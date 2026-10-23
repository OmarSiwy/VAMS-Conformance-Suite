/* 04 — vpi_put_value()'s vpiForceFlag / vpiReleaseFlag, and the cbForce /
 * cbRelease callbacks that observe them.
 *
 * LRM 12.30: "vpiForceFlag — The object shall be forced to the passed value
 * with no delay (same as the Verilog-AMS HDL procedural force). Argument time_p
 * shall be ignored and can be set to NULL."
 *
 * LRM 12.30: "vpiReleaseFlag — The object shall be released from a forced value
 * (same as the Verilog-AMS HDL procedural release). Argument time_p shall be
 * ignored and can be set to NULL. The value_p shall contain the current value
 * of the object."
 *
 * LRM 12.31.1: "cbForce/cbRelease  After a force or release has occurred" and
 * "cb_data_p->obj ... For force and release callbacks, if this is set to NULL,
 * every force and release shall generate a callback."
 *
 * LRM 12.31.1: "For cbForce, cbRelease, cbAssign, and cbDeassign callbacks, the
 * object returned in the obj field shall be a handle to the force, release,
 * assign or deassign statement. The value field shall contain the resultant
 * value of the LHS expression. In the case of a release, the value field shall
 * contain the value after the release has occurred."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * The forced object is `w`, an 8-bit net driven by a continuous assignment
 * `assign w = a + 8'd1`. A net, not a reg, deliberately: releasing a reg leaves
 * it holding the forced value until someone assigns it again, so a release test
 * on a reg has no observable destination. Releasing a continuously driven net
 * re-evaluates the driver, and the driver's answer is arithmetic this file can
 * do by hand.
 *
 *   t=0   a = 10  ->  w = 10 + 1 = 11
 *   t=2   application forces w = 0xF0 = 240. The driver still says 11; the
 *         force wins, so w reads 240.
 *   t=6   the design assigns a = 20. The driver now says 20 + 1 = 21, and w is
 *         still forced, so w still reads 240. This is the step that proves the
 *         force actually overrides the driver rather than merely having
 *         happened to match it.
 *   t=10  application releases w. "The value_p shall contain the current value
 *         of the object" — the current value, after the release, is the
 *         driver's: 21. The cbRelease callback sees 21 for the same reason.
 *   t=12  w reads 21, unforced.
 *
 * Callback census: obj == NULL means EVERY force and release is reported, and
 * this application performs exactly one of each and the design performs none,
 * so forces == 1 and releases == 1. A count of 2 would mean the release was
 * also reported as a force, or the single force was reported twice.
 */

//! lrm 12.2
//! lrm 12.16
//! lrm 12.21
//! lrm 12.30
//! lrm 12.31
//! lrm 12.31.1
//! lrm 12.31.2
//! lrm 12.33.2
//! lrm 12.30:5
//! lrm 12.30:6
//! lrm 12.30:7
//! lrm 12.30:8
//! lrm 12.31.1:2
//! lrm 12.31.1:3
//! lrm 12.31.1:11
//! lrm 12.31.1:12
//! design ../digital/design.v
//! stdout p02: 04_force_release checks=39
//! stdout p02_design: t=20 reached

#include "p02_check.h"

static vpiHandle w, a;
static int forces = 0, releases = 0;
static PLI_INT32 force_value = -1, release_value = -1;

static PLI_INT32 byte_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  expect_no_error("vpi_get_value(vpiIntVal)");
  return v.value.integer;
}

static int on_force(p_cb_data cb_data)
{
  forces++;
  CHECK(cb_data->reason == cbForce, "the callback must be told its own reason");
  CHECK(cb_data->obj != NULL, "12.31.1: obj is a handle to the force statement");
  CHECK(cb_data->value != NULL && cb_data->value->format == vpiIntVal,
        "the value must arrive in the format registered for");
  force_value = cb_data->value->value.integer;
  return 0;
}

static int on_release(p_cb_data cb_data)
{
  releases++;
  CHECK(cb_data->reason == cbRelease, "the callback must be told its own reason");
  CHECK(cb_data->obj != NULL, "12.31.1: obj is a handle to the release statement");
  release_value = cb_data->value->value.integer;
  return 0;
}

