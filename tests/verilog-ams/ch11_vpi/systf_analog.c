/* 11 — vpi_register_analog_systf(), the derivtf phase, and the derivative
 * handles of vpi_handle_multi(vpiDerivative, ...).
 *
 * LRM 12.32: "The VPI routine vpi_register_analog_systf() shall register
 * callbacks for user-defined analog system tasks or functions. ... The
 * registration function (vpi_register_analog_systf() or vpi_register_systf())
 * with which the task or function is registered shall determine the context or
 * contexts from which the task or function can be invoked and how and when the
 * call backs associated with the function shall be called."
 *
 * LRM 12.32.1: "The compiletf, calltf, sizetf, and derivtf fields of the
 * s_vpi_analog_systf_data structure shall be pointers to the user-provided
 * applications which are to be invoked by the system task/function callback
 * mechanism. One or more of the compiletf, calltf, sizetf, and derivtf fields
 * can be set to NULL if they are not needed. Callbacks to the applications
 * pointed to by the compiletf and sizetf fields shall occur when the simulation
 * data structure is compiled or built" — and the derivtf callbacks "shall occur
 * when registering partial derivatives for the analog system task/function
 * arguments or return value."
 *
 * LRM 12.22.1: "The VPI routine vpi_handle_multi() is used to access the
 * derivative handles associated with analog system task/functions. The first
 * argument is the type vpiDerivative. The second is the handle for the
 * task/function argument for which a partial derivative is to be declared. The
 * third argument indicates the value with respect to which the derivative being
 * declared shall be calculated. ... For vpiDerivative, the vpi_handle_multi()
 * function can only be called for those derivatives allocated during the
 * derivtf phase of execution."
 *
 * LRM 12.32.2 (Declaring derivatives for analog system task/functions), on the
 * declarative nature of derivtf: it returns "a t_vpi_stf_partials data
 * structure containing the required information. The purpose of this function
 * is declarative only, it does not assign any value to the derivative being
 * declared." (An earlier revision of this header put that sentence at 12.32.1;
 * 12.32.1 is *System task and function callbacks* and carries the field and
 * build-phase sentences quoted further down, not this one.)
 *
 * LRM 12.22.2 prints the whole shape this file follows: derivs.count = 1,
 * derivative_of = {1}, derivative_to = {2}; then in calltf,
 * vpi_handle_by_index(funcHandle, 1..3), vpi_handle_multi(vpiDerivative,
 * i_handle, v_handle), and vpi_put_value of the conductance onto that handle.
 *
 * TWO SPELLINGS, AND WHY THIS FILE PICKS THE EXAMPLE'S. The LRM contradicts
 * itself about t_vpi_stf_partials, and an implementer who resolves it the other
 * way will not be able to COMPILE this file, so it is stated here rather than
 * discovered:
 *
 *   - 12.32.2's structure definition is
 *       typedef struct t_vpi_stf_partials { int count; int *derivative_of;
 *         int *derivative_wrt; } s_vpi_stf_partials, *p_vpi_stf_partials;
 *     which names the third field `derivative_wrt` and makes
 *     `t_vpi_stf_partials` a struct TAG only — `static t_vpi_stf_partials x;`
 *     is not legal C against it.
 *   - 12.22.2's example, the only executable code the LRM prints for this
 *     structure, writes `static t_vpi_stf_partials derivs;` and assigns
 *     `derivs.derivative_to`.
 *
 * This file follows the example (lines 149 and 159 below) because the example is
 * what an implementer copies and because P03's analog fixtures follow it too.
 * The consequence for src/vpi/vpi_user.h is stated in tests/fixtures/ch11_vpi/p02_SPEC.md at 8b1514d4's header list: it
 * must typedef the name `t_vpi_stf_partials`, not only the tag, and the third
 * field must be reachable as `derivative_to`. An implementer who prefers
 * 12.32.2's `derivative_wrt` changes exactly one line here (159) and one line
 * of tests/fixtures/ch11_vpi/p02_SPEC.md at 8b1514d4; nothing else in the row depends on the spelling.
 *
 * LRM 12.13: vpi_get_analog_systf_info() "shall return information about a
 * user-defined analog system task or function callback in an
 * s_vpi_analog_systf_data structure. The memory for this structure shall be
 * allocated by the user."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * analog_system_task_registration.va calls $p02_resistor at TWO call sites, with r1 = 1k and
 * r2 = 2k. LRM 2.6.2's Table 2-1 gives the scaled-notation symbol "K, k" the
 * value 1e3 (2.5 is Operators and says nothing about scale factors), and 2.6.2
 * prints `7k` among its own valid real constants, so the third argument reads
 * exactly 1000.0 at the first site and 2000.0 at the second, and the
 * conductances the application computes are
 *
 *   g1 = 1.0 / 1000.0 = 0.001      exact in binary64: IEEE division is
 *   g2 = 1.0 / 2000.0 = 0.0005     correctly rounded and the decimal literals
 *                                  parse to those same rounded values, so `==`
 *                                  is legal here without a tolerance.
 *
 * COUNTS. compiletf and derivtf are build-phase, once per call site: 2 each.
 * calltf is per evaluation, and an analog solver evaluates a contribution once
 * per Newton iteration, so its count is a property of the solver rather than of
 * the LRM — this file asserts only that it ran at least twice (once per site)
 * and that every compiletf and derivtf invocation preceded every calltf one.
 * The exact analog invocation ORDER and count belong to P03, not here.
 *
 * DERIVATIVE HANDLES. derivtf declares exactly one partial per call site:
 * of = argument 1 (the output `curr`), to = argument 2 (V(p,n)). So inside
 * calltf,
 *
 *   vpi_handle_multi(vpiDerivative, arg1, arg2)  must be non-NULL
 *   vpi_handle_multi(vpiDerivative, arg1, arg3)  must be NULL and set an error,
 *
 * the second because d(curr)/d(r) was never allocated during the derivtf phase
 * and 12.22.1 permits the call "only ... for those derivatives allocated during
 * the derivtf phase". A tool that hands out a handle for every pair makes the
 * declarative half of derivtf meaningless.
 *
 * THE OUTPUT ARGUMENT. 12.22.2's calltf puts the conductance on the
 * derivative object and curr = V(p,n)*g on argument 1, and the next statement
 * contributes curr. Both puts must succeed (no error): argument 1 is a real
 * variable the design reads back. The analysis is the banner's operating
 * point, at analog_system_task_registration.va's bias V(p,n) = 1.0, so calltf runs during it.
 *
 * THE CENSUS. `checks` counts the assertions whose number the LRM fixes:
 * compiletf's 10 at each of the two sites (seven CHECKs, then expect_error's
 * three), the startup routine's 3 and census's 12, so 20 + 3 + 12 = 35.
 * calltf's 11 per invocation run every time, but how often the solver
 * evaluates the block is its own business, so they are taken back out of
 * the count before it is printed (`call_checks`).
 *
 *! analysis op
 */

