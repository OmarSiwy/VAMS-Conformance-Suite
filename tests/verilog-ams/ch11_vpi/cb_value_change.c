/* 06 — cbValueChange: how many times it fires, what it carries, and the `index`
 * field for a memory word.
 *
 * LRM 12.31.1: "cbValueChange  After value change on an expression or terminal".
 *
 * LRM 12.31.1: "When a simulation event callback occurs, the user application
 * shall be passed a single argument, which is a pointer to an s_cb_data
 * structure (this is not a pointer to the same structure which was passed to
 * vpi_register_cb()). The time and value information shall be set as directed
 * by the time type and value format fields in the call to vpi_register_cb().
 * The user_data field shall be equivalent to the user_data field passed to
 * vpi_register_cb()."
 *
 * LRM 12.31.1: "For a cbValueChange callback, if the obj is a memory word or a
 * variable array, the value in the s_cb_data structure shall be the value of
 * the memory word or variable select which changed value. The index field shall
 * contain the index of the memory word or variable select which changed value."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * The word is CHANGE, not write, and both halves of that are pinned here.
 *
 * p02_design.n is `reg [3:0]`, so it holds 4'bxxxx until something assigns it.
 * Its complete write history is
 *
 *   t=0  n = 0   xxxx -> 0     a change (an unknown becoming a known IS one)
 *   t=1  n = 5      0 -> 5     a change
 *   t=2  n = 9      5 -> 9     a change
 *   t=3  n = 9      9 -> 9     a WRITE THAT IS NOT A CHANGE — no callback
 *   t=4  n = 2      9 -> 2     a change
 *
 * so a correct implementation delivers EXACTLY FOUR callbacks, at t = 0, 1, 2,
 * 4, carrying 0, 5, 9, 2. Five callbacks means t=3 leaked through; three means
 * the x-to-0 transition at t=0 was not counted. Registration happens from
 * cbStartOfSimulation, which 12.31.4 places at the "beginning of time 0
 * simulation cycle" — before the initial blocks run — so the t=0 transition is
 * inside the callback's lifetime and must be reported.
 *
 * p02_design.mem is `reg [7:0] mem [0:3]`, written
 *
 *   t=0  mem[0]=0x00, mem[1]=0x00, mem[2]=0x00, mem[3]=0x00   (each xx -> 00)
 *   t=1  mem[2]=0x7E
 *
 * = FIVE callbacks, in that order, carrying index 0,1,2,3 then 2, and values
 * 0,0,0,0 then 0x7E = 126. The last one is the interesting one: it is the only
 * place `index` can be wrong without also making the value wrong.
 *
 * TIME AND VALUE DELIVERY. Registered with time->type = vpiSimTime and
 * value->format = vpiIntVal, so 12.31.1's "set as directed by" sentence says
 * each delivered structure must carry those same two tags and the delivered
 * time must equal the tick the change happened at. The timescale is 1ns/1ns, so
 * the tick and the nanosecond are the same number.
 */

//! lrm 11.2.1
//! lrm 12.3
//! lrm 12.21
//! lrm 12.31
//! lrm 12.31.1
//! lrm 12.31.2
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 11.2.1:1
//! lrm 11.2.1:2
//! lrm 11.2.1:3
//! lrm 11.2.1:5
//! lrm 12.3:1
//! lrm 12.31:1
//! lrm 12.31:3
//! lrm 12.31.1:6
//! lrm 12.31.1:7
//! lrm 12.31.1:8
//! lrm 12.31.1:9
//! design ../digital/design.v
//! stdout p02: 06_cb_value_change checks=62
//! stdout p02_design: t=20 reached

#include "p02_check.h"

static vpiHandle n, mem;

static int n_hits = 0;
static PLI_UINT32 n_time[8];
static PLI_INT32  n_value[8];

static int m_hits = 0;
static PLI_UINT32 m_time[8];
static PLI_INT32  m_index[8];
static PLI_INT32  m_value[8];

static int on_n(p_cb_data cb_data)
{
  CHECK(n_hits < 8, "more cbValueChange callbacks on n than the design can cause");
  CHECK(cb_data->reason == cbValueChange, "reason must be echoed back");
  CHECK(cb_data->time != NULL && cb_data->time->type == vpiSimTime,
        "time must arrive in the registered type");
  CHECK(cb_data->value != NULL && cb_data->value->format == vpiIntVal,
        "value must arrive in the registered format");
  CHECK(cb_data->user_data != NULL && strcmp(cb_data->user_data, "n") == 0,
        "12.31.1: user_data must be equivalent to what was registered");
  CHECK(vpi_compare_objects(cb_data->obj, n) == 1,
        "the delivered obj must be the object registered for");
  n_time[n_hits]  = cb_data->time->low;
  n_value[n_hits] = cb_data->value->value.integer;
  n_hits++;
  return 0;
}

