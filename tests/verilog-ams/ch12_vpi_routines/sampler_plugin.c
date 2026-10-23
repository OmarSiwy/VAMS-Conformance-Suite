/* P03 — VAMS-2023 12.32.3's sample-and-hold, as a working plugin.
 *
 *   12.32   "The VPI routine vpi_register_analog_systf() shall register
 *           callbacks for user-defined analog system tasks or functions."
 *   12.32.3 "The following example illustrates the declaration and use of
 *           callbacks in an analog function $sampler() which implements a
 *           sample and hold."
 *   12.31.3 acbAbsTime "Upon acceptance of the analog solution for the given
 *           time (this callback shall force a solution at that time)".
 *   12.9    vpi_get_analog_time() is "the time of the solution attempted".
 *
 * This is 12.32.3's own listing made to compile and made to assert. The clause's
 * code does not build as printed — it calls a `vpi_set_value()` that no clause
 * defines, spells vpiScaledRealTime as `vpiScaledTme`, dereferences
 * `cb_data.time.real` against Figure 12-17's POINTER, reads `periodHandle` and
 * `sampler` before either is assigned, and registers an analog function through
 * `s_vpi_systf_data` rather than 12.32's own `s_vpi_analog_systf_data`. The
 * STRUCTURE is the clause's and is reproduced exactly: compiletf validates the
 * two arguments, a cbEndOfCompile callback builds the per-call instance data and
 * reads the constant period, an acbAbsTime chain re-arms itself one period
 * ahead, and calltf returns whatever the last capture held.
 *
 * THE HAND DERIVATION. V(in) is p03_ramp_in at 1000 V/s, so V(in) = 1000*t
 * exactly. period = 1e-3. The chain therefore captures at t = 0, 1e-3, 2e-3,
 * 3e-3, 4e-3, 5e-3 and the k-th capture takes the value
 *
 *     V(in)(k*1e-3) = 1000 * k * 1e-3 = k volts.
 *
 * Expected captures, in order: 0, 1, 2, 3, 4, 5 — SIX of them over a 0..5e-3
 * run, because acbAbsTime forces a solution at 5e-3 and that is the last
 * accepted solution rather than one past the end.
 *
 * The HOLD is checked from outside the sampler, at two forced probe points that
 * are not capture instants:
 *
 *     t = 2.50e-3 lies in [2e-3, 3e-3) -> V(out) == 2 exactly
 *     t = 4.25e-3 lies in [4e-3, 5e-3) -> V(out) == 4 exactly
 *
 * Those two are the assertions a sampler that merely tracked its input would
 * fail: a pass-through gives 2.5 and 4.25, a one-step-late tracker gives
 * something between. 4.25e-3 is deliberately not a midpoint, so an
 * implementation that rounds probe times to the nearest capture cannot land on
 * it by accident.
 *
 *! design   sampnhold.va
 *! analysis tran 0 5m
 *! expect   06_sampler_plugin.expected.txt
 */

//! lrm 12.9
//! lrm 12.16
//! lrm 12.30
//! lrm 12.31.3
//! lrm 12.32
//! lrm 12.32.2
//! lrm 12.32.3
//! lrm 12.20
//! lrm 12.20:1
//! lrm 12.32:1
//! lrm 12.32.1
//! lrm 12.32.1:9
//! lrm 12.32.1:1002
//! design sampnhold.va
//! stdout p03-06: samples=6 first=0 last=5 hold_2p5=2 hold_4p25=4

#include "p03_vpi_analog.h"

#define PERIOD 1.0e-3
#define TSTOP  5.0e-3
#define TOL    1e-12

/* 12.32.3's own s_sampler_data, minus the fields its listing never uses. */
typedef struct {
  vpiHandle  returnHandle;   /* arg #0: the returned value */
  vpiHandle  exprHandle;     /* arg #1: the sampled expression */
  vpiHandle  periodHandle;   /* arg #2: the period */
  double     period;
  double     held;
  s_cb_data  cb_data;
  s_vpi_time cb_time;
} s_sampler_data, *p_sampler_data;

static s_sampler_data sampler;

static int    captures;
static int    compiletf_calls, calltf_calls;
static double captured[16];
static double hold_2p5 = -1.0, hold_4p25 = -1.0;
static vpiHandle vout;

