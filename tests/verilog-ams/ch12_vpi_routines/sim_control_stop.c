/* b7 vpiStop: VAMS-2023 12.36, over digital.v.
 *
 * 12.36  "All standard compliant simulators must support the following three
 *        operations: vpiStop — cause $stop built-in Verilog system task to be
 *        executed upon return of user function. This operation shall be
 *        passed one additional diagnostic message level integer argument
 *        that is the same as the argument passed to $stop (see 9.7.2)."
 *        Returns "1 (true) if successful; 0 (false) on a failure".
 * vpiStop is IEEE 1364-2005 Annex G's 66; src/vpi/vpi_user.h does not define
 * it, so this file does.
 *
 * DERIVATION. At t=1, from a cbAfterDelay routine, vpi_sim_control(vpiStop,
 * 1) (diagnostic level 1, a legal $stop argument, 9.7.2) is a supported
 * operation with its one argument, so it succeeds: 1, and no error. What
 * $stop then does in a run with no interactive mode is 9.7.2's, not this
 * row's, and is not asserted beyond the run reaching its end.
 */

//! lrm 12.36:3
//! lrm 12.36:4
//! design digital.v
//! stdout p02: b7_sim_control_stop checks=6

#include "../ch11_vpi/p02_check.h"

#ifndef vpiStop
#define vpiStop 66
#endif

static int calls;

static PLI_INT32 at1(p_cb_data d)
{
  (void)d;
  calls++;
  CHECK(vpi_sim_control(vpiStop, 1) == 1, "12.36: vpi_sim_control(vpiStop, 1) failed; every compliant simulator supports vpiStop");
  expect_no_error("vpi_sim_control(vpiStop, 1)");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  (void)d;
  t.type = vpiSimTime;
  t.low = 1;
  cb.reason = cbAfterDelay;
  cb.cb_rtn = at1;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbAfterDelay(1) registration failed");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(calls == 1, "the operation was requested once, got %d", calls);
  p02_done("b7_sim_control_stop");
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
