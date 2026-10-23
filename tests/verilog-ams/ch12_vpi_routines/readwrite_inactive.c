/* b8 a read-write callback is an inactive event: VAMS-2023 8.5.1 over
 * readwrite_inactive.v.
 *
 * 8.5.1  "The call back procedures scheduled with PLI routines such as
 *        tf_synchronize() ... or vpi_register_cb(cb_readwrite) ... shall be
 *        treated as inactive events."
 *
 * 8.5.1's regions at one time: active events, then explicit D2A, then
 * inactive events, then the nonblocking assign updates, then monitor events.
 * So a cbReadWriteSynch callback due at t runs AFTER the active events at t
 * and BEFORE the nonblocking updates at t.
 *
 * DERIVATION. At t=7 the design's process runs `b = 8'h11` (active) and
 * `r <= 8'h42` (its update is a nonblocking assign update event). The
 * read-write callback registered for t=7 must therefore read b = 0x11 (the
 * active event has run) and r = 0x00 (the update has not). A host that runs
 * read-write callbacks after the whole time slice reads r = 0x42 and fails
 * here. The read-only callback at t=7 comes after every event of the time
 * (12.31.2 "after execution of events"), so it reads both new values; that
 * pins that the update did happen at 7 and the 0x00 is not a design quirk.
 */

//! lrm 8.5.1
//! lrm 8.5.1:6
//! design readwrite_inactive.v
//! stdout p02: b8_readwrite_inactive checks=13

#include "../ch11_vpi/p02_check.h"

static vpiHandle r, b;
static int n_rw = 0, n_ro = 0;

static PLI_INT32 byte_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  return v.value.integer;
}

static PLI_INT32 on_read_write(p_cb_data d)
{
  (void)d;
  n_rw++;
  CHECK(byte_of(b) == 0x11, "8.5.1: the read-write callback runs after the active events at t=7, so b is 0x11, got 0x%02x", (unsigned)byte_of(b));
  CHECK(byte_of(r) == 0x00, "8.5.1: the read-write callback is an inactive event, before the nonblocking update, so r is still 0x00, got 0x%02x", (unsigned)byte_of(r));
  return 0;
}

static PLI_INT32 on_read_only(p_cb_data d)
{
  (void)d;
  n_ro++;
  CHECK(byte_of(b) == 0x11, "the read-only callback at t=7 reads b = 0x11");
  CHECK(byte_of(r) == 0x42, "the read-only callback at t=7 follows the nonblocking update: r = 0x42, got 0x%02x", (unsigned)byte_of(r));
  return 0;
}

static PLI_INT32 on_end(p_cb_data d)
{
  (void)d;
  CHECK(n_rw == 1, "the read-write callback fires once, fired %d", n_rw);
  CHECK(n_ro == 1, "the read-only callback fires once, fired %d", n_ro);
  p02_done("b8_readwrite_inactive");
  return 0;
}

static void reg_at(PLI_INT32 reason, PLI_INT32 (*fn)(p_cb_data), PLI_UINT32 low)
{
  static s_vpi_time times[2];
  static s_cb_data cbs[2];
  static int used = 0;
  int i = used++;
  times[i].type = vpiSimTime;
  times[i].high = 0;
  times[i].low = low;
  cbs[i].reason = reason;
  cbs[i].cb_rtn = fn;
  cbs[i].time = &times[i];
  CHECK(vpi_register_cb(&cbs[i]) != NULL, "registration for reason %d failed", (int)reason);
}

static void setup_after_compile(void)
{
  static s_cb_data e;
  r = p02_by_name("b8_readwrite_inactive.r");
  b = p02_by_name("b8_readwrite_inactive.b");
  reg_at(cbReadWriteSynch, on_read_write, 7);
  reg_at(cbReadOnlySynch, on_read_only, 7);
  e.reason = cbEndOfSimulation;
  e.cb_rtn = on_end;
  CHECK(vpi_register_cb(&e) != NULL, "cbEndOfSimulation registration failed");
}

static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