//! lrm 11.6.16
//! lrm 12.13
//! lrm 12.16
//! lrm 12.20
//! lrm-reject 12.20
//! lrm 12.22
//! lrm 12.22.1
//! lrm-reject 12.22.1
//! lrm 12.30
//! lrm 12.32
//! lrm 12.32.1
//! lrm 12.32.2
//! design analog_system_task_registration.va
//! stdout p02: 11_systf_analog checks=35

#include "p02_check.h"

static int order = 0;
static int compiles = 0, derivs_called = 0, calls = 0;
static int last_build_order = 0, first_call_order = 0;
static int saw_r1000 = 0, saw_r2000 = 0;
static int call_checks = 0;
static vpiHandle systf_analog;

static double real_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiRealVal;
  vpi_get_value(h, &v);
  expect_no_error("vpi_get_value(vpiRealVal)");
  return v.value.real;
}

static PLI_INT32 res_compiletf(p_cb_data cb_data)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  char name[32];

  compiles++;
  last_build_order = ++order;

  CHECK(cb_data != NULL && cb_data->user_data != NULL &&
        strcmp(cb_data->user_data, "res") == 0,
        "user_data must be passed back to an analog compiletf");
  CHECK(call != NULL, "11.6.16 NOTE 1 applies to analog systfs too");
  strcpy(name, vpi_get_str(vpiName, call));
  CHECK(strcmp(name, "$p02_resistor") == 0, "the call's vpiName, got %s", name);

  /* 12.22.2's argument checks, by index, 1-based. */
  CHECK(vpi_handle_by_index(call, 1) != NULL, "argument 1 must exist");
  CHECK(vpi_handle_by_index(call, 2) != NULL, "argument 2 must exist");
  CHECK(vpi_handle_by_index(call, 3) != NULL, "argument 3 must exist");
  CHECK(vpi_handle_by_index(call, 4) == NULL,
        "$p02_resistor is called with three arguments, not four");
  expect_error("vpi_handle_by_index past the last argument");
  return 0;
}

static p_vpi_stf_partials res_derivtf(p_cb_data cb_data)
{
  static t_vpi_stf_partials derivs;
  static int deriv_of[] = { 1 };
  static int deriv_to[] = { 2 };
  (void)cb_data;

  derivs_called++;
  last_build_order = ++order;

  derivs.count         = 1;
  derivs.derivative_of = deriv_of;
  derivs.derivative_to = deriv_to;
  return &derivs;
}

