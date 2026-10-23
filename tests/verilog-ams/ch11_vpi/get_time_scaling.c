/* 13 — vpi_get_time()'s three readings of one instant.
 *
 * LRM 12.15: "The VPI routine vpi_get_time() shall retrieve the current
 * simulation time, using the time scale of the object. If obj is NULL, the
 * simulation time is retrieved using the simulation time unit. The time_p->type
 * field shall be set to indicate if scaled real, analog, or simulation time is
 * desired. The memory for the time_p structure shall be allocated by the user."
 *
 * LRM 12.30, closing sentence, on the same structure: "For vpiScaledRealTime,
 * the indicated time shall be in the timescale associated with the object."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * scales.v defines p02_scales_top under `timescale 1ns/1ps and
 * p02_scales_sub under `timescale 1us/1ps. The finest precision in the design
 * is 1 ps, so the simulation time unit is 1 ps. The top module's `#3` is three
 * of ITS units, i.e. 3 ns, which is 3000 simulation time units.
 *
 * At that instant, by hand:
 *
 *   vpi_get_time(NULL, {vpiSimTime})
 *       = 3 ns expressed in the 1 ps simulation time unit
 *       = 3000 ticks            -> high = 0, low = 3000
 *
 *   vpi_get_time(p02_scales_top, {vpiScaledRealTime})
 *       = 3 ns / 1 ns  = 3.0    exactly representable; asserted with ==
 *
 *   vpi_get_time(p02_scales_sub, {vpiScaledRealTime})
 *       = 3 ns / 1 us = 0.003   NOT exactly representable in binary64, and the
 *                               route from 3000 ticks to it is a division the
 *                               implementation may perform more than one way,
 *                               so this one is asserted to within 1e-12 — far
 *                               tighter than the 1000x error a wrong scale
 *                               would produce, and far looser than the last
 *                               few ulps of one division.
 *
 *   vpi_get_time(NULL, {vpiScaledRealTime})
 *       = the simulation time unit again, as a real
 *       = 3000.0
 *
 * The 1000x separation between the two scaled readings is the whole point: a
 * tool that ignores the object and always uses the global unit answers 3000.0
 * three times, and a tool that always uses the top module answers 3.0 twice.
 *
 * The reading is taken from cbReadOnlySynch at simulation time 3000, and
 * p02_scales_top.tick — 0x00 before that queue and 0x01 after — is checked
 * first, so a callback that fired at the wrong instant is caught before it can
 * make a time assertion pass or fail for the wrong reason.
 */

//! lrm 12.2
//! lrm 12.15
//! lrm 12.16
//! lrm 12.21
//! lrm 12.31.2
//! lrm 12.33.2
//! lrm 12.15:1
//! design ../digital/scales.v
//! stdout p02: 13_get_time_scaling checks=15

#include "p02_check.h"

static double dabs(double x) { return x < 0.0 ? -x : x; }

static int read_clock(p_cb_data cb_data)
{
  s_vpi_time  t;
  s_vpi_value v;
  vpiHandle   top, sub;
  (void)cb_data;

  top = p02_by_name("p02_scales_top");
  sub = p02_by_name("p02_scales_top.u");

  v.format = vpiIntVal;
  vpi_get_value(p02_by_name("p02_scales_top.tick"), &v);
  CHECK(v.value.integer == 0x01,
        "cbReadOnlySynch(3000) is after the t=3ns queue, so tick must be 0x01");

  t.type = vpiSimTime;
  t.high = 0xDEAD; t.low = 0xBEEF;      /* poisoned, must be overwritten */
  vpi_get_time(NULL, &t);
  expect_no_error("vpi_get_time(NULL, vpiSimTime)");
  CHECK(t.high == 0 && t.low == 3000,
        "3 ns in a 1 ps simulation time unit is 3000 ticks, got high=%u low=%u",
        (unsigned)t.high, (unsigned)t.low);

  t.type = vpiScaledRealTime;
  t.real = -1.0;
  vpi_get_time(top, &t);
  expect_no_error("vpi_get_time(top, vpiScaledRealTime)");
  CHECK(t.real == 3.0,
        "3 ns scaled to p02_scales_top's 1 ns unit is exactly 3.0, got %.17g",
        t.real);

  t.type = vpiScaledRealTime;
  t.real = -1.0;
  vpi_get_time(sub, &t);
  expect_no_error("vpi_get_time(sub, vpiScaledRealTime)");
  CHECK(dabs(t.real - 0.003) <= 1e-12,
        "3 ns scaled to p02_scales_sub's 1 us unit is 0.003, got %.17g", t.real);

  t.type = vpiScaledRealTime;
  t.real = -1.0;
  vpi_get_time(NULL, &t);
  CHECK(t.real == 3000.0,
        "a NULL object means the simulation time unit, so 3000.0, got %.17g",
        t.real);

  p02_done("13_get_time_scaling");
  return 0;
}

static void setup_after_compile(void)
{
  static s_vpi_time t = { vpiSimTime, 0, 3000, 0.0 };
  static s_cb_data  cb;

  cb.reason = cbReadOnlySynch;
  cb.cb_rtn = read_clock;
  cb.obj = NULL; cb.time = &t; cb.value = NULL;
  cb.index = 0; cb.user_data = NULL;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadOnlySynch(3000) registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
