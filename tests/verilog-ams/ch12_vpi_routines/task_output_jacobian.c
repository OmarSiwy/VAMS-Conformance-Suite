/* P03 — VAMS-2023 12.22.2/12.32.2/12.30: an analog system TASK's output
 * argument, and its declared partial, steer the solver to a node it has to
 * find.
 *
 *   12.22.2 "The following example illustrates the declaration and use of
 *           derivative handles in an analog task $resistor()": calltf puts
 *           the conductance on vpi_handle_multi(vpiDerivative, i_handle,
 *           v_handle) and the current on argument 1, which the next
 *           statement contributes.
 *   12.32.2 "Having declared a partial derivative using this function in the
 *           derivtf callback, values can then be contributed to the
 *           derivative using the vpi_put_value function in the calltf call
 *           back."
 *   12.30   "The routine can be applied to nets, regs, variables, memory
 *           words, system function calls, sequential UDPs, and schedule
 *           events." Argument 1 is a real variable; argument 2, V(q, gnd),
 *           is an access function, none of those.
 *
 * DERIVATION. cube_solve.va contributes I(q, gnd) <+ icube - 7 with
 * $p03_cube(icube, V(q, gnd)). calltf puts icube = (V + 1)^3 - 1 on argument
 * 1 and d(icube)/dV = 3 (V + 1)^2 on the derivative derivtf declared (of 1,
 * wrt 2). KCL at q is (V + 1)^3 = 8, so at acbFinalStep V(q, gnd) = 1 (Newton
 * stops within its tolerance: 1e-9 here), and the last partial put is
 * 3 * 2^2 = 12 (to 1e-6, the same tolerance through the square). Newton from
 * V = 0 needs the partial at every step (the design's header), so at least
 * two evaluations ran: calls >= 2. The node is not pinned, so a host that
 * drops the partial leaves V at 0 and fails the first check.
 *
 * THE REFUSAL. On its first call calltf also puts a value on argument 2, the
 * access function V(q, gnd): it must fail with 12.2's error, and the put on
 * argument 1 in the same call must not (the legal neighbour).
 *
 * stdout: "p03-95: v=1 dcube=12 refused=1".
 *
 *! design   cube_solve.va
 *! analysis op
 */

//! lrm 12.22.2
//! lrm 12.32.1:9
//! lrm 12.32.2
//! lrm 12.32.2:1000
//! lrm 12.30
//! lrm 12.30:1001
//! lrm-reject 12.30
//! design cube_solve.va
//! stdout p03-95: v=1 dcube=12 refused=1

#include "p03_vpi_analog.h"

static PLI_INT32 cube_of[]  = { 1 };
static PLI_INT32 cube_wrt[] = { 2 };

static int calls, refused;
static double last_g = -1.0;

static p_vpi_stf_partials cube_derivtf(p_cb_data cb)
{
  static s_vpi_stf_partials d;
  (void)cb;
  d.count = 1;
  d.derivative_of = cube_of;
  d.derivative_wrt = cube_wrt;
  return &d;
}

static PLI_INT32 cube_calltf(p_cb_data cb)
{
  vpiHandle f, a1, a2, didv;
  s_vpi_value value;
  double u;
  (void)cb;

  f  = vpi_handle(vpiSysTfCall, NULL);
  a1 = vpi_handle_by_index(f, 1);
  a2 = vpi_handle_by_index(f, 2);
  P03_CHECK(a1 && a2, "$p03_cube needs two arguments");
  didv = vpi_handle_multi(vpiDerivative, a1, a2);
  P03_CHECK(didv != NULL, "12.22.1: the derivative derivtf declared is unreachable");
  p03_no_error("vpi_handle_multi(vpiDerivative, arg1, arg2)");

  value.format = vpiRealVal;
  vpi_get_value(a2, &value);
  p03_no_error("vpi_get_value on argument 2");
  u = value.value.real + 1.0;

  if (calls == 0) {
    value.format = vpiRealVal;
    value.value.real = 0.5;
    vpi_put_value(a2, &value, NULL, vpiNoDelay);
    refused += p03_saw_error("vpi_put_value onto the access function V(q, gnd)");
  }

  value.format = vpiRealVal;
  value.value.real = 3.0 * u * u;
  vpi_put_value(didv, &value, NULL, vpiNoDelay);
  p03_no_error("vpi_put_value onto the derivative of argument 1");
  last_g = value.value.real;

  value.format = vpiRealVal;
  value.value.real = u * u * u - 1.0;
  vpi_put_value(a1, &value, NULL, vpiNoDelay);
  p03_no_error("vpi_put_value onto argument 1, a real variable");
  calls++;
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  double v;
  (void)cb;
  P03_CHECK(calls >= 2, "Newton from V = 0 evaluates $p03_cube more than once, calltf ran %d times", calls);
  v = p03_real_of(p03_quantity("p03_cube_solve", vpiPotential), NULL);
  P03_NEAR(v, 1.0, 1e-9, "V(q, gnd) where (V + 1)^3 = 8");
  P03_NEAR(last_g, 12.0, 1e-6, "the partial calltf put at the solution: 3 (1 + 1)^2");
  P03_CHECK(refused == 1, "12.30: the put onto V(q, gnd) was not refused");
  printf("p03-95: v=%g dcube=%g refused=%d\n", v, last_g, refused);
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

static void p03_95_startup(void)
{
  static s_vpi_analog_systf_data cube;
  cube.type = vpiAnalogSysTask;
  cube.sysfunctype = 0;
  cube.tfname = (PLI_BYTE8 *)"$p03_cube";
  cube.calltf = cube_calltf;
  cube.compiletf = 0;
  cube.sizetf = 0;
  cube.derivtf = cube_derivtf;
  cube.user_data = 0;
  P03_CHECK(vpi_register_analog_systf(&cube) != NULL, "registering $p03_cube failed");
  /* IEEE 1364-2005 26.2.4: acbFinalStep waits for cbEndOfCompile. */
  p03_defer(register_final);
}

void (*vlog_startup_routines[])(void) = { p03_95_startup, 0 };
