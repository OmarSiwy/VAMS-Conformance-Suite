/* P03 — VAMS-2023 12.34: removing a callback from inside a callback.
 *
 *   12.34  "The VPI routine vpi_remove_cb() shall remove callbacks which were
 *          registered with vpi_register_cb(). The argument to this routine
 *          shall be a handle to the callback object. The routine shall return a
 *          1 (TRUE) if successful, and a 0 (FALSE) on a failure. After
 *          vpi_remove_cb() is called with a handle to the callback, the handle
 *          is no longer valid."
 *   12.31.3  acbConvergenceTest is delivered "Prior acceptance of the analog
 *          solution for the given time"; acbAcceptedPoint "Upon acceptance of
 *          the solution at the given time"; acbAbsTime "shall force a solution
 *          at that time".
 *
 * Three removals, each with an exact expected count, and none of them depending
 * on an ordering the LRM does not fix:
 *
 *  1. REMOVING A FUTURE CALLBACK. Four acbAbsTime callbacks are armed at
 *     1e-3, 2e-3, 3e-3 and 4e-3. An acbAcceptedPoint routine removes the 3e-3
 *     one when it is dispatched at exactly 2e-3. 3e-3 is strictly later, so no
 *     same-instant ordering question arises: the expected counts are
 *
 *         at 1e-3: 1    at 2e-3: 1    at 3e-3: 0    at 4e-3: 1
 *
 *     The zero is the assertion; the three ones are what stops a host from
 *     passing it by dropping every forced point.
 *
 *  2. REMOVING ONESELF DURING ONE'S OWN DISPATCH. The 4e-3 callback calls
 *     vpi_remove_cb() on its own handle and then runs to its `return`. 12.34
 *     invalidates the HANDLE, not the frame, so the routine must complete and
 *     the return value must be 1. Expected: fires exactly once, removal returns
 *     1. A host that frees the callback record underneath the running routine
 *     crashes here, which is the bug this check exists for.
 *
 *  3. REMOVING A CALLBACK FOR THE SAME INSTANT. 12.31.3 ORDERS these two
 *     reasons at one time — "prior acceptance" strictly precedes "upon
 *     acceptance" — so an acbConvergenceTest routine that removes an
 *     acbAcceptedPoint callback at time t suppresses it AT t as well as after.
 *     This is the one same-instant ordering claim the clause actually supports,
 *     and the expected value is exact: after the removal at the first attempt
 *     with t >= 2e-3, the removed routine's largest observed time is strictly
 *     less than that t.
 *
 *! design   ramp_load.va
 *! analysis tran 0 5m
 *! expect   04_remove_cb_during_dispatch.expected.txt
 */

//! lrm 12.9
//! lrm 12.31.3
//! lrm 12.34
//! design ramp_load.va
//! stdout p03-04: at1=1 at2=1 at3=0 at4=1 rm_future=1 rm_self=1 rm_same=1

#include "p03_vpi_analog.h"

#define TOL 1e-12

static s_vpi_time at_time[4];
static s_cb_data  at_cb[4];
static vpiHandle  at_h[4];
static int        at_hits[4];

static vpiHandle victim_h;          /* the acbAcceptedPoint removed at the same instant */
static int rm_future_ret, rm_self_ret, rm_same_ret;
static double rm_same_t = -1.0, victim_last_t = -1.0;

static PLI_INT32 on_abs(p_cb_data cb)
{
  int k = (int)(size_t)cb->user_data;
  double want = 1.0e-3 * (double)(k + 1);
  at_hits[k]++;
  P03_NEAR(vpi_get_analog_time(), want, TOL, "12.31.3 acbAbsTime forced time");
  if (k == 3) {
    /* Case 2: self-removal during dispatch. */
    rm_self_ret = vpi_remove_cb(at_h[3]);
    P03_CHECK(rm_self_ret == 1, "12.34: removing a callback from itself returned %d, want 1",
              rm_self_ret);
    p03_no_error("vpi_remove_cb on the running callback");
  }
  return 0;
}

