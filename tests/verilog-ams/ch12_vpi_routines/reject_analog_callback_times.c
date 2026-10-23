/* P03 REJECT — VAMS-2023 12.31.3: an analog time callback needs an analog
 * time.
 *
 *   12.31.3  "acbAbsTime  Upon acceptance of the analog solution for the given
 *             time (this callback shall force a solution at that time)
 *             acbElapsedTime  Upon acceptance of the solution advanced from the
 *             current solution by the given interval (this callback shall force
 *             a solution at that time)"
 *   12.31    vpi_register_cb() "shall register" the callback — and returns the
 *             handle, which an application checks against NULL.
 *   12.2     every failure is reported with a state, a code and a message.
 *
 * Both reasons are defined by "the given time": an analysis instant, which is
 * a real number of seconds (12.9 reports it as a `double`). A registration that
 * gives none, or gives one no analysis can reach, names no solution to force
 * and no acceptance to wait for, so it cannot be kept. FOUR such registrations,
 * each refused with NULL and an error:
 *
 *   acbAbsTime,     time = NULL                  no time at all
 *   acbAbsTime,     time->type = vpiSimTime      a digital tick count, not an
 *                                                analog instant in seconds
 *   acbAbsTime,     time->real = -1e-3           before every analysis starts
 *   acbElapsedTime, time->real = NaN             no interval
 *
 * THE CONTROL, without which "refuse everything" passes: a well-formed
 * acbAbsTime at 0.5e-3 is kept, fires exactly once, and fires at 0.5e-3 —
 * 12.31.3's "shall force a solution at that time" makes that exact equality
 * the clause's own number. (Forcing itself is p03_03's; this control pins
 * delivery, which is what a refusal must not also suppress.)
 *
 *! design   dc_divider.va
 *! analysis tran 0 1m
 */

//! lrm 12.31.3
//! lrm-reject 12.31.3
//! design dc_divider.va
//! stdout p03-92: control_hits=1 control_t=0.0005 refused=4 errs=4

#include <string.h>
#include "p03_vpi_analog.h"

static int control_hits, refused, errs;
static double control_t;

static PLI_INT32 control_cb(p_cb_data cb)
{
  (void)cb;
  control_hits++;
  control_t = vpi_get_analog_time();
  return 0;
}

static PLI_INT32 never_cb(p_cb_data cb)
{
  (void)cb;
  P03_FAIL("12.31.3: a refused registration was delivered anyway");
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(control_hits == 1, "12.31.3: the well-formed acbAbsTime fired %d times, want 1",
            control_hits);
  P03_CHECK(control_t == 0.5e-3, "12.31.3: it fired at %.17g, want the given time 5e-4",
            control_t);
  P03_CHECK(refused == 4, "12.31.3: %d of the 4 unkeepable registrations were refused", refused);
  P03_CHECK(errs == 4, "12.2: %d of the 4 refusals carried an error report", errs);
  printf("p03-92: control_hits=%d control_t=%g refused=%d errs=%d\n", control_hits, control_t,
         refused, errs);
  fflush(stdout);
  return 0;
}

static void try_bad(PLI_INT32 reason, p_vpi_time t, const char *what)
{
  s_cb_data d;
  memset(&d, 0, sizeof d);
  d.reason = reason;
  d.cb_rtn = never_cb;
  d.time = t;
  if (vpi_register_cb(&d) == NULL) refused++;
  errs += p03_saw_error(what);
}

static void p03_92_after_compile(void)
{
  static s_cb_data ok_cb, fin_cb;
  static s_vpi_time ok_t;
  s_vpi_time sim_t, neg_t, nan_t;

  ok_t.type = vpiScaledRealTime;
  ok_t.real = 0.5e-3;
  ok_cb.reason = acbAbsTime;
  ok_cb.cb_rtn = control_cb;
  ok_cb.time = &ok_t;
  P03_CHECK(vpi_register_cb(&ok_cb) != NULL, "12.31.3: a well-formed acbAbsTime was refused");
  p03_no_error("the control registration");

  try_bad(acbAbsTime, NULL, "acbAbsTime with no time");

  memset(&sim_t, 0, sizeof sim_t);
  sim_t.type = vpiSimTime;
  sim_t.low = 5;
  try_bad(acbAbsTime, &sim_t, "acbAbsTime with a vpiSimTime tick count");

  memset(&neg_t, 0, sizeof neg_t);
  neg_t.type = vpiScaledRealTime;
  neg_t.real = -1e-3;
  try_bad(acbAbsTime, &neg_t, "acbAbsTime before time zero");

  memset(&nan_t, 0, sizeof nan_t);
  nan_t.type = vpiScaledRealTime;
  nan_t.real = NAN;
  try_bad(acbElapsedTime, &nan_t, "acbElapsedTime with a NaN interval");

  fin_cb.reason = acbFinalStep;
  fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_92_startup(void)
{
  p03_defer(p03_92_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_92_startup, 0 };
