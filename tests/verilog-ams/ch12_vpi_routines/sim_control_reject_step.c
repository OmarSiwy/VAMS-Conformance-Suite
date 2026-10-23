/* P03 — VAMS-2023 12.36: vpi_sim_control(vpiRejectTransientStep) rejects the
 * analog solution awaiting acceptance.
 *
 *   12.36    "vpiRejectTransientStep — cause the current analog simulation
 *            time point to be rejected. This operation shall pass one
 *            argument which is the current timestep (delta)."
 *            Returns "1 (true) if successful; 0 (false) on a failure".
 *   12.31.3  acbConvergenceTest "Prior acceptance of the analog solution for
 *            the given time": the moment a solution exists and is not yet
 *            accepted, so the moment it can be rejected.
 *   8.4.7    "it cannot calculate a solution for a future time until it has
 *            accepted the solution for the current time."
 *
 * p03_05 rejects through the callback's return value. This plugin returns 0
 * (accept) from every acbConvergenceTest and rejects ONCE through the routine
 * instead, at the first test at t >= 2e-3. What is forced:
 *
 *   - the call returns 1: a transient point after the first is awaiting
 *     acceptance, so the operation has something to act on;
 *   - the next acbConvergenceTest is at a time STRICTLY LESS than the rejected
 *     one, with no acbAcceptedPoint between (the same ordering p03_05 pins);
 *   - the run still reaches acbFinalStep at t == 5e-3 exactly.
 *
 * And the refusal: at cbEndOfCompile, where the startup routine defers its
 * work (IEEE 1364-2005 26.2.4), no analysis is running, so there is no
 * "current analog simulation time point" and the call must fail — 0, with
 * vpi_chk_error set.
 *
 *! design   ramp_load.va
 *! analysis tran 0 5m
 */

//! lrm 12.36
//! lrm-reject 12.36
//! lrm 12.36:2
//! lrm-reject 12.36:2
//! design ramp_load.va
//! stdout p03-12: rejected=1 backed_up=1 t_final=0.005

#include "p03_vpi_analog.h"

#define TSTOP 5.0e-3
#define TOL   1e-12

/* 12.36 names the operation and gives it no number, so the value is VerA's
 * (specification/Vague_Decisions.md) and a host compiled against vpi_user.h depends on
 * it staying put. */
_Static_assert(vpiRejectTransientStep == 730, "VerA's vpiRejectTransientStep is 730");

static int rejections, backed_up, accepted_after_reject, awaiting_backup;
static double rejected_t = -1.0;

static PLI_INT32 on_convergence(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  (void)cb;

  if (awaiting_backup) {
    P03_CHECK(t < rejected_t - TOL,
              "12.36: after rejecting t=%.17g the engine attempted t=%.17g, "
              "which is not an earlier time", rejected_t, t);
    P03_CHECK(accepted_after_reject == 0,
              "8.4.7: %d solutions were accepted between the rejection at t=%.17g "
              "and the backup", accepted_after_reject, rejected_t);
    backed_up = 1;
    awaiting_backup = 0;
  }

  if (rejections == 0 && t >= 2.0e-3) {
    P03_CHECK(vpi_sim_control(vpiRejectTransientStep, vpi_get_analog_delta()) == 1,
              "12.36: vpiRejectTransientStep failed on a solution awaiting acceptance");
    p03_no_error("vpiRejectTransientStep on an open step");
    rejections++;
    rejected_t = t;
    awaiting_backup = 1;
  }
  return 0;   /* accept: the rejection is the routine's, not the return's */
}

static PLI_INT32 on_accepted(p_cb_data cb)
{
  (void)cb;
  if (awaiting_backup) accepted_after_reject++;
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(rejections == 1, "the plugin issued %d rejections, want 1", rejections);
  P03_CHECK(backed_up == 1, "12.36: the engine never backed up after the rejection");
  P03_NEAR(vpi_get_analog_time(), TSTOP, 1e-15, "acbFinalStep time after a rejection");
  printf("p03-12: rejected=%d backed_up=%d t_final=%g\n", rejections, backed_up, TSTOP);
  fflush(stdout);
  return 0;
}

static void p03_12_after_compile(void)
{
  static s_cb_data cvg_cb, acc_cb, fin_cb;
  P03_CHECK(vpi_sim_control(vpiRejectTransientStep, 0.0) == 0,
            "12.36: vpiRejectTransientStep succeeded with no analysis running");
  p03_saw_error("vpiRejectTransientStep with no analysis running");
  cvg_cb.reason = acbConvergenceTest; cvg_cb.cb_rtn = on_convergence;
  acc_cb.reason = acbAcceptedPoint;   acc_cb.cb_rtn = on_accepted;
  fin_cb.reason = acbFinalStep;       fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&cvg_cb) != NULL, "acbConvergenceTest registration failed");
  P03_CHECK(vpi_register_cb(&acc_cb) != NULL, "acbAcceptedPoint registration failed");
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_12_startup(void)
{
  p03_defer(p03_12_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_12_startup, 0 };
