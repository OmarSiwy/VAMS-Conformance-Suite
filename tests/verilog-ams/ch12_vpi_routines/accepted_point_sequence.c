/* P03 — VAMS-2023 12.31.3: the shape of the acbAcceptedPoint sequence, and the
 * identity that ties it to 12.7's delta.
 *
 *   12.31.3  acbInitialStep     "Upon acceptance of the first analog solution"
 *            acbFinalStep       "Upon acceptance of the last analog solution"
 *            acbAcceptedPoint   "Upon acceptance of the solution at the given
 *                                time"
 *   12.7     vpi_get_analog_delta() "returns the elapsed time between the
 *            latest converged and accepted solution and the solution being
 *            calculated".
 *   8.4.7    "the analog engine can either accept or reject that solution; it
 *            cannot calculate a solution for a future time until it has
 *            accepted the solution for the current time."
 *
 * WHAT IS AND IS NOT DERIVABLE. The NUMBER of accepted points in a transient is
 * the step controller's business and no clause fixes it, so this fixture never
 * asserts a count of accepted points. Everything it does assert is forced by
 * the text above for any conforming engine:
 *
 *   - acbInitialStep fires exactly ONCE, and before any acbAcceptedPoint:
 *     "the first analog solution" is singular and precedes the rest.
 *   - acbFinalStep fires exactly ONCE, after every acbAcceptedPoint: "the last
 *     analog solution".
 *   - accepted times are STRICTLY INCREASING. 8.4.7 forbids advancing before
 *     accepting, so two accepted points cannot share a time and cannot go
 *     backwards.
 *   - at every accepted point after the first, vpi_get_analog_delta() equals
 *     that point's time minus the previous ACCEPTED point's time. This is
 *     12.7 read literally, and it is the assertion that separates a correct
 *     implementation from the common bug: reporting the last ATTEMPTED step
 *     size, which differs from this by exactly the rejected trials.
 *   - the last accepted point is at t = tstop = 5e-3 exactly. A `.tran 0 5m`
 *     that stopped at 4.87e-3 has not produced "the last analog solution" of
 *     the requested interval; the engine must land on the endpoint.
 *
 * The 5e-3 endpoint and the delta identity are the hand-derived numbers. Both
 * are exact: 5e-3 is the deck's own stop time, and the delta identity is a
 * subtraction of two doubles the engine itself produced.
 *
 *! design   ramp_load.va
 *! analysis tran 0 5m
 *! expect   02_accepted_point_sequence.expected.txt
 */

//! lrm 12.7
//! lrm 12.9
//! lrm 12.31.3
//! lrm 12.7:1
//! lrm 12.7:1001
//! lrm 12.9:1
//! lrm 12.31.3:1
//! design ramp_load.va
//! stdout p03-02: initial=1 final=1 t_final=0.005 monotone=1 delta_ok=1

#include "p03_vpi_analog.h"

#define TSTOP 5.0e-3

static int initial_count, final_count, accepted_count;
static int monotone = 1, delta_ok = 1;
static double prev_t = -1.0, last_t = -1.0;

static PLI_INT32 at_initial(p_cb_data cb)
{
  (void)cb;
  initial_count++;
  P03_CHECK(accepted_count == 0,
            "12.31.3: acbInitialStep arrived after %d accepted points", accepted_count);
  /* The first analog solution of a transient started at 0 is the t=0 one. */
  P03_NEAR(vpi_get_analog_time(), 0.0, 0.0, "12.31.3 acbInitialStep time");
  prev_t = 0.0;
  last_t = 0.0;
  return 0;
}

static PLI_INT32 at_accepted(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  double dt = vpi_get_analog_delta();
  (void)cb;
  accepted_count++;
  P03_CHECK(initial_count == 1,
            "12.31.3: an accepted point arrived before acbInitialStep");
  P03_CHECK(final_count == 0,
            "12.31.3: an accepted point arrived after acbFinalStep at t=%.17g", t);
  if (!(t > prev_t)) {
    monotone = 0;
    P03_FAIL("8.4.7: accepted times must strictly increase, got %.17g after %.17g", t, prev_t);
  }
  /* 12.7, read literally. The tolerance is one ulp of the times involved, not a
   * slack: both sides are differences of numbers the engine already holds. */
  if (fabs(dt - (t - prev_t)) > 1e-15 * (fabs(t) + 1e-30)) {
    delta_ok = 0;
    P03_FAIL("12.7: delta at t=%.17g is %.17g, but t - t_prev is %.17g", t, dt, t - prev_t);
  }
  prev_t = t;
  last_t = t;
  return 0;
}

static PLI_INT32 at_final(p_cb_data cb)
{
  (void)cb;
  final_count++;
  P03_CHECK(initial_count == 1, "12.31.3: acbInitialStep fired %d times, want 1", initial_count);
  P03_CHECK(final_count == 1, "12.31.3: acbFinalStep fired %d times, want 1", final_count);
  P03_CHECK(accepted_count > 0, "the run produced no accepted points at all");
  /* acbFinalStep is delivered on "the last analog solution", which for a
   * `.tran 0 5m` is the solution at t = 5e-3. */
  P03_NEAR(vpi_get_analog_time(), TSTOP, 1e-15, "12.31.3 acbFinalStep time");
  P03_NEAR(last_t, TSTOP, 1e-15, "last acbAcceptedPoint time");
  printf("p03-02: initial=%d final=%d t_final=%g monotone=%d delta_ok=%d\n",
         initial_count, final_count, TSTOP, monotone, delta_ok);
  fflush(stdout);
  return 0;
}

static void p03_02_after_compile(void)
{
  static s_cb_data icb, acb, fcb;
  icb.reason = acbInitialStep;   icb.cb_rtn = at_initial;
  acb.reason = acbAcceptedPoint; acb.cb_rtn = at_accepted;
  fcb.reason = acbFinalStep;     fcb.cb_rtn = at_final;
  P03_CHECK(vpi_register_cb(&icb) != NULL, "acbInitialStep registration failed");
  P03_CHECK(vpi_register_cb(&acb) != NULL, "acbAcceptedPoint registration failed");
  P03_CHECK(vpi_register_cb(&fcb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_02_startup(void)
{
  p03_defer(p03_02_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_02_startup, 0 };
