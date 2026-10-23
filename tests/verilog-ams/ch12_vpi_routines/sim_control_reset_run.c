/* b7 vpiReset that runs on: VAMS-2023 12.36 with a nonzero stop_value, over
 * digital.v.
 *
 * 12.36  "vpiReset — cause $reset informative built-in Verilog system task
 *        to be executed upon return of user VPI function. This operation
 *        shall be passed three integer value arguments: stop_value,
 *        reset_value, diagnostic_level that are the same values passed to the
 *        $reset system task (see F.7 of IEEE Std 1364 Verilog)." Returns
 *        "1 (true) if successful; 0 (false) on a failure".
 * IEEE 1364-2005 C.7 (VAMS's F.7): "The $reset system task tells a tool to
 * return the processing of the design to its logical state at time 0." It
 * "Cancels all scheduled simulation events", and after it "The simulation
 * time is 0. All regs and nets contain their initial values. The tool begins
 * to execute the first procedural statements in all initial and always
 * blocks." "A nonzero value passed to $reset causes the tool to begin
 * processing immediately." 4.2.2: "The initialization value for reg, time,
 * and integer data types shall be the unknown value, x."
 *
 * DERIVATION (digital.v's timeline). cbValueChange on alpha and on w40
 * count their changes; at t=3, from a cbAfterDelay routine,
 * vpi_sim_control(vpiReset, 1, 0, 0), once.
 *   first run:  t=0 alpha x -> 8'h01 (alpha 1), w40 x -> 0 (w40 1);
 *               t=2 w40 -> 40'h12_3456_789A (w40 2). The reset at 3 comes
 *               first; its t=4 change and its $finish at 10 are cancelled.
 *   the reset:  time 0, alpha and w40 back to x, which is no value change
 *               a process made.
 *   second run: t=0 alpha x -> 8'h01 (alpha 2: a change only because the
 *               reset made alpha x again), w40 x -> 0 (w40 3); t=2 (w40 4);
 *               t=4 -> 40'hA5_zzzz_xxxx (w40 5); t=10 $finish(0).
 * So cbEndOfSimulation sees alpha changed 2 times, w40 5 times, at time 10.
 * A run that went on from 3 without resetting would have alpha 1 and w40 3;
 * one that reset without re-initialising alpha would have alpha 1. The
 * cbAfterDelay fired once and is gone, so the second run asks no reset.
 *
 * CENSUS: setup 2; eoc 7 (two p02_by_name, a CHECK and an expect_no_error
 * each, and three registrations); at3 2 at its one call; eos 4: checks=15.
 */

//! lrm 12.36
//! lrm 12.36:5
//! lrm 12.36:6
//! design digital.v
//! stdout p02: b7_sim_control_reset_run checks=15

#include "../ch11_vpi/p02_check.h"

#ifndef vpiReset
#define vpiReset 68
#endif

static int calls, alpha_changes, w40_changes;

static PLI_INT32 on_alpha(p_cb_data d)
{
  (void)d;
  alpha_changes++;
  return 0;
}

static PLI_INT32 on_w40(p_cb_data d)
{
  (void)d;
  w40_changes++;
  return 0;
}

static PLI_INT32 at3(p_cb_data d)
{
  (void)d;
  if (calls++ != 0) return 0;
  CHECK(vpi_sim_control(vpiReset, 1, 0, 0) == 1, "12.36: vpi_sim_control(vpiReset, 1, 0, 0) failed");
  expect_no_error("vpi_sim_control(vpiReset, 1, 0, 0)");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data a, w, cb;
  (void)d;
  a.reason = cbValueChange;
  a.cb_rtn = on_alpha;
  a.obj = p02_by_name("b7_digital.alpha");
  CHECK(vpi_register_cb(&a) != NULL, "cbValueChange on alpha registration failed");
  w.reason = cbValueChange;
  w.cb_rtn = on_w40;
  w.obj = p02_by_name("b7_digital.w40");
  CHECK(vpi_register_cb(&w) != NULL, "cbValueChange on w40 registration failed");
  t.type = vpiSimTime;
  t.low = 3;
  cb.reason = cbAfterDelay;
  cb.cb_rtn = at3;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbAfterDelay(3) registration failed");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  s_vpi_time t;
  (void)d;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  CHECK(calls == 1, "the reset was requested once, got %d", calls);
  CHECK(alpha_changes == 2, "C.7: alpha changes once per run, the second only because the reset made it x; got %d", alpha_changes);
  CHECK(w40_changes == 5, "C.7: w40 changes twice before the reset and three times after it; got %d", w40_changes);
  CHECK(t.high == 0 && t.low == 10, "C.7: the second run ends at its own $finish, t=10; got %u", (unsigned)t.low);
  p02_done("b7_sim_control_reset_run");
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