/* The remover: case 1. */
static PLI_INT32 on_accepted_remover(p_cb_data cb)
{
  (void)cb;
  if (fabs(vpi_get_analog_time() - 2.0e-3) <= TOL && rm_future_ret == 0) {
    rm_future_ret = vpi_remove_cb(at_h[2]);
    P03_CHECK(rm_future_ret == 1, "12.34: removing a future callback returned %d, want 1",
              rm_future_ret);
    p03_no_error("vpi_remove_cb on a pending acbAbsTime");
  }
  return 0;
}

/* The victim: case 3. */
static PLI_INT32 on_accepted_victim(p_cb_data cb)
{
  (void)cb;
  victim_last_t = vpi_get_analog_time();
  return 0;
}

static PLI_INT32 on_convergence(p_cb_data cb)
{
  double t = vpi_get_analog_time();
  (void)cb;
  if (t >= 2.0e-3 && rm_same_ret == 0) {
    rm_same_t = t;
    rm_same_ret = vpi_remove_cb(victim_h);
    P03_CHECK(rm_same_ret == 1, "12.34: removing a same-instant callback returned %d, want 1",
              rm_same_ret);
  }
  return 0;   /* 0 = accept this solution; see 05_convergence_test_rejection.c */
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(at_hits[0] == 1, "acbAbsTime@1e-3 fired %d times, want 1", at_hits[0]);
  P03_CHECK(at_hits[1] == 1, "acbAbsTime@2e-3 fired %d times, want 1", at_hits[1]);
  P03_CHECK(at_hits[2] == 0, "12.34: acbAbsTime@3e-3 was removed but fired %d times",
            at_hits[2]);
  P03_CHECK(at_hits[3] == 1, "acbAbsTime@4e-3 fired %d times, want 1", at_hits[3]);
  P03_CHECK(rm_future_ret == 1 && rm_self_ret == 1 && rm_same_ret == 1,
            "12.34: a removal reported failure (future=%d self=%d same=%d)",
            rm_future_ret, rm_self_ret, rm_same_ret);
  P03_CHECK(rm_same_t > 0.0, "no convergence test at or after 2e-3: nothing was removed");
  /* 12.31.3's "prior acceptance" ordering: the victim cannot have been
   * delivered at the instant its removal was requested, nor after it. */
  P03_CHECK(victim_last_t < rm_same_t - TOL,
            "12.31.3/12.34: the removed acbAcceptedPoint ran at t=%.17g, "
            "after its removal during the convergence test at t=%.17g",
            victim_last_t, rm_same_t);
  printf("p03-04: at1=%d at2=%d at3=%d at4=%d rm_future=%d rm_self=%d rm_same=%d\n",
         at_hits[0], at_hits[1], at_hits[2], at_hits[3],
         rm_future_ret, rm_self_ret, rm_same_ret);
  fflush(stdout);
  return 0;
}

static void p03_04_after_compile(void)
{
  static s_cb_data rem_cb, vic_cb, cvg_cb, fin_cb;
  int k;

  for (k = 0; k < 4; k++) {
    at_time[k].type = vpiScaledRealTime;
    at_time[k].real = 1.0e-3 * (double)(k + 1);
    at_cb[k].reason = acbAbsTime;
    at_cb[k].cb_rtn = on_abs;
    at_cb[k].time   = &at_time[k];
    at_cb[k].user_data = (PLI_BYTE8 *)(size_t)k;
    at_h[k] = vpi_register_cb(&at_cb[k]);
    P03_CHECK(at_h[k] != NULL, "acbAbsTime registration %d failed", k);
  }

  rem_cb.reason = acbAcceptedPoint; rem_cb.cb_rtn = on_accepted_remover;
  P03_CHECK(vpi_register_cb(&rem_cb) != NULL, "remover registration failed");

  vic_cb.reason = acbAcceptedPoint; vic_cb.cb_rtn = on_accepted_victim;
  victim_h = vpi_register_cb(&vic_cb);
  P03_CHECK(victim_h != NULL, "victim registration failed");

  cvg_cb.reason = acbConvergenceTest; cvg_cb.cb_rtn = on_convergence;
  P03_CHECK(vpi_register_cb(&cvg_cb) != NULL, "acbConvergenceTest registration failed");

  fin_cb.reason = acbFinalStep; fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_04_startup(void)
{
  p03_defer(p03_04_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_04_startup, 0 };