static PLI_INT32 res_calltf(p_cb_data cb_data)
{
  vpiHandle call, i_handle, v_handle, r_handle, didv, not_declared;
  s_vpi_value value;
  double g, r;
  int before = p02_checks;
  (void)cb_data;

  if (calls == 0) first_call_order = order + 1;
  calls++;
  ++order;

  call     = vpi_handle(vpiSysTfCall, NULL);
  i_handle = vpi_handle_by_index(call, 1);
  v_handle = vpi_handle_by_index(call, 2);
  r_handle = vpi_handle_by_index(call, 3);

  r = real_of(r_handle);
  if (r == 1000.0) saw_r1000 = 1;
  else if (r == 2000.0) saw_r2000 = 1;
  else CHECK(0, "the third argument must be 1000.0 or 2000.0, read %.17g", r);

  g = 1.0 / r;
  if (r == 1000.0)
    CHECK(g == 0.001, "1.0/1000.0 must be exactly 0.001, got %.17g", g);
  else
    CHECK(g == 0.0005, "1.0/2000.0 must be exactly 0.0005, got %.17g", g);

  /* The declared partial: d(arg1)/d(arg2). */
  didv = vpi_handle_multi(vpiDerivative, i_handle, v_handle);
  expect_no_error("vpi_handle_multi on a declared derivative");
  CHECK(didv != NULL, "the derivative declared by derivtf must be reachable");

  /* The undeclared one: d(arg1)/d(arg3). derivtf never allocated it. */
  not_declared = vpi_handle_multi(vpiDerivative, i_handle, r_handle);
  CHECK(not_declared == NULL,
        "a derivative not allocated during derivtf must not be handed out");
  expect_error("vpi_handle_multi on an underivable pair");

  value.format = vpiRealVal;
  value.value.real = g;
  vpi_put_value(didv, &value, NULL, vpiNoDelay);
  expect_no_error("vpi_put_value onto a derivative handle");

  value.format = vpiRealVal;
  value.value.real = real_of(v_handle) * g;
  vpi_put_value(i_handle, &value, NULL, vpiNoDelay);
  expect_no_error("vpi_put_value onto an analog task output argument");
  call_checks += p02_checks - before;
  return 0;
}

static int census(p_cb_data cb_data)
{
  s_vpi_analog_systf_data info;
  (void)cb_data;

  CHECK(compiles == 2,
        "analog_system_task_registration.va has two $p02_resistor call sites, so compiletf runs "
        "twice, ran %d", compiles);
  CHECK(derivs_called == 2,
        "derivtf is a build-phase callback, once per call site: want 2, got %d",
        derivs_called);
  CHECK(calls >= 2,
        "both call sites must have been evaluated at least once, calltf ran %d",
        calls);
  CHECK(last_build_order < first_call_order,
        "every compiletf/derivtf must precede every calltf: build ended at %d, "
        "calls began at %d", last_build_order, first_call_order);
  CHECK(saw_r1000 && saw_r2000,
        "both call sites must have been seen with their own resistance");

  memset(&info, 0, sizeof info);
  vpi_get_analog_systf_info(systf_analog, &info);
  expect_no_error("vpi_get_analog_systf_info");
  CHECK(info.type == vpiAnalogSysTask, "type should round trip to vpiAnalogSysTask");
  CHECK(info.tfname != NULL && strcmp(info.tfname, "$p02_resistor") == 0,
        "tfname should round trip");
  CHECK(info.compiletf == res_compiletf, "compiletf should round trip");
  CHECK(info.calltf    == res_calltf,    "calltf should round trip");
  CHECK(info.derivtf   == res_derivtf,   "derivtf should round trip");
  CHECK(info.sizetf    == NULL, "$p02_resistor is a task and registered no sizetf");

  p02_checks -= call_checks;
  p02_done("11_systf_analog");
  return 0;
}

static void setup(void)
{
  static s_vpi_analog_systf_data res = {
    vpiAnalogSysTask, 0, "$p02_resistor",
    res_calltf, res_compiletf, NULL, res_derivtf, "res"
  };
  static s_cb_data ccb = { 0 };

  systf_analog = vpi_register_analog_systf(&res);
  expect_no_error("vpi_register_analog_systf");
  CHECK(systf_analog != NULL, "vpi_register_analog_systf must return a handle");

  ccb.reason = cbEndOfSimulation;
  ccb.cb_rtn = census;
  CHECK(vpi_register_cb(&ccb) != NULL, "cbEndOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