static int on_mem(p_cb_data cb_data)
{
  CHECK(m_hits < 8, "more cbValueChange callbacks on mem than the design can cause");
  m_time[m_hits]  = cb_data->time->low;
  m_index[m_hits] = cb_data->index;
  m_value[m_hits] = cb_data->value->value.integer;
  m_hits++;
  return 0;
}

static int census(p_cb_data cb_data)
{
  static const PLI_UINT32 want_nt[4] = { 0, 1, 2, 4 };
  static const PLI_INT32  want_nv[4] = { 0, 5, 9, 2 };
  static const PLI_UINT32 want_mt[5] = { 0, 0, 0, 0, 1 };
  static const PLI_INT32  want_mi[5] = { 0, 1, 2, 3, 2 };
  static const PLI_INT32  want_mv[5] = { 0, 0, 0, 0, 0x7E };
  int i;
  (void)cb_data;

  CHECK(n_hits == 4,
        "n changes value at t=0,1,2,4 and is merely rewritten at t=3: "
        "want 4 callbacks, got %d", n_hits);
  for (i = 0; i < 4; i++) {
    CHECK(n_time[i] == want_nt[i],
          "n callback %d should be at t=%u, was at t=%u",
          i, (unsigned)want_nt[i], (unsigned)n_time[i]);
    CHECK(n_value[i] == want_nv[i],
          "n callback %d should carry %d, carried %d",
          i, (int)want_nv[i], (int)n_value[i]);
  }

  CHECK(m_hits == 5,
        "mem takes four time-0 initialisations and one write at t=1: "
        "want 5 callbacks, got %d", m_hits);
  for (i = 0; i < 5; i++) {
    CHECK(m_time[i] == want_mt[i],
          "mem callback %d should be at t=%u, was at t=%u",
          i, (unsigned)want_mt[i], (unsigned)m_time[i]);
    CHECK(m_index[i] == want_mi[i],
          "mem callback %d should report index %d, reported %d",
          i, (int)want_mi[i], (int)m_index[i]);
    CHECK(m_value[i] == want_mv[i],
          "mem callback %d should carry 0x%02x, carried 0x%02x",
          i, (unsigned)want_mv[i], (unsigned)m_value[i]);
  }

  p02_done("06_cb_value_change");
  return 0;
}

static int on_start_of_simulation(p_cb_data cb_data)
{
  static s_vpi_time  nt = { vpiSimTime, 0, 0, 0.0 };
  static s_vpi_value nv = { vpiIntVal, { 0 } };
  static s_vpi_time  mt = { vpiSimTime, 0, 0, 0.0 };
  static s_vpi_value mv = { vpiIntVal, { 0 } };
  static s_vpi_time  ct = { vpiSimTime, 0, 30, 0.0 };
  static s_cb_data   ncb, mcb, ccb;
  (void)cb_data;

  n   = p02_by_name("p02_design.n");
  mem = p02_by_name("p02_design.mem");

  ncb.reason = cbValueChange; ncb.cb_rtn = on_n;   ncb.obj = n;
  ncb.time = &nt; ncb.value = &nv; ncb.index = 0;
  ncb.user_data = (PLI_BYTE8 *)"n";
  CHECK(vpi_register_cb(&ncb) != NULL, "cbValueChange on n failed to register");

  mcb.reason = cbValueChange; mcb.cb_rtn = on_mem; mcb.obj = mem;
  mcb.time = &mt; mcb.value = &mv; mcb.index = 0; mcb.user_data = NULL;
  CHECK(vpi_register_cb(&mcb) != NULL, "cbValueChange on mem failed to register");

  ccb.reason = cbReadOnlySynch; ccb.cb_rtn = census; ccb.obj = NULL;
  ccb.time = &ct; ccb.value = NULL; ccb.index = 0; ccb.user_data = NULL;
  CHECK(vpi_register_cb(&ccb) != NULL, "the census callback failed to register");
  return 0;
}

static void setup(void)
{
  static s_cb_data start;
  start.reason = cbStartOfSimulation;
  start.cb_rtn = on_start_of_simulation;
  start.obj = NULL; start.time = NULL; start.value = NULL;
  start.index = 0; start.user_data = NULL;
  CHECK(vpi_register_cb(&start) != NULL, "cbStartOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
