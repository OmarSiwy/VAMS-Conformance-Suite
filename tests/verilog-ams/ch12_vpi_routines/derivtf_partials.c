/* P03 — VAMS-2023 12.22.1/12.22.2/12.32.2: a declared partial derivative
 * reaches the solver's Jacobian.
 *
 *   12.32.2 "Analog system tasks and functions require partial derivatives of
 *           the outputs ... The derivtf field of the t_vpi_analog_systf_data
 *           structure can be called during the build process (similar to
 *           sizetf) and returns a pointer to a t_vpi_stf_partials data
 *           structure containing the required information. The purpose of this
 *           function is declarative only, it does not assign any value to the
 *           derivative being declared. Having declared a partial derivative
 *           using this function in the derivtf callback, values can then be
 *           contributed to the derivative using the vpi_put_value function in
 *           the calltf call back."
 *   12.22.1 "vpi_handle_multi(vpiDerivative, argHandle2, argHandle3) indicates
 *           the partial derivative of the returned value with respect to the
 *           third argument. For vpiDerivative, the vpi_handle_multi() function
 *           can only be called for those derivatives allocated during the
 *           derivtf phase of execution."
 *   12.22.2 is the $resistor() listing this file implements.
 *
 * TWO DEVICES, AND THE SECOND IS THE ONE THAT MATTERS.
 *
 * $resistor is 12.22.2's own, verbatim in behaviour: g = 1/r written to the
 * derivative object, curr = V*g written to argument 1. With r = 1 kohm and an
 * ideal 1 V source across it:
 *
 *     V(a, gnd) = 1        exactly
 *     curr      = 1e-3 A   exactly
 *     d(curr)/dV = 1e-3    exactly
 *
 * That pins the plumbing but CANNOT pin the propagation: the element is linear
 * and is pinned by an ideal source, so a host that discards the declared
 * partial still lands on the same answer. $cube exists to remove that escape.
 * It contributes
 *
 *     icube = (V + 1)^3 - 1,   d(icube)/dV = 3*(V + 1)^2
 *
 * driven by a 7 A injection, so KCL at q is (V+1)^3 = 8 and
 *
 *     V(q, gnd) = 1.0                exactly
 *     d(icube)/dV at the solution = 3*(1+1)^2 = 12.0 exactly
 *     branch current = 7 A           exactly (it is the source's own value)
 *
 * A host that leaves the $cube column of the Jacobian at zero has a singular
 * matrix and cannot converge at all; a host that uses a numerical difference
 * instead of the plugin's value converges to the same V but not to a derivative
 * that reads back as 12 through vpi_get_value on the derivative handle. Both
 * failures are caught.
 *
 * (V+1)^3 rather than V^3 because 3*V^2 is zero at the V = 0 cold start, which
 * would make the first Newton step singular for a reason that has nothing to do
 * with the VPI. Here the cold-start derivative is 3 and Newton on u^3 = 8 from
 * u = 1 runs 1, 3.333, 2.462, 2.081, 2.0031, 2.0000073, 2 — monotone.
 *
 * c1's flow is its OWN branch's. i1 (gnd, q) and c1 (q, gnd) are two
 * instances' unnamed branches over one node pair, which VerA stamps as ONE
 * residual row (the node equation only sees the sum); 11.6.7's flow of c1's
 * branch is c1's own contribution, which the device publishes beside the row
 * (`vpiShares`, one instance's share of a shared row). In the row's direction
 * (q, gnd), i1's share is -7 (its I(gnd,q) <+ 7, reversed) and c1's is
 * icube = 7, so the row sums to 0 and c1's flow reads 7, not 0.
 *
 * Expected stdout, from the values above printed with %g:
 *
 *   vres  = 1      V(a,gnd), the ideal source
 *   ires  = 0.001  1/1000 at 1 V
 *   dres  = 0.001  g = 1/r
 *   vcube = 1      (V+1)^3 = 8
 *   icube = 7      (1+1)^3 - 1
 *   dcube = 12     3*(1+1)^2
 *
 *   p03-07: vres=1 ires=0.001 dres=0.001 vcube=1 icube=7 dcube=12
 *
 *! design   systf_devices.va
 *! analysis op
 *! expect   07_derivtf_partials.expected.txt
 */

