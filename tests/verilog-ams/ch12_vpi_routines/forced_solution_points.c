/* P03 — VAMS-2023 12.31.3: acbAbsTime and acbElapsedTime FORCE a solution.
 *
 *   12.31.3  acbAbsTime      "Upon acceptance of the analog solution for the
 *                             given time (this callback shall force a solution
 *                             at that time)"
 *            acbElapsedTime  "Upon acceptance of the solution advanced from the
 *                             current solution by the given interval (this
 *                             callback shall force a solution at that time)"
 *            acbAcceptedPoint "Upon acceptance of the solution at the given
 *                             time"
 *   12.9     vpi_get_analog_time() is "the time of the solution attempted or of
 *            the latest converged and accepted solution otherwise".
 *   12.10    vpi_get_analog_value() "shall retrieve the simulation value of VPI
 *            analog vpiFlow or vpiPotential (node or branch) quantity objects".
 *
 * WHY THIS IS THE LOAD-BEARING FIXTURE OF THE ROW. Everything else about a
 * transient's time points is the step controller's choice, so nothing else can
 * be asserted against a number. These two reasons are the exception: the clause
 * says the callback SHALL FORCE a solution at a time the application names, so
 * both the time and — for a circuit whose solution is a closed form of time —
 * the VALUE at that time are fixed by the standard.
 *
 * p03_ramp_load solves to V(out) = 1000*t exactly (see its header). So:
 *
 *   acbAbsTime      at t = 2.5e-3  ->  time == 2.5e-3, V(out) == 2.5 V
 *   acbElapsedTime  interval 1.5e-3 from t = 0
 *                                  ->  time == 1.5e-3, V(out) == 1.5 V
 *   re-armed once, interval 1.5e-3 from t = 1.5e-3
 *                                  ->  time == 3.0e-3, V(out) == 3.0 V
 *
 * 2.5e-3 is deliberately NOT a multiple of 1.5e-3 and neither is a round
 * fraction of the 5e-3 stop time, so no plausible natural step schedule lands on
 * these points by accident: an implementation that ignores the forcing misses
 * them and the fixture fails rather than passing for the wrong reason.
 *
 * The last assertion closes the loop between the two reasons: a forced point is
 * still an ACCEPTED point, so a separately registered acbAcceptedPoint callback
 * must be delivered at each of 1.5e-3, 2.5e-3 and 3.0e-3. A host that
 * implemented forcing as a private side channel, invisible to acbAcceptedPoint,
 * would pass the first three checks and fail this one.
 *
 *! design   ramp_load.va
 *! analysis tran 0 5m
 *! expect   03_forced_solution_points.expected.txt
 */

//! lrm 12.9
//! lrm 12.10
//! lrm 12.31.3
//! lrm 12.9:1
//! lrm 12.10:1
//! lrm 12.31.3:1
//! design ramp_load.va
//! stdout p03-03: abs_t=0.0025 abs_v=2.5 el1=0.0015 v1=1.5 el2=0.003 v2=3 accepted=3

#include "p03_vpi_analog.h"

#define T_ABS  2.5e-3
#define T_EL1  1.5e-3
#define T_EL2  3.0e-3
#define TOL    1e-12

static vpiHandle vout;
static s_vpi_time abs_time, el_time;
static s_cb_data el_cb;

static int abs_hits, el_hits;
static int seen_accept_el1, seen_accept_abs, seen_accept_el2;
static double abs_v, el_v1, el_v2;

static PLI_INT32 on_abs_time(p_cb_data cb)
{
  (void)cb;
  abs_hits++;
  P03_NEAR(vpi_get_analog_time(), T_ABS, TOL, "12.31.3 acbAbsTime forced time");
  abs_v = p03_real_of(vout, NULL);
  P03_NEAR(abs_v, 1000.0 * T_ABS, TOL, "V(out) at the acbAbsTime point");
  return 0;
}

static PLI_INT32 on_elapsed(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  (void)cb;
  el_hits++;
  if (el_hits == 1) {
    P03_NEAR(t, T_EL1, TOL, "12.31.3 first acbElapsedTime forced time");
    el_v1 = p03_real_of(vout, NULL);
    P03_NEAR(el_v1, 1000.0 * T_EL1, TOL, "V(out) at the first acbElapsedTime point");
    /* 12.31.3 makes acbElapsedTime relative to "the current solution", so
     * re-arming from inside the callback at t = 1.5e-3 with the same 1.5e-3
     * interval lands on 3.0e-3 and not on 1.5e-3 again. That is the whole
     * difference between acbElapsedTime and acbAbsTime and it is asserted by
     * the expected time below. */
    P03_CHECK(vpi_register_cb(&el_cb) != NULL, "re-arming acbElapsedTime failed");
  } else if (el_hits == 2) {
    P03_NEAR(t, T_EL2, TOL, "12.31.3 second acbElapsedTime forced time");
    el_v2 = p03_real_of(vout, NULL);
    P03_NEAR(el_v2, 1000.0 * T_EL2, TOL, "V(out) at the second acbElapsedTime point");
  } else {
    P03_FAIL("12.31.3: acbElapsedTime fired %d times, want 2", el_hits);
  }
  return 0;
}

static PLI_INT32 on_accepted(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  (void)cb;
  if (fabs(t - T_EL1) <= TOL) seen_accept_el1 = 1;
  if (fabs(t - T_ABS) <= TOL) seen_accept_abs = 1;
  if (fabs(t - T_EL2) <= TOL) seen_accept_el2 = 1;
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(abs_hits == 1, "12.31.3: acbAbsTime fired %d times, want 1", abs_hits);
  P03_CHECK(el_hits == 2, "12.31.3: acbElapsedTime fired %d times, want 2", el_hits);
  P03_CHECK(seen_accept_el1 && seen_accept_abs && seen_accept_el2,
            "12.31.3: a forced solution is still an accepted point "
            "(el1=%d abs=%d el2=%d)", seen_accept_el1, seen_accept_abs, seen_accept_el2);
  printf("p03-03: abs_t=%g abs_v=%g el1=%g v1=%g el2=%g v2=%g accepted=%d\n",
         T_ABS, abs_v, T_EL1, el_v1, T_EL2, el_v2, 3);
  fflush(stdout);
  return 0;
}

static void p03_03_after_compile(void)
{
  static s_cb_data abs_cb, acc_cb, fin_cb;

  vout = p03_quantity("p03_ramp_load.load", vpiPotential);

  abs_time.type = vpiScaledRealTime;
  abs_time.real = T_ABS;
  abs_cb.reason = acbAbsTime;
  abs_cb.cb_rtn = on_abs_time;
  abs_cb.time   = &abs_time;
  P03_CHECK(vpi_register_cb(&abs_cb) != NULL, "acbAbsTime registration failed");

  /* An INTERVAL, not an absolute time: 12.31.3 advances "from the current
   * solution by the given interval", and the current solution at registration
   * is t = 0. */
  el_time.type = vpiScaledRealTime;
  el_time.real = T_EL1;
  el_cb.reason  = acbElapsedTime;
  el_cb.cb_rtn  = on_elapsed;
  el_cb.time    = &el_time;
  P03_CHECK(vpi_register_cb(&el_cb) != NULL, "acbElapsedTime registration failed");

  acc_cb.reason = acbAcceptedPoint; acc_cb.cb_rtn = on_accepted;
  fin_cb.reason = acbFinalStep;     fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&acc_cb) != NULL, "acbAcceptedPoint registration failed");
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_03_startup(void)
{
  p03_defer(p03_03_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_03_startup, 0 };
