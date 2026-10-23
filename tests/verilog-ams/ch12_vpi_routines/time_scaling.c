/* b7 time scaling: VAMS-2023 12.31.2, a time callback's scaled real time is
 * in the unit of its obj, and the routine is handed a structure of the
 * system's, not the registered one.
 *
 * 12.31.2  "When the cb_data_p->time->type is set to vpiScaledRealTime, the
 *          cb_data_p->obj field shall be used as the object for determining
 *          the time scaling." "cbAtStartOfSimTime Callback shall occur before
 *          execution of events in a specified time queue." "cbAfterDelay
 *          Callback shall occur after a specified amount of time". "When a
 *          simulation-time-related callback occurs, the user callback
 *          application shall be passed a single argument, which is a pointer
 *          to an s_cb_data structure (this is not a pointer to the same
 *          structure which was passed to vpi_register_cb()). The time
 *          structure shall contain the current simulation time."
 *          "The value fields are ignored for all reasons with
 *          simulation-time-related callbacks."
 * 12.15    "If obj is NULL, the simulation time is retrieved using the
 *          simulation time unit."
 *
 * DERIVATION (scales.v: simulation unit 1 ns; b7_scales 1 ns, its
 * instance u of b7_scales_sub 1 us). Registered at end of compile, t=0:
 *   A  cbAtStartOfSimTime, vpiScaledRealTime 3.0, obj u:
 *      3.0 us = 3000 ticks. Fires at t=3000, before that queue's events, so
 *      tick still reads 0; its time, in u's unit, 3.0.
 *   B  cbAtStartOfSimTime, vpiScaledRealTime 3.0, obj b7_scales:
 *      3.0 ns = 3 ticks. Fires at t=3; its time 3.0.
 *   C  cbAfterDelay, vpiScaledRealTime 0.5, obj u:
 *      0.5 us = 500 ticks after t=0. Fires at t=500; its time 0.5.
 * A tool that scaled by the simulation unit instead fires A and B at 3 and C
 * at 0 (0.5 ns rounds to 0 or 1 tick); one that ignored obj for b7_scales's
 * unit would fire A at 3. Each value is exact in binary64 (3000/1000,
 * 3/1, 500/1000), so compared with ==. Each routine's argument is not the
 * address of the structure it was registered with. Each registration carries a
 * value with format vpiIntVal; a time callback ignores it, and the callback
 * still arrives at the time and for the reason above. At A (tick 3000),
 * vpi_get_time(NULL, vpiScaledRealTime) is 3000.0: the simulation time unit
 * is the 1 ns unit, not u's 1 us.
 */

//! lrm 12.31.2
//! lrm 12.31.2:4
//! lrm 12.31.2:5
//! lrm 12.31.2:1001
//! lrm 12.15:1001
//! design scales.v
//! stdout p02: b7_time_scaling checks=26

#include "../ch11_vpi/p02_check.h"

static vpiHandle top, sub, tick;
static s_vpi_time ta, tb, tc;
static s_cb_data ra, rb, rc;
static int a_hits, b_hits, c_hits;

static PLI_UINT32 now(void)
{
  s_vpi_time t;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  return t.low;
}

static PLI_INT32 int_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  return v.value.integer;
}

static PLI_INT32 on_a(p_cb_data d)
{
  a_hits++;
  CHECK(d != &ra, "12.31.2: the routine is passed a structure that is not the registered one");
  CHECK(now() == 3000, "12.31.2: 3.0 in u's 1 us unit is 3000 ticks, fired at %u", (unsigned)now());
  CHECK(int_of(tick) == 0, "cbAtStartOfSimTime runs before t=3000's events, so tick is still 0");
  CHECK(d->time != NULL && d->time->type == vpiScaledRealTime && d->time->real == 3.0,
        "12.31.2: the time, in u's unit, is 3.0, got %.17g", d->time ? d->time->real : -1.0);
  {
    s_vpi_time n;
    n.type = vpiScaledRealTime;
    vpi_get_time(NULL, &n);
    CHECK(n.real == 3000.0, "12.15: with obj NULL the time is in the simulation time unit (1 ns), got %.17g", n.real);
  }
  return 0;
}

static PLI_INT32 on_b(p_cb_data d)
{
  b_hits++;
  CHECK(d != &rb, "12.31.2: the routine is passed a structure that is not the registered one");
  CHECK(now() == 3, "12.31.2: 3.0 in b7_scales's 1 ns unit is 3 ticks, fired at %u", (unsigned)now());
  CHECK(d->time != NULL && d->time->type == vpiScaledRealTime && d->time->real == 3.0,
        "12.31.2: the time, in b7_scales's unit, is 3.0, got %.17g", d->time ? d->time->real : -1.0);
  return 0;
}

static PLI_INT32 on_c(p_cb_data d)
{
  c_hits++;
  CHECK(d != &rc, "12.31.2: the routine is passed a structure that is not the registered one");
  CHECK(now() == 500, "12.31.2: a 0.5 delay in u's 1 us unit is 500 ticks, fired at %u", (unsigned)now());
  CHECK(d->time != NULL && d->time->type == vpiScaledRealTime && d->time->real == 0.5,
        "12.31.2: the time, in u's unit, is 0.5, got %.17g", d->time ? d->time->real : -1.0);
  return 0;
}

static void arm(s_cb_data *cb, s_vpi_time *t, PLI_INT32 reason, PLI_INT32 (*fn)(p_cb_data), vpiHandle obj, double real)
{
  static s_vpi_value ignored;
  t->type = vpiScaledRealTime;
  t->real = real;
  ignored.format = vpiIntVal;
  ignored.value.integer = 42;
  cb->reason = reason;
  cb->cb_rtn = fn;
  cb->obj = obj;
  cb->time = t;
  cb->value = &ignored;
  CHECK(vpi_register_cb(cb) != NULL, "registering reason %d at %g failed", (int)reason, real);
  expect_no_error("vpi_register_cb(vpiScaledRealTime)");
}

static PLI_INT32 eoc(p_cb_data d)
{
  (void)d;
  top = p02_by_name("b7_scales");
  sub = p02_by_name("b7_scales.u");
  tick = p02_by_name("b7_scales.tick");
  arm(&ra, &ta, cbAtStartOfSimTime, on_a, sub, 3.0);
  arm(&rb, &tb, cbAtStartOfSimTime, on_b, top, 3.0);
  arm(&rc, &tc, cbAfterDelay, on_c, sub, 0.5);
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(a_hits == 1 && b_hits == 1 && c_hits == 1, "each callback once, got %d %d %d", a_hits, b_hits, c_hits);
  p02_done("b7_time_scaling");
  return 0;
}

static void setup(void)
{
  static s_cb_data c, e;
  c.reason = cbEndOfCompile;
  c.cb_rtn = eoc;
  CHECK(vpi_register_cb(&c) != NULL, "cbEndOfCompile registration failed");
  e.reason = cbEndOfSimulation;
  e.cb_rtn = eos;
  CHECK(vpi_register_cb(&e) != NULL, "cbEndOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
