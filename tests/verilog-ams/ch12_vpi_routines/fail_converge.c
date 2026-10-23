/* b7 vpiTransientFailConverge: VAMS-2023 12.36's analog control operation
 * that keeps the solver on the current time point.
 *
 * 12.36  "vpiTransientFailConverge — cause the current analog simulation to
 *        continue iterating for a (valid) solution." Returns "1 (true) if
 *        successful; 0 (false) on a failure".
 * 12.31.3 acbConvergenceTest "Prior acceptance of the analog solution for the
 *        given time (this callback allows rejection of the analog solution at
 *        that time and backup to an earlier time)"; acbAcceptedPoint "Upon
 *        acceptance of the solution at the given time".
 *
 * DERIVATION. The analysis is this banner's `tran 0 5m` over ramp_load.va.
 * At the first acbConvergenceTest at t >= 2e-3 the routine asks for
 * vpiTransientFailConverge (no argument is listed for it): a listed
 * operation on a solution awaiting acceptance, so it succeeds, 1, and no
 * error. "Continue iterating for a (valid) solution" keeps the solver on THE
 * SAME time point: unlike vpiRejectTransientStep (p03_12) it does not back up
 * to an earlier time, and the point is not accepted first. So the next
 * acbConvergenceTest is at that same time (within 1e-15 s, the solver's last
 * bits), with no acbAcceptedPoint between, and the run still ends at 5e-3.
 *
 *! design   ramp_load.va
 *! analysis tran 0 5m
 */

//! lrm 12.36:8
//! design ramp_load.va
//! stdout b7-fail-converge: retested=1 t_final=0.005

#include "p03_vpi_analog.h"

#ifndef vpiTransientFailConverge

static void b7_startup(void)
{
  P03_FAIL("12.36: src/vpi/vpi_user.h defines no vpiTransientFailConverge");
}

#else

static int asked, retested, accepted_between;
static double asked_t = -1.0;

static PLI_INT32 on_convergence(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  (void)cb;
  if (asked && !retested) {
    P03_NEAR(t, asked_t, 1e-15, "12.36: after vpiTransientFailConverge the next convergence test is at the same time");
    P03_CHECK(accepted_between == 0, "12.36: %d points were accepted before the same time was tested again", accepted_between);
    retested = 1;
  }
  if (!asked && t >= 2.0e-3) {
    P03_CHECK(vpi_sim_control(vpiTransientFailConverge) == 1, "12.36: vpiTransientFailConverge failed on a solution awaiting acceptance");
    p03_no_error("vpi_sim_control(vpiTransientFailConverge)");
    asked = 1;
    asked_t = t;
  }
  return 0;
}

static PLI_INT32 on_accepted(p_cb_data cb)
{
  (void)cb;
  if (asked && !retested) accepted_between++;
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(asked == 1 && retested == 1, "12.36: the operation was asked (%d) and the time tested again (%d)", asked, retested);
  P03_NEAR(vpi_get_analog_time(), 5.0e-3, 1e-15, "acbFinalStep time");
  printf("b7-fail-converge: retested=1 t_final=0.005\n");
  fflush(stdout);
  return 0;
}

static void b7_after_compile(void)
{
  static s_cb_data cvg_cb, acc_cb, fin_cb;
  cvg_cb.reason = acbConvergenceTest; cvg_cb.cb_rtn = on_convergence;
  acc_cb.reason = acbAcceptedPoint;   acc_cb.cb_rtn = on_accepted;
  fin_cb.reason = acbFinalStep;       fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&cvg_cb) != NULL, "acbConvergenceTest registration failed");
  P03_CHECK(vpi_register_cb(&acc_cb) != NULL, "acbAcceptedPoint registration failed");
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the callbacks
 * above register at cbEndOfCompile (p03_defer, VD-044). */
static void b7_startup(void)
{
  p03_defer(b7_after_compile);
}

#endif

void (*vlog_startup_routines[])(void) = { b7_startup, 0 };
