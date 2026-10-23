/* P03 — VAMS-2023 12.18: vpi_get_real() inside an analog function, where the
 * clause makes it available, reading the analysis the function runs in.
 *
 *   12.18  "The VPI routine vpi_get_real() shall return the value of object
 *          properties, for properties of type real. Note for object properties
 *          shown below, if the object is NULL, then the corresponding value
 *          shall be returned.
 *            vpiStartTime for beginning of transient analysis time
 *            vpiEndTime for end of transient analysis time
 *            vpiTransientMaxStep for maximum analog time step
 *            vpiStartFrequency for the start frequency of AC analysis
 *            vpiEndFrequency for the end frequency of AC analysis
 *          This function is available to analog tasks and functions only.
 *          Should an error occur, vpi_get_real() shall return vpiUndefined."
 *   12.32  calltf runs "each time the system task or function is invoked".
 *   12.30  a put on "system function calls" is its returned value.
 *
 * THE DERIVATION. The analysis is this banner's `tran 0 1m 1e-4`, so inside
 * $p03_env's calltf the three transient properties are that line's three
 * numbers, exactly:
 *
 *     vpiStartTime        = 0
 *     vpiEndTime          = 1e-3
 *     vpiTransientMaxStep = 1e-4
 *
 * No other number is asserted — the step count, the number of calltf calls —
 * because no clause fixes them; only that there was at least one call.
 *
 * TWO REFUSALS, inside the same calltf (so "available to analog tasks and
 * functions only" is satisfied and the refusal is about the INPUT):
 *
 *   vpiStartFrequency during a transient    -> vpiUndefined + error: "for the
 *                                              start frequency of AC analysis",
 *                                              and no AC analysis is running
 *   vpiStartTime asked of a non-NULL object -> vpiUndefined + error: the
 *                                              analysis properties are the
 *                                              NULL object's
 *
 * THE RETURN VALUE REACHES THE CIRCUIT. calltf puts 1.0 on the call (12.30);
 * env_probe.va contributes `V(b, gnd) <+ e`, so V(b) = 1.0 at every
 * accepted point, read back through 12.10 from top's unnamed (b, gnd) branch.
 *
 *! design   env_probe.va
 *! analysis tran 0 1m 1e-4
 */

//! lrm 12.18
//! lrm-reject 12.18
//! lrm 12.30
//! lrm 12.32
//! lrm 12.18:1
//! lrm 12.18:2
//! lrm 12.30:1
//! design env_probe.va
//! stdout p03-93: start=0 end=0.001 max_step=0.0001 refused_per_call=2 v_b=1

#include "p03_vpi_analog.h"

static int calls, refusals;
static double start_t = -1, end_t = -1, max_step = -1;

static PLI_INT32 env_calltf(p_cb_data cb)
{
  s_vpi_value v;
  vpiHandle call;
  double bad;
  (void)cb;
  calls++;
  start_t = vpi_get_real(vpiStartTime, NULL);
  end_t = vpi_get_real(vpiEndTime, NULL);
  max_step = vpi_get_real(vpiTransientMaxStep, NULL);
  p03_no_error("vpi_get_real of the three transient properties");

  bad = vpi_get_real(vpiStartFrequency, NULL);
  if (bad == (double)vpiUndefined && p03_saw_error("vpiStartFrequency during a transient")) refusals++;
  call = vpi_handle(vpiSysTfCall, NULL);
  bad = vpi_get_real(vpiStartTime, call);
  if (bad == (double)vpiUndefined && p03_saw_error("vpiStartTime asked of an object")) refusals++;

  v.format = vpiRealVal;
  v.value.real = 1.0;
  vpi_put_value(call, &v, NULL, vpiNoDelay);
  p03_no_error("vpi_put_value on the $p03_env call");
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  vpiHandle top, itr, br, q = NULL;
  double vb;
  (void)cb;
  P03_CHECK(calls > 0, "12.32: calltf never ran");
  P03_CHECK(start_t == 0.0, "12.18 vpiStartTime: got %.17g, want 0", start_t);
  P03_CHECK(end_t == 1e-3, "12.18 vpiEndTime: got %.17g, want 1e-3", end_t);
  P03_CHECK(max_step == 1e-4, "12.18 vpiTransientMaxStep: got %.17g, want 1e-4", max_step);
  P03_CHECK(refusals == 2 * calls, "12.18: %d refusals over %d calls, want 2 per call", refusals, calls);

  /* top's branches, in contribution order: (a, gnd), then (b, gnd). */
  top = vpi_handle_by_name((PLI_BYTE8 *)"p03_env_probe", NULL);
  itr = vpi_iterate(vpiBranchObj, top);
  P03_CHECK(itr != NULL, "11.6.6: the top module has no branches");
  while ((br = vpi_scan(itr)) != NULL) q = vpi_handle(vpiPotential, br);
  vb = p03_real_of(q, NULL);
  P03_CHECK(vb == 1.0, "12.30: the value calltf put reached V(b): got %.17g, want 1", vb);
  printf("p03-93: start=%g end=%g max_step=%g refused_per_call=%d v_b=%g\n", start_t, end_t,
         max_step, refusals / calls, vb);
  fflush(stdout);
  return 0;
}

static void register_final(void)
{
  static s_cb_data fin_cb;
  fin_cb.reason = acbFinalStep;
  fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

static void p03_93_startup(void)
{
  static s_vpi_analog_systf_data systf;

  systf.type = vpiAnalogSysFunc;
  systf.sysfunctype = vpiRealFunc;
  systf.tfname = (PLI_BYTE8 *)"$p03_env";
  systf.calltf = env_calltf;
  P03_CHECK(vpi_register_analog_systf(&systf) != NULL, "12.32: registering $p03_env failed");

  /* IEEE 1364-2005 26.2.4: acbFinalStep waits for cbEndOfCompile. */
  p03_defer(register_final);
}

void (*vlog_startup_routines[])(void) = { p03_93_startup, 0 };