//! lrm 12.10:1
//! lrm 12.16
//! lrm 12.22
//! lrm 12.22.1
//! lrm 12.22.2
//! lrm 12.30
//! lrm 12.32
//! lrm 12.32.1
//! lrm 12.32.2
//! design systf_devices.va
//! stdout p03-07: vres=1 ires=0.001 dres=0.001 vcube=1 icube=7 dcube=12

#include "p03_vpi_analog.h"

static PLI_INT32 res_of[]  = { 1 };   /* d(argument 1) ... */
static PLI_INT32 res_wrt[] = { 2 };   /* ... with respect to argument 2 */
static PLI_INT32 cub_of[]  = { 1 };
static PLI_INT32 cub_wrt[] = { 2 };

static int res_calls, cub_calls;
static double last_res_g = -1.0, last_cub_g = -1.0;

/* 12.22.2's resistor_derivtf(), with the structure definition's member names. */
static p_vpi_stf_partials resistor_derivtf(p_cb_data cb)
{
  static s_vpi_stf_partials derivs;
  (void)cb;
  derivs.count          = 1;
  derivs.derivative_of  = res_of;
  derivs.derivative_wrt = res_wrt;
  return &derivs;
}

static p_vpi_stf_partials cube_derivtf(p_cb_data cb)
{
  static s_vpi_stf_partials derivs;
  (void)cb;
  derivs.count          = 1;
  derivs.derivative_of  = cub_of;
  derivs.derivative_wrt = cub_wrt;
  return &derivs;
}

/* 12.22.2's resistor_calltf(), unchanged in substance. */
static PLI_INT32 resistor_calltf(p_cb_data cb)
{
  vpiHandle f, i_h, v_h, r_h, didv_h;
  s_vpi_value value;
  double g, v;
  (void)cb;

  f   = vpi_handle(vpiSysTfCall, NULL);
  P03_CHECK(f != NULL, "12.32.3: no vpiSysTfCall context in calltf");
  i_h = vpi_handle_by_index(f, 1);
  v_h = vpi_handle_by_index(f, 2);
  r_h = vpi_handle_by_index(f, 3);
  P03_CHECK(i_h && v_h && r_h, "12.22.2: $resistor needs three arguments");

  didv_h = vpi_handle_multi(vpiDerivative, i_h, v_h);
  P03_CHECK(didv_h != NULL,
            "12.22.1: the derivative declared by derivtf must be reachable in calltf");
  p03_no_error("vpi_handle_multi(vpiDerivative, arg1, arg2)");

  value.format = vpiRealVal;
  vpi_get_value(r_h, &value);
  P03_NEAR(value.value.real, 1000.0, 0.0, "the r argument reaches calltf");
  g = 1.0 / value.value.real;

  value.value.real = g;
  vpi_put_value(didv_h, &value, NULL, vpiNoDelay);
  p03_no_error("vpi_put_value on a derivative object");

  /* 12.32.2 says derivtf is "declarative only" and calltf contributes the
   * value: so reading it straight back must give what was just written. */
  value.value.real = 0.0;
  vpi_get_value(didv_h, &value);
  P03_NEAR(value.value.real, g, 0.0, "a derivative object reads back what calltf put");
  last_res_g = value.value.real;

  value.format = vpiRealVal;
  vpi_get_value(v_h, &value);
  v = value.value.real;
  value.value.real = v * g;
  vpi_put_value(i_h, &value, NULL, vpiNoDelay);
  res_calls++;
  return 0;
}