/* 12.32.3's sampler_update_cb: hold the expression value, then re-arm one
 * period ahead. The clause re-arms with acbAbsTime at
 * `vpi_get_analog_time() + period`, which is what is done here — the absolute
 * spelling keeps the capture grid from drifting with the step controller. */
static PLI_INT32 sampler_update_cb(p_cb_data data)
{
  p_sampler_data s = (p_sampler_data)data->user_data;
  s_vpi_value value;
  double t = vpi_get_analog_time();
  double want = 1000.0 * t;

  value.format = vpiRealVal;
  vpi_get_value(s->exprHandle, &value);
  p03_no_error("vpi_get_value on the sampled expression");
  s->held = value.value.real;

  P03_CHECK(captures < 16, "more captures than a 5 ms run at 1 ms can produce");
  captured[captures++] = s->held;
  P03_NEAR(t, PERIOD * (double)(captures - 1), TOL, "12.31.3 capture instant");
  P03_NEAR(s->held, want, TOL, "V(in) at the capture instant");

  if (t + s->period <= TSTOP + TOL) {
    s->cb_time.type = vpiScaledRealTime;
    s->cb_time.real = t + s->period;
    s->cb_data.reason    = acbAbsTime;
    s->cb_data.cb_rtn    = sampler_update_cb;
    s->cb_data.time      = &s->cb_time;
    s->cb_data.user_data = (PLI_BYTE8 *)s;
    P03_CHECK(vpi_register_cb(&s->cb_data) != NULL, "re-arming the capture failed");
  }
  return 0;
}

/* 12.32.3's sampler_calltf: "Set returned value to held value". */
static PLI_INT32 sampler_calltf(p_cb_data cb)
{
  s_vpi_value value;
  (void)cb;
  calltf_calls++;
  /* 12.32.1: the analog calltf has the digital calltf's usage — it runs at
   * every invocation, and only after the one compiletf built the call. */
  P03_CHECK(compiletf_calls == 1,
            "12.32.1: calltf ran with %d compiletf calls, want the one call site's", compiletf_calls);
  value.format     = vpiRealVal;
  value.value.real = sampler.held;
  vpi_put_value(sampler.returnHandle, &value, NULL, vpiNoDelay);
  p03_no_error("vpi_put_value on the $sampler return value");
  return 0;
}

/* 12.32.3's sampler_compiletf, with its argument checks. */
static PLI_INT32 sampler_compiletf(p_cb_data cb)
{
  vpiHandle f, e, p;
  (void)cb;
  compiletf_calls++;
  /* 12.32.1: compiletf's usage is the digital compiletf's: once for the one
   * call site, at compile, before any calltf. */
  P03_CHECK(compiletf_calls == 1,
            "12.32.1: compiletf ran %d times for one call site", compiletf_calls);
  P03_CHECK(calltf_calls == 0,
            "12.32.1: compiletf ran after %d calltf calls", calltf_calls);
  f = vpi_handle(vpiSysTfCall, NULL);
  P03_CHECK(f != NULL, "12.32.3: no vpiSysTfCall context in compiletf");
  e = vpi_handle_by_index(f, 1);
  P03_CHECK(e != NULL, "12.32.3: `Not enough arguments for $sampler function.`");
  p = vpi_handle_by_index(f, 2);
  P03_CHECK(p != NULL, "12.32.3: $sampler needs a period argument");
  sampler.returnHandle = vpi_handle_by_index(f, 0);
  P03_CHECK(sampler.returnHandle != NULL, "12.32.2: argument 0 is the returned value");
  sampler.exprHandle   = e;
  sampler.periodHandle = p;
  return 0;
}

/* 12.32.3's sampler_postcompile_cb, reduced to what it actually needs: read the
 * constant period and arm the chain at t = 0. */
