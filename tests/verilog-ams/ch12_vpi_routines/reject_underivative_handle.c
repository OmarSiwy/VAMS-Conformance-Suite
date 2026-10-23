/* P03 REJECT — VAMS-2023 12.22.1: a derivative the derivtf phase never declared
 * is not reachable.
 *
 *   12.22.1  "For vpiDerivative, the vpi_handle_multi() function can only be
 *            called for those derivatives allocated during the derivtf phase of
 *            execution."
 *   12.32.2  "The purpose of this function is declarative only, it does not
 *            assign any value to the derivative being declared."
 *   12.2     the failure has to be REPORTABLE: vpi_chk_error() names the level,
 *            the state, a code and a message.
 *
 * WHY A REFUSAL IS THE CORRECT BEHAVIOUR AND NOT AN INCONVENIENCE. The
 * declaration made in derivtf is what tells the solver which Jacobian entries
 * this system task will contribute to; an entry that was never declared has no
 * storage and, more importantly, no column reserved in the matrix. Handing back
 * a handle for it would let calltf write a partial derivative into nowhere and
 * the solver would converge — to the wrong answer, silently, with a Jacobian
 * that is missing a term the application believes it supplied. So the only safe
 * answer is NULL plus 12.2's error, which is what this fixture asserts.
 *
 * $resistor here declares EXACTLY ONE partial, count = 1, derivative_of = {1},
 * derivative_wrt = {2} — 12.22.2's own declaration. The three probes are:
 *
 *   vpi_handle_multi(vpiDerivative, arg1, arg2)  -> non-NULL   (declared)
 *   vpi_handle_multi(vpiDerivative, arg2, arg3)  -> NULL + err (not declared)
 *   vpi_handle_multi(vpiDerivative, arg1, arg3)  -> NULL + err (not declared:
 *                                                    d(curr)/dr is a real
 *                                                    derivative mathematically,
 *                                                    which is the point — the
 *                                                    rule is about what derivtf
 *                                                    ALLOCATED, not about what
 *                                                    exists)
 *
 * and the fourth is the one that separates a refusal from a crash:
 * vpi_put_value() on the NULL that came back must fail and report, not
 * dereference. An application that does not check vpi_handle_multi()'s result is
 * exactly the application this rule protects.
 *
 *! design   systf_devices.va
 *! analysis op
 *! expect   90_reject_underivative_handle.expected.txt
 */

//! lrm 12.2
//! lrm 12.22.1
//! lrm-reject 12.22.1
//! lrm 12.22.1:1001
//! lrm-reject 12.22.1:1001
//! lrm-reject 12.30
//! design systf_devices.va
//! stdout p03-90: declared=1 undeclared=0 undeclared_wrt_param=0 put_null=0 errs=3 vres=1

#include "p03_vpi_analog.h"

static PLI_INT32 res_of[]  = { 1 };
static PLI_INT32 res_wrt[] = { 2 };
static PLI_INT32 cub_of[]  = { 1 };
static PLI_INT32 cub_wrt[] = { 2 };

static int declared_ok, undeclared_2_3, undeclared_1_3, put_null_ret, errs;

static p_vpi_stf_partials resistor_derivtf(p_cb_data cb)
{
  static s_vpi_stf_partials d;
  (void)cb;
  d.count = 1; d.derivative_of = res_of; d.derivative_wrt = res_wrt;
  return &d;
}

static p_vpi_stf_partials cube_derivtf(p_cb_data cb)
{
  static s_vpi_stf_partials d;
  (void)cb;
  d.count = 1; d.derivative_of = cub_of; d.derivative_wrt = cub_wrt;
  return &d;
}