static PLI_INT32 cube_calltf(p_cb_data cb)
{
  vpiHandle f, i_h, v_h, didv_h;
  s_vpi_value value;
  double v, u;
  (void)cb;

  f   = vpi_handle(vpiSysTfCall, NULL);
  i_h = vpi_handle_by_index(f, 1);
  v_h = vpi_handle_by_index(f, 2);
  P03_CHECK(i_h && v_h, "$cube needs two arguments");

  didv_h = vpi_handle_multi(vpiDerivative, i_h, v_h);
  P03_CHECK(didv_h != NULL, "12.22.1: $cube's declared derivative is unreachable");

  value.format = vpiRealVal;
  vpi_get_value(v_h, &value);
  v = value.value.real;
  u = v + 1.0;

  value.value.real = 3.0 * u * u;          /* d(icube)/dV */
  vpi_put_value(didv_h, &value, NULL, vpiNoDelay);
  last_cub_g = value.value.real;

  value.value.real = u * u * u - 1.0;      /* icube */
  vpi_put_value(i_h, &value, NULL, vpiNoDelay);
  cub_calls++;
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  vpiHandle vres, ires, vcub, icub;
  double vr, ir, vc, ic;
  (void)cb;

  P03_CHECK(res_calls > 0 && cub_calls > 0,
            "12.32: calltf was never invoked (resistor=%d cube=%d)", res_calls, cub_calls);

  vres = p03_quantity("p03_systf_devices.r1", vpiPotential);
  ires = p03_quantity("p03_systf_devices.r1", vpiFlow);
  vcub = p03_quantity("p03_systf_devices.c1", vpiPotential);
  icub = p03_quantity("p03_systf_devices.c1", vpiFlow);

  vr = p03_real_of(vres, NULL);
  ir = p03_real_of(ires, NULL);
  P03_NEAR(vr, 1.0,    1e-12, "V across the 12.22.2 $resistor");
  P03_NEAR(ir, 1.0e-3, 1e-15, "current through the 12.22.2 $resistor");
  P03_NEAR(last_res_g, 1.0e-3, 0.0, "d(curr)/dV handed to the solver");

  /* The discriminating pair, then c1's own flow (its share of the q row). */
  vc = p03_real_of(vcub, NULL);
  P03_NEAR(vc, 1.0, 1e-9,  "V at the $cube node: (V+1)^3 = 8");
  P03_NEAR(last_cub_g, 12.0, 1e-6,
           "d(icube)/dV at the converged point: 3*(1+1)^2");
  ic = p03_real_of(icub, NULL);
  P03_NEAR(ic, 7.0, 1e-9,  "current into the $cube node");

  printf("p03-07: vres=%g ires=%g dres=%g vcube=%g icube=%g dcube=%g\n",
         vr, ir, last_res_g, vc, ic, last_cub_g);
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

static void p03_07_startup(void)
{
  static s_vpi_analog_systf_data res_systf, cub_systf;

  /* 12.22.2's own registration structure, with 12.32.1's spelling of `type`. */
  res_systf.type        = vpiAnalogSysTask;
  res_systf.sysfunctype = 0;
  res_systf.tfname      = (PLI_BYTE8 *)"$resistor";
  res_systf.calltf      = resistor_calltf;
  res_systf.compiletf   = 0;
  res_systf.sizetf      = 0;
  res_systf.derivtf     = resistor_derivtf;
  res_systf.user_data   = 0;
  P03_CHECK(vpi_register_analog_systf(&res_systf) != NULL, "registering $resistor failed");

  cub_systf.type        = vpiAnalogSysTask;
  cub_systf.sysfunctype = 0;
  cub_systf.tfname      = (PLI_BYTE8 *)"$cube";
  cub_systf.calltf      = cube_calltf;
  cub_systf.compiletf   = 0;
  cub_systf.sizetf      = 0;
  cub_systf.derivtf     = cube_derivtf;
  cub_systf.user_data   = 0;
  P03_CHECK(vpi_register_analog_systf(&cub_systf) != NULL, "registering $cube failed");

  /* IEEE 1364-2005 26.2.4: acbFinalStep waits for cbEndOfCompile. */
  p03_defer(register_final);
}

void (*vlog_startup_routines[])(void) = { p03_07_startup, 0 };
