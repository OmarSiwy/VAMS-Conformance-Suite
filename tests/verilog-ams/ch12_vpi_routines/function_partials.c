/* P03 — VAMS-2023 12.22.1 / 12.32.2: a partial derivative an analog system
 * FUNCTION declares reaches the solver.
 *
 *   12.32.2 "Analog system tasks and functions require partial derivatives of
 *           the outputs (arguments for system tasks and the return value for
 *           system functions) ... The derivtf field ... returns a pointer to a
 *           t_vpi_stf_partials data structure containing the required
 *           information ... Having declared a partial derivative using this
 *           function in the derivtf callback, values can then be contributed
 *           to the derivative using the vpi_put_value function in the calltf
 *           call back."  derivative_of: "0 = returned value, 1 = 1st arg".
 *   12.22.1 vpi_handle_multi(vpiDerivative, ...) "can only be called for those
 *           derivatives allocated during the derivtf phase of execution."
 *
 * THE FUNCTION. $p03_sq(x, k) = k * x^2. derivtf declares exactly ONE partial,
 * d(returned value)/d(x) — (of 0, wrt 1). calltf puts k*x^2 on the call and
 * 2*k*x on that derivative.
 *
 * THE DERIVATION. square_law.va drives 3 A into q and draws $p03_sq(V(q),
 * 1.0) out of it, so at the solution V(q)^2 = 3:
 *
 *     V(q)                 = sqrt(3)
 *     d(returned)/d(x)     = 2 * sqrt(3)        (read back from the derivative)
 *
 * sqrt(3) is the discriminator: Newton moves V(q) only through the column the
 * declared partial fills. Drop the partial and the column is zero and the
 * analysis cannot leave the nodeset guess of 1 — 3.0 is not a value the
 * function takes there.
 *
 * TWO REFUSALS, inside calltf (the only phase handles exist, 12.32.2):
 *
 *   vpi_handle_multi(vpiDerivative, call, arg2)  -> NULL + error: d/dk was not
 *                                                  declared by derivtf (the
 *                                                  "can only be called for
 *                                                  those derivatives allocated"
 *                                                  sentence)
 *   vpi_handle_multi(vpiDerivative, call, call)  -> NULL + error: a partial is
 *                                                  "with respect to" an argument
 *
 *! design   square_law.va
 *! analysis op
 */

//! lrm 12.22
//! lrm 12.22.1
//! lrm 12.32.2
//! lrm-reject 12.22
//! lrm-reject 12.22.1
//! lrm-reject 12.32.2
//! lrm C.14
//! lrm-reject C.14
//! lrm 11.3.2
//! lrm 11.3.2:1000
//! lrm 12.22.1:1
//! lrm 12.32.2:1000
//! design square_law.va
//! stdout p03-94: v_q=1.732050808 dfdx=3.464101615 refused_per_call=2

#include "p03_vpi_analog.h"

static int calls, refusals;
static double last_deriv;
static PLI_INT32 of_0 = 0, wrt_1 = 1;
static s_vpi_stf_partials partials;

static p_vpi_stf_partials sq_derivtf(p_cb_data cb)
{
  (void)cb;
  partials.count = 1;
  partials.derivative_of = &of_0;
  partials.derivative_wrt = &wrt_1;
  return &partials;
}

static PLI_INT32 sq_calltf(p_cb_data cb)
{
  vpiHandle call, x_h, k_h, dfdx;
  s_vpi_value v;
  double x, k;
  (void)cb;
  calls++;
  call = vpi_handle(vpiSysTfCall, NULL);
  x_h = vpi_handle_by_index(call, 1);
  k_h = vpi_handle_by_index(call, 2);
  P03_CHECK(x_h != NULL && k_h != NULL, "12.20: $p03_sq's two arguments");
  v.format = vpiRealVal;
  vpi_get_value(x_h, &v);
  x = v.value.real;
  vpi_get_value(k_h, &v);
  k = v.value.real;
  p03_no_error("reading $p03_sq's arguments");

  dfdx = vpi_handle_multi(vpiDerivative, call, x_h);
  P03_CHECK(dfdx != NULL, "12.22.1: the declared d(returned)/d(arg 1) has no handle");
  p03_no_error("vpi_handle_multi on the declared partial");

  if (vpi_handle_multi(vpiDerivative, call, k_h) == NULL && p03_saw_error("an undeclared partial")) refusals++;
  if (vpi_handle_multi(vpiDerivative, call, call) == NULL && p03_saw_error("a partial with respect to the call")) refusals++;

  v.format = vpiRealVal;
  v.value.real = k * x * x;
  vpi_put_value(call, &v, NULL, vpiNoDelay);
  v.value.real = 2.0 * k * x;
  vpi_put_value(dfdx, &v, NULL, vpiNoDelay);
  p03_no_error("vpi_put_value on the call and its derivative");

  vpi_get_value(dfdx, &v);
  last_deriv = v.value.real;
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  vpiHandle top, itr, br, q = NULL;
  double vq, want = sqrt(3.0);
  (void)cb;
  top = vpi_handle_by_name((PLI_BYTE8 *)"p03_square_law", NULL);
  itr = vpi_iterate(vpiBranchObj, top);
  P03_CHECK(itr != NULL, "11.6.6: the top module has no branches");
  while ((br = vpi_scan(itr)) != NULL) q = vpi_handle(vpiPotential, br);
  vq = p03_real_of(q, NULL);
  P03_CHECK(calls > 0, "12.32: calltf never ran");
  P03_NEAR(vq, want, 1e-9, "12.32.2: V(q) solved through the declared partial");
  P03_NEAR(last_deriv, 2.0 * want, 1e-8, "12.22.1: the derivative reads back 2*sqrt(3)");
  P03_CHECK(refusals == 2 * calls, "12.22.1: %d refusals over %d calls, want 2 per call", refusals, calls);
  printf("p03-94: v_q=%.9f dfdx=%.9f refused_per_call=%d\n", vq, last_deriv, refusals / calls);
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

static void p03_94_startup(void)
{
  static s_vpi_analog_systf_data systf;
  systf.type = vpiAnalogSysFunc;
  systf.sysfunctype = vpiRealFunc;
  systf.tfname = (PLI_BYTE8 *)"$p03_sq";
  systf.calltf = sq_calltf;
  systf.derivtf = sq_derivtf;
  P03_CHECK(vpi_register_analog_systf(&systf) != NULL, "12.32: registering $p03_sq failed");
  /* IEEE 1364-2005 26.2.4: acbFinalStep waits for cbEndOfCompile. */
  p03_defer(register_final);
}

void (*vlog_startup_routines[])(void) = { p03_94_startup, 0 };