static PLI_INT32 resistor_calltf(p_cb_data cb)
{
  vpiHandle f, a1, a2, a3, h;
  s_vpi_value value;
  double g, v;
  (void)cb;

  f  = vpi_handle(vpiSysTfCall, NULL);
  a1 = vpi_handle_by_index(f, 1);
  a2 = vpi_handle_by_index(f, 2);
  a3 = vpi_handle_by_index(f, 3);
  P03_CHECK(a1 && a2 && a3, "12.22.2: $resistor needs three arguments");

  if (!declared_ok) {
    /* The one derivtf allocated. */
    h = vpi_handle_multi(vpiDerivative, a1, a2);
    P03_CHECK(h != NULL, "12.22.1: the DECLARED derivative must be reachable");
    p03_no_error("vpi_handle_multi on a declared derivative");
    declared_ok = 1;

    /* Not allocated: d(arg2)/d(arg3). */
    h = vpi_handle_multi(vpiDerivative, a2, a3);
    P03_CHECK(h == NULL,
              "12.22.1: vpi_handle_multi returned a handle for a derivative "
              "derivtf never allocated (of=2, wrt=3)");
    errs += p03_saw_error("vpi_handle_multi(vpiDerivative, arg2, arg3)");
    undeclared_2_3 = 1;

    /* Not allocated either, though mathematically real: d(curr)/dr. */
    h = vpi_handle_multi(vpiDerivative, a1, a3);
    P03_CHECK(h == NULL,
              "12.22.1: vpi_handle_multi returned a handle for d(arg1)/d(arg3), "
              "which derivtf did not allocate");
    errs += p03_saw_error("vpi_handle_multi(vpiDerivative, arg1, arg3)");
    undeclared_1_3 = 1;

    /* The unchecked-application case: 12.30 must refuse, not dereference. */
    value.format = vpiRealVal;
    value.value.real = 1.0;
    put_null_ret = (vpi_put_value(NULL, &value, NULL, vpiNoDelay) == NULL);
    P03_CHECK(put_null_ret, "12.30: vpi_put_value on a null handle must fail");
    errs += p03_saw_error("vpi_put_value(NULL, ...)");
  }

  /* Still compute the device, so the analysis reaches its solution and the
   * refusals above are shown not to have broken the run. */
  h = vpi_handle_multi(vpiDerivative, a1, a2);
  value.format = vpiRealVal;
  vpi_get_value(a3, &value);
  g = 1.0 / value.value.real;
  value.value.real = g;
  vpi_put_value(h, &value, NULL, vpiNoDelay);
  vpi_get_value(a2, &value);
  v = value.value.real;
  value.value.real = v * g;
  vpi_put_value(a1, &value, NULL, vpiNoDelay);
  return 0;
}

static PLI_INT32 cube_calltf(p_cb_data cb)
{
  vpiHandle f, a1, a2, h;
  s_vpi_value value;
  double u;
  (void)cb;
  f  = vpi_handle(vpiSysTfCall, NULL);
  a1 = vpi_handle_by_index(f, 1);
  a2 = vpi_handle_by_index(f, 2);
  h  = vpi_handle_multi(vpiDerivative, a1, a2);
  value.format = vpiRealVal;
  vpi_get_value(a2, &value);
  u = value.value.real + 1.0;
  value.value.real = 3.0 * u * u;
  vpi_put_value(h, &value, NULL, vpiNoDelay);
  value.value.real = u * u * u - 1.0;
  vpi_put_value(a1, &value, NULL, vpiNoDelay);
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  vpiHandle vres = p03_quantity("p03_systf_devices.r1", vpiPotential);
  (void)cb;
  P03_CHECK(declared_ok && undeclared_2_3 && undeclared_1_3 && put_null_ret,
            "not every probe ran (declared=%d u23=%d u13=%d put_null=%d)",
            declared_ok, undeclared_2_3, undeclared_1_3, put_null_ret);
  P03_CHECK(errs == 3, "12.2: %d of the 3 refusals reported an error", errs);
  /* The refusals did not poison the solve: 12.22.2's own answer still stands. */
  P03_NEAR(p03_real_of(vres, NULL), 1.0, 1e-12,
           "the analysis still converged after three refused requests");
  printf("p03-90: declared=1 undeclared=0 undeclared_wrt_param=0 put_null=0 errs=%d vres=%g\n",
         errs, 1.0);
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

static void p03_90_startup(void)
{
  static s_vpi_analog_systf_data res_systf, cub_systf;

  res_systf.type = vpiAnalogSysTask;  res_systf.sysfunctype = 0;
  res_systf.tfname = (PLI_BYTE8 *)"$resistor";
  res_systf.calltf = resistor_calltf; res_systf.compiletf = 0;
  res_systf.sizetf = 0; res_systf.derivtf = resistor_derivtf; res_systf.user_data = 0;
  P03_CHECK(vpi_register_analog_systf(&res_systf) != NULL, "registering $resistor failed");

  cub_systf.type = vpiAnalogSysTask;  cub_systf.sysfunctype = 0;
  cub_systf.tfname = (PLI_BYTE8 *)"$cube";
  cub_systf.calltf = cube_calltf;     cub_systf.compiletf = 0;
  cub_systf.sizetf = 0; cub_systf.derivtf = cube_derivtf; cub_systf.user_data = 0;
  P03_CHECK(vpi_register_analog_systf(&cub_systf) != NULL, "registering $cube failed");

  /* IEEE 1364-2005 26.2.4: acbFinalStep waits for cbEndOfCompile. */
  p03_defer(register_final);
}

void (*vlog_startup_routines[])(void) = { p03_90_startup, 0 };