static PLI_INT32 sampler_postcompile_cb(p_cb_data data)
{
  s_vpi_value value;
  (void)data;
  value.format = vpiRealVal;
  vpi_get_value(sampler.periodHandle, &value);
  p03_no_error("vpi_get_value on the $sampler period argument");
  sampler.period = value.value.real;
  P03_NEAR(sampler.period, PERIOD, 0.0, "the period argument reaches the plugin");

  sampler.cb_time.type = vpiScaledRealTime;
  sampler.cb_time.real = 0.0;
  sampler.cb_data.reason    = acbAbsTime;
  sampler.cb_data.cb_rtn    = sampler_update_cb;
  sampler.cb_data.time      = &sampler.cb_time;
  sampler.cb_data.user_data = (PLI_BYTE8 *)&sampler;
  P03_CHECK(vpi_register_cb(&sampler.cb_data) != NULL, "arming the first capture failed");
  return 0;
}

/* The two hold probes, outside the sampler. */
static PLI_INT32 probe_cb(p_cb_data data)
{
  double t = vpi_get_analog_time();
  if (vout == NULL) vout = p03_quantity("p03_sampnhold_tb.load", vpiPotential);
  if (data->user_data == NULL) {
    P03_NEAR(t, 2.5e-3, TOL, "hold probe time");
    hold_2p5 = p03_real_of(vout, NULL);
    P03_NEAR(hold_2p5, 2.0, 1e-9, "V(out) held across [2e-3, 3e-3)");
  } else {
    P03_NEAR(t, 4.25e-3, TOL, "hold probe time");
    hold_4p25 = p03_real_of(vout, NULL);
    P03_NEAR(hold_4p25, 4.0, 1e-9, "V(out) held across [4e-3, 5e-3)");
  }
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  int k;
  (void)cb;
  P03_CHECK(captures == 6, "12.31.3: %d captures over 0..5e-3 at 1e-3, want 6", captures);
  for (k = 0; k < captures; k++)
    P03_NEAR(captured[k], (double)k, TOL, "capture value");
  printf("p03-06: samples=%d first=%g last=%g hold_2p5=%g hold_4p25=%g\n",
         captures, captured[0], captured[captures - 1], hold_2p5, hold_4p25);
  fflush(stdout);
  return 0;
}

static void register_probes(void)
{
  static s_cb_data fin_cb, probe_a, probe_b;
  static s_vpi_time probe_a_t, probe_b_t;

  probe_a_t.type = vpiScaledRealTime; probe_a_t.real = 2.5e-3;
  probe_a.reason = acbAbsTime; probe_a.cb_rtn = probe_cb;
  probe_a.time = &probe_a_t; probe_a.user_data = (PLI_BYTE8 *)0;
  P03_CHECK(vpi_register_cb(&probe_a) != NULL, "probe A registration failed");

  probe_b_t.type = vpiScaledRealTime; probe_b_t.real = 4.25e-3;
  probe_b.reason = acbAbsTime; probe_b.cb_rtn = probe_cb;
  probe_b.time = &probe_b_t; probe_b.user_data = (PLI_BYTE8 *)1;
  P03_CHECK(vpi_register_cb(&probe_b) != NULL, "probe B registration failed");

  fin_cb.reason = acbFinalStep; fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

static void p03_06_startup(void)
{
  static s_vpi_analog_systf_data systf;
  static s_cb_data post_cb;

  /* Figure 12-18. 12.32's own field order; $sampler is a FUNCTION returning a
   * real, so type is vpiAnalogSysFunc and sysfunctype is vpiRealFunc. */
  systf.type        = vpiAnalogSysFunc;
  systf.sysfunctype = vpiRealFunc;
  systf.tfname      = (PLI_BYTE8 *)"$sampler";
  systf.calltf      = sampler_calltf;
  systf.compiletf   = sampler_compiletf;
  systf.sizetf      = 0;
  systf.derivtf     = 0;    /* a held value has no derivative w.r.t. its input */
  systf.user_data   = 0;
  P03_CHECK(vpi_register_analog_systf(&systf) != NULL,
            "12.32: registering $sampler failed");

  post_cb.reason = cbEndOfCompile; post_cb.cb_rtn = sampler_postcompile_cb;
  P03_CHECK(vpi_register_cb(&post_cb) != NULL, "cbEndOfCompile registration failed");

  /* IEEE 1364-2005 26.2.4: the analog callbacks wait for cbEndOfCompile. */
  p03_defer(register_probes);
}

void (*vlog_startup_routines[])(void) = { p03_06_startup, 0 };
