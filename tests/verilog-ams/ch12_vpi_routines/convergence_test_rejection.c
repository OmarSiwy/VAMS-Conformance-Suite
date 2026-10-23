/* P03 — VAMS-2023 12.31.3: acbConvergenceTest rejects a solution and the engine
 * backs up.
 *
 *   12.31.3  acbConvergenceTest  "Prior acceptance of the analog solution for
 *            the given time (this callback allows rejection of the analog
 *            solution at that time and backup to an earlier time)"
 *            acbAcceptedPoint    "Upon acceptance of the solution at the given
 *            time"
 *   8.4.7    "the analog engine can either accept or reject that solution; it
 *            cannot calculate a solution for a future time until it has
 *            accepted the solution for the current time."
 *
 * THE ONE DEGREE OF FREEDOM THE LRM LEAVES, stated here so it is a decision and
 * not a silent assumption: Figure 12-17 types cb_rtn as returning an int, and
 * 12.31.3 gives acbConvergenceTest the power to reject, but no clause spells the
 * encoding. This fixture FIXES it, matching every other callback in the
 * interface where 0 is the uneventful return: 0 accepts, non-zero rejects. An
 * implementation that chooses the opposite polarity fails this fixture, and
 * should change the fixture and say so — it must not leave the question open,
 * because an application cannot be written against an unspecified return.
 *
 * The plugin rejects exactly ONE solution: the first attempt at a time >= 2e-3.
 * Everything asserted is then forced by the clauses above:
 *
 *   - rejections issued == 1. The plugin counts its own returns, so this is
 *     exact by construction and the assertion is that the engine asked again
 *     rather than giving up.
 *   - after the rejection the next acbConvergenceTest arrives at a time
 *     STRICTLY LESS than the rejected one — 12.31.3's "backup to an earlier
 *     time". A host that merely re-attempts the same time has not backed up.
 *   - no acbAcceptedPoint ever carries the rejected time with the rejected
 *     attempt: 8.4.7 forbids accepting what was rejected. Since the run may
 *     later reach that same time on a shorter step and accept it, the exact
 *     assertion is the ordering one — no acbAcceptedPoint at all between the
 *     rejection and the following (earlier) convergence test.
 *   - every acbAcceptedPoint at time t is preceded by an acbConvergenceTest at
 *     the same t. "Prior acceptance" makes the test a precondition of the
 *     acceptance, not an independent stream.
 *   - the run still completes: acbFinalStep at t == 5e-3 exactly. A rejection
 *     the engine mishandles by stalling or by running past tstop is caught here
 *     and nowhere else.
 *
 *! design   ramp_load.va
 *! analysis tran 0 5m
 *! expect   05_convergence_test_rejection.expected.txt
 */

//! lrm 12.9
//! lrm 12.31.3
//! lrm 12.31.3:1
//! design ramp_load.va
//! stdout p03-05: rejected=1 backed_up=1 ct_before_ap=1 t_final=0.005

#include "p03_vpi_analog.h"

#define TSTOP 5.0e-3
#define TOL   1e-12

static int rejections, accepted_after_reject, ct_before_ap = 1, backed_up;
static double rejected_t = -1.0, last_ct_t = -1.0;
static int awaiting_backup;

static PLI_INT32 on_convergence(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  (void)cb;

  if (awaiting_backup) {
    /* 12.31.3: "backup to an earlier time". */
    P03_CHECK(t < rejected_t - TOL,
              "12.31.3: after rejecting t=%.17g the engine attempted t=%.17g, "
              "which is not an earlier time", rejected_t, t);
    P03_CHECK(accepted_after_reject == 0,
              "8.4.7: %d solutions were accepted between the rejection at t=%.17g "
              "and the backup", accepted_after_reject, rejected_t);
    backed_up = 1;
    awaiting_backup = 0;
  }

  last_ct_t = t;

  if (rejections == 0 && t >= 2.0e-3) {
    rejections++;
    rejected_t = t;
    awaiting_backup = 1;
    accepted_after_reject = 0;
    return 1;   /* non-zero: reject — see the banner */
  }
  return 0;     /* accept */
}

static PLI_INT32 on_accepted(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  (void)cb;
  if (awaiting_backup) accepted_after_reject++;
  /* "Prior acceptance": the test for THIS time must already have happened. */
  if (fabs(last_ct_t - t) > TOL) {
    ct_before_ap = 0;
    P03_FAIL("12.31.3: acbAcceptedPoint at t=%.17g without a preceding "
             "acbConvergenceTest at that time (last test was t=%.17g)", t, last_ct_t);
  }
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(rejections == 1, "the plugin issued %d rejections, want 1", rejections);
  P03_CHECK(backed_up == 1, "12.31.3: the engine never backed up after the rejection");
  P03_NEAR(vpi_get_analog_time(), TSTOP, 1e-15, "12.31.3 acbFinalStep time after a rejection");
  printf("p03-05: rejected=%d backed_up=%d ct_before_ap=%d t_final=%g\n",
         rejections, backed_up, ct_before_ap, TSTOP);
  fflush(stdout);
  return 0;
}

static void p03_05_after_compile(void)
{
  static s_cb_data cvg_cb, acc_cb, fin_cb;
  cvg_cb.reason = acbConvergenceTest; cvg_cb.cb_rtn = on_convergence;
  acc_cb.reason = acbAcceptedPoint;   acc_cb.cb_rtn = on_accepted;
  fin_cb.reason = acbFinalStep;       fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&cvg_cb) != NULL, "acbConvergenceTest registration failed");
  P03_CHECK(vpi_register_cb(&acc_cb) != NULL, "acbAcceptedPoint registration failed");
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_05_startup(void)
{
  p03_defer(p03_05_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_05_startup, 0 };