static int at2(p_cb_data cb_data)
{
  s_vpi_value v;
  vpiHandle   r;
  (void)cb_data;

  w = p02_by_name("p02_design.w");
  a = p02_by_name("p02_design.a");

  CHECK(byte_of(a) == 10, "t=2: a should be 10");
  CHECK(byte_of(w) == 11, "t=2: the driver gives w = a + 1 = 11");

  v.format = vpiIntVal;
  v.value.integer = 0xF0;
  r = vpi_put_value(w, &v, NULL, vpiForceFlag);
  expect_no_error("vpi_put_value(vpiForceFlag)");
  CHECK(r == NULL, "a force uses no delay, so no event handle is returned");
  CHECK(byte_of(w) == 0xF0, "t=2: w must read the forced 240 immediately");

  CHECK(forces == 1, "the force must have produced exactly one cbForce");
  CHECK(force_value == 0xF0, "cbForce must carry 240, got %d", (int)force_value);
  CHECK(releases == 0, "a force is not a release");
  return 0;
}

static int at7(p_cb_data cb_data)
{
  (void)cb_data;
  CHECK(byte_of(a) == 20, "t=7: the design assigned a = 20 at t=6");
  CHECK(byte_of(w) == 0xF0,
        "t=7: the driver now says 21, but w is forced and must still read 240");
  return 0;
}

static int at10(p_cb_data cb_data)
{
  s_vpi_value v;
  vpiHandle   r;
  (void)cb_data;

  v.format = vpiIntVal;
  v.value.integer = -1;              /* poisoned: the routine must overwrite it */
  r = vpi_put_value(w, &v, NULL, vpiReleaseFlag);
  expect_no_error("vpi_put_value(vpiReleaseFlag)");
  CHECK(r == NULL, "a release uses no delay, so no event handle is returned");
  CHECK(v.value.integer == 21,
        "12.30: value_p must come back holding the post-release value 21, got %d",
        (int)v.value.integer);

  CHECK(releases == 1, "the release must have produced exactly one cbRelease");
  CHECK(release_value == 21,
        "12.31.1: cbRelease carries the value AFTER the release, want 21, got %d",
        (int)release_value);
  CHECK(forces == 1, "a release must not be reported as a second force");
  return 0;
}

static int at12(p_cb_data cb_data)
{
  (void)cb_data;
  CHECK(byte_of(w) == 21, "t=12: w is back under its driver and reads 21");
  CHECK(forces == 1 && releases == 1,
        "final census: 1 force and 1 release, got %d and %d", forces, releases);
  p02_done("04_force_release");
  return 0;
}

static void at(PLI_INT32 reason, PLI_INT32 (*fn)(p_cb_data), PLI_UINT32 when)
{
  static s_vpi_time times[8];
  static s_cb_data  cbs[8];
  static int        used = 0;
  int i = used++;

  times[i].type = vpiSimTime;
  times[i].high = 0;
  times[i].low  = when;
  times[i].real = 0.0;

  cbs[i].reason    = reason;
  cbs[i].cb_rtn    = fn;
  cbs[i].obj       = NULL;
  cbs[i].time      = &times[i];
  cbs[i].value     = NULL;
  cbs[i].index     = 0;
  cbs[i].user_data = NULL;

  CHECK(vpi_register_cb(&cbs[i]) != NULL, "registration at t=%u failed", when);
}

static void setup_after_compile(void)
{
  static s_vpi_value fv = { vpiIntVal, { 0 } };
  static s_vpi_time  ft = { vpiSuppressTime, 0, 0, 0.0 };
  static s_cb_data   fcb, rcb;

  /* obj == NULL: "every force and release shall generate a callback". */
  fcb.reason = cbForce;   fcb.cb_rtn = on_force;
  fcb.obj = NULL; fcb.time = &ft; fcb.value = &fv; fcb.index = 0; fcb.user_data = NULL;
  CHECK(vpi_register_cb(&fcb) != NULL, "cbForce registration failed");

  rcb.reason = cbRelease; rcb.cb_rtn = on_release;
  rcb.obj = NULL; rcb.time = &ft; rcb.value = &fv; rcb.index = 0; rcb.user_data = NULL;
  CHECK(vpi_register_cb(&rcb) != NULL, "cbRelease registration failed");

  at(cbReadWriteSynch, at2,   2);
  at(cbReadOnlySynch,  at7,   7);
  at(cbReadWriteSynch, at10, 10);
  at(cbReadOnlySynch,  at12, 12);
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
