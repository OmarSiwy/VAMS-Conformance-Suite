/* P03 — VAMS-2023 12.7, 12.8, 12.9: the three no-argument analog queries, at
 * the one point where the standard fixes all three of their values.
 *
 *   12.7  "The VPI routine vpi_get_analog_delta() ... returns the elapsed time
 *          between the latest converged and accepted solution and the solution
 *          being calculated. The function shall return zero (0) during DC or
 *          the time zero transient solution."
 *   12.8  "The VPI routine vpi_get_analog_freq() shall be used determine the
 *          current frequency used in the small-signal analysis. The function
 *          shall return zero (0) during DC or transient analysis."
 *   12.9  "The VPI routine vpi_get_analog_time() shall be used determine the
 *          time of the solution attempted or of the latest converged and
 *          accepted solution otherwise. The function shall return zero (0)
 *          during DC or the time zero transient solution."
 *
 * 12.31.3 names acbInitialStep as the callback delivered "Upon acceptance of
 * the first analog solution". For a transient run started at 0 that solution IS
 * the time zero transient solution, so all three clauses above apply at once
 * and every expected value is a literal zero fixed by the text — no arithmetic,
 * no solver dependence, no tolerance needed beyond exact equality.
 *
 * The negative half matters as much: a plausible wrong implementation returns
 * the FIRST step size from vpi_get_analog_delta() at t = 0 (there is no previous
 * accepted solution to subtract, so the natural bug is to report h), or reports
 * a stale frequency left over from a previous AC analysis. Both are caught here.
 *
 * The fixture also pins the one thing 12.9 says about the rest of the run and
 * that a zero-only test would miss: at a LATER accepted point the routine
 * reports that point's time, not zero — so the zeros above are a property of
 * t = 0 rather than of an unimplemented routine that returns zero always. The
 * second accepted point of any run has t > 0, and delta > 0 there, which is
 * solver-independent.
 *
 *! design   dc_divider.va
 *! analysis tran 0 1m
 *! expect   01_time_delta_freq_at_zero.expected.txt
 */

//! lrm 12.7
//! lrm 12.8
//! lrm 12.9
//! lrm 12.31.3
//! lrm 12.7:2
//! lrm 12.8:2
//! lrm 12.9:2
//! design dc_divider.va
//! stdout p03-01: t0=0 dt0=0 f0=0 initial=1 final=1 later_pos=1

#include "p03_vpi_analog.h"

static int initial_count, final_count, later_count;
static double later_time, later_delta;

static PLI_INT32 at_initial(p_cb_data cb)
{
  (void)cb;
  initial_count++;
  /* Exact equality, not a tolerance: the clauses say "zero (0)". */
  P03_CHECK(vpi_get_analog_time() == 0.0,
            "12.9: analog time at the time zero transient solution must be 0, got %.17g",
            vpi_get_analog_time());
  P03_CHECK(vpi_get_analog_delta() == 0.0,
            "12.7: analog delta at the time zero transient solution must be 0, got %.17g",
            vpi_get_analog_delta());
  P03_CHECK(vpi_get_analog_freq() == 0.0,
            "12.8: analog freq during transient analysis must be 0, got %.17g",
            vpi_get_analog_freq());
  p03_no_error("the three analog queries at t=0");
  return 0;
}

static PLI_INT32 at_accepted(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  (void)cb;
  /* 12.8 again: the whole transient, not just its first point. */
  P03_CHECK(vpi_get_analog_freq() == 0.0,
            "12.8: analog freq stays 0 through a transient, got %.17g at t=%.17g",
            vpi_get_analog_freq(), t);
  if (t > 0.0 && later_count == 0) {
    later_count = 1;
    later_time = t;
    later_delta = vpi_get_analog_delta();
  }
  return 0;
}

static PLI_INT32 at_final(p_cb_data cb)
{
  (void)cb;
  final_count++;
  P03_CHECK(initial_count == 1, "12.31.3: acbInitialStep must fire exactly once, got %d",
            initial_count);
  /* The first accepted point after t = 0 exists in any transient that runs at
   * all, and 12.9/12.7 make both of these strictly positive there. */
  P03_CHECK(later_count == 1, "no accepted point after t=0: the run did not advance");
  P03_CHECK(later_time > 0.0, "12.9: a later accepted point must report its own time, got %.17g",
            later_time);
  P03_CHECK(later_delta > 0.0, "12.7: delta at a later accepted point must be > 0, got %.17g",
            later_delta);
  printf("p03-01: t0=%g dt0=%g f0=%g initial=%d final=%d later_pos=%d\n",
         0.0, 0.0, 0.0, initial_count, final_count, 1);
  fflush(stdout);
  return 0;
}

static void p03_01_after_compile(void)
{
  static s_cb_data initial_cb, accepted_cb, final_cb;

  initial_cb.reason = acbInitialStep;
  initial_cb.cb_rtn = at_initial;
  P03_CHECK(vpi_register_cb(&initial_cb) != NULL, "12.31: acbInitialStep registration failed");

  accepted_cb.reason = acbAcceptedPoint;
  accepted_cb.cb_rtn = at_accepted;
  P03_CHECK(vpi_register_cb(&accepted_cb) != NULL, "12.31: acbAcceptedPoint registration failed");

  final_cb.reason = acbFinalStep;
  final_cb.cb_rtn = at_final;
  P03_CHECK(vpi_register_cb(&final_cb) != NULL, "12.31: acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_01_startup(void)
{
  p03_defer(p03_01_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_01_startup, 0 };
