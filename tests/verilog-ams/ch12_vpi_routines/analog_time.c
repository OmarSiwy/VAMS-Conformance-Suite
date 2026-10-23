/* b7 vpiAnalogTime: VAMS-2023 12.15, the analog time type of vpi_get_time().
 *
 * 12.15  "The time_p->type field shall be set to indicate if scaled real,
 *        analog, or simulation time is desired." Figure 12-8: "int type;
 *        for vpiScaledRealTime, vpiSimTime, vpiAnalogTime".
 * 12.31.3 acbAbsTime "Upon acceptance of the analog solution for the given
 *        time (this callback shall force a solution at that time)".
 *
 * DERIVATION. The analysis is this banner's `tran 0 5m` over ramp_load.va.
 * acbAbsTime at 2.5e-3 s forces a solution at 2.5e-3 and calls back on its
 * acceptance, so the analog time then is 2.5e-3 s. vpi_get_time(NULL, ...)
 * with type vpiAnalogTime returns it, in seconds, in the structure's one
 * real field, with no error. The tolerance, 1e-15 absolute (4e-13 relative),
 * is the solver's last bits only; p03_03 pins the forced time the same way.
 * The routine is asked once.
 *
 *! design   ramp_load.va
 *! analysis tran 0 5m
 */

//! lrm 12.15:2
//! design ramp_load.va
//! stdout b7-analog-time: t=0.0025

#include "p03_vpi_analog.h"

#ifndef vpiAnalogTime

static void b7_startup(void)
{
  P03_FAIL("12.15: src/vpi/vpi_user.h defines no vpiAnalogTime, the analog time_p->type 12.15 names");
}

#else

#define T_ABS 2.5e-3

static int hits;

static PLI_INT32 on_abs(p_cb_data cb)
{
  s_vpi_time t;
  (void)cb;
  hits++;
  t.type = vpiAnalogTime;
  t.high = 0;
  t.low = 0;
  t.real = -1.0;
  vpi_get_time(NULL, &t);
  p03_no_error("vpi_get_time(NULL, vpiAnalogTime)");
  P03_NEAR(t.real, T_ABS, 1e-15, "12.15: vpiAnalogTime at the forced 2.5e-3 s solution");
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(hits == 1, "12.31.3: acbAbsTime at 2.5e-3 fired %d times, want 1", hits);
  printf("b7-analog-time: t=%g\n", T_ABS);
  fflush(stdout);
  return 0;
}

static void b7_after_compile(void)
{
  static s_vpi_time t;
  static s_cb_data abs_cb, fin_cb;
  t.type = vpiScaledRealTime;
  t.real = T_ABS;
  abs_cb.reason = acbAbsTime;
  abs_cb.cb_rtn = on_abs;
  abs_cb.time = &t;
  P03_CHECK(vpi_register_cb(&abs_cb) != NULL, "acbAbsTime registration failed");
  fin_cb.reason = acbFinalStep;
  fin_cb.cb_rtn = on_final;
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
