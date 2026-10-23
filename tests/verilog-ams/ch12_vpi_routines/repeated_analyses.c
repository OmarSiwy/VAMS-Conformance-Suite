/* P03 — VAMS-2023 12.31.3 across MORE THAN ONE analysis in one simulator run.
 *
 *   12.31.3  acbInitialStep "Upon acceptance of the first analog solution";
 *            acbFinalStep   "Upon acceptance of the last analog solution";
 *            acbAbsTime     "shall force a solution at that time".
 *   12.33.2  vlog_startup_routines runs "just after the simulator is invoked" —
 *            ONCE, not once per analysis, and so does the cbEndOfCompile it
 *            registers (IEEE 1364-2005 26.2.4), where this plugin arms its
 *            callbacks. Everything armed there has to survive, or not
 *            survive, the analysis boundary on its own terms.
 *
 * "First" and "last" are relative to an ANALYSIS, not to the process: two
 * transients in one run are two first solutions and two last ones. That is the
 * only reading under which a plugin can do anything useful at the start of the
 * second analysis, and it is the one this fixture pins:
 *
 *     acbInitialStep fires exactly 2 times
 *     acbFinalStep   fires exactly 2 times
 *
 * with the TIME BASE RESTARTING at each, which is the observable that
 * distinguishes two analyses from one long one:
 *
 *     at every acbInitialStep: t == 0        and V(out) == 1000*0   == 0
 *     at every acbFinalStep:   t == 2e-3     and V(out) == 1000*2e-3 == 2
 *
 * (p03_ramp_load solves to V(out) = 1000*t exactly; see its header.) A host
 * that carried the clock across the boundary reports t == 2e-3 at the second
 * acbInitialStep and V(out) == 2 there, and fails on the first check it reaches.
 *
 * THE THIRD ASSERTION is the one an application actually depends on and that a
 * count-only test would miss: a callback registered BETWEEN analyses — from
 * inside the first analysis's acbFinalStep, when no analysis is running — must
 * be armed for the next one. An acbAbsTime at 1.5e-3 registered there must fire
 * exactly once, in the second transient, at exactly 1.5e-3, where
 * V(out) == 1.5. Exactly once and not twice, because the first transient is
 * already over when it is armed; and not zero, because the second transient
 * covers 1.5e-3.
 *
 *! design   ramp_load.va
 *! analysis tran 0 2m
 *! analysis tran 0 2m
 *! expect   10_repeated_analyses.expected.txt
 */

//! lrm 12.9
//! lrm 12.31.3
//! design ramp_load.va
//! stdout p03-10: initial=2 final=2 t0=0 v_final=2 late_t=0.0015 late_v=1.5 late_hits=1

#include "p03_vpi_analog.h"

#define TSTOP 2.0e-3
#define T_LATE 1.5e-3
#define TOL   1e-12

static int initial_hits, final_hits, late_hits;
static double late_t = -1.0, late_v = -1.0, final_v = -1.0;
static s_cb_data late_cb;
static s_vpi_time late_time;
static vpiHandle vout;

static vpiHandle out_quantity(void)
{
  if (vout == NULL) vout = p03_quantity("p03_ramp_load.load", vpiPotential);
  return vout;
}

static PLI_INT32 on_initial(p_cb_data cb)
{
  (void)cb;
  initial_hits++;
  P03_NEAR(vpi_get_analog_time(), 0.0, 0.0,
           "12.31.3: each analysis's first analog solution is at t = 0");
  P03_NEAR(p03_real_of(out_quantity(), NULL), 0.0, 1e-12,
           "V(out) at the start of each transient");
  P03_CHECK(initial_hits <= 2, "acbInitialStep fired %d times, want 2", initial_hits);
  return 0;
}

static PLI_INT32 on_late(p_cb_data cb)
{
  (void)cb;
  late_hits++;
  late_t = vpi_get_analog_time();
  late_v = p03_real_of(out_quantity(), NULL);
  P03_NEAR(late_t, T_LATE, TOL, "12.31.3 acbAbsTime armed between analyses");
  P03_NEAR(late_v, 1000.0 * T_LATE, 1e-9, "V(out) at the between-analyses probe");
  P03_CHECK(initial_hits == 2,
            "the between-analyses callback fired during analysis %d, want the second",
            initial_hits);
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  final_hits++;
  P03_NEAR(vpi_get_analog_time(), TSTOP, 1e-15,
           "12.31.3: each analysis's last analog solution is at tstop");
  final_v = p03_real_of(out_quantity(), NULL);
  P03_NEAR(final_v, 1000.0 * TSTOP, 1e-9, "V(out) at the end of each transient");

  if (final_hits == 1) {
    /* No analysis is running at this instant; the registration is for the next. */
    late_time.type = vpiScaledRealTime;
    late_time.real = T_LATE;
    late_cb.reason = acbAbsTime;
    late_cb.cb_rtn = on_late;
    late_cb.time   = &late_time;
    P03_CHECK(vpi_register_cb(&late_cb) != NULL,
              "12.31: registering a callback between analyses failed");
    P03_CHECK(late_hits == 0, "the between-analyses callback fired before it was armed");
  } else if (final_hits == 2) {
    P03_CHECK(initial_hits == 2, "acbInitialStep fired %d times, want 2", initial_hits);
    P03_CHECK(late_hits == 1,
              "12.31.3: the acbAbsTime armed between analyses fired %d times, want 1",
              late_hits);
    printf("p03-10: initial=%d final=%d t0=%g v_final=%g late_t=%g late_v=%g late_hits=%d\n",
           initial_hits, final_hits, 0.0, final_v, late_t, late_v, late_hits);
    fflush(stdout);
  } else {
    P03_FAIL("12.31.3: acbFinalStep fired %d times, want 2", final_hits);
  }
  return 0;
}

static void p03_10_after_compile(void)
{
  static s_cb_data icb, fcb;
  icb.reason = acbInitialStep; icb.cb_rtn = on_initial;
  fcb.reason = acbFinalStep;   fcb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&icb) != NULL, "acbInitialStep registration failed");
  P03_CHECK(vpi_register_cb(&fcb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_10_startup(void)
{
  p03_defer(p03_10_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_10_startup, 0 };
