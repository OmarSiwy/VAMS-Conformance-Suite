/* b7 calltf at two call sites: VAMS-2023 12.32.1, a user system function's
 * calltf runs at every invocation, from whichever call site.
 *
 * 12.32.1 "Callbacks to the application pointed to by the calltf routine
 *         shall occur each time the system task or function is invoked
 *         during simulation execution."
 * 12.30   a put on "system function calls" sets the value the call returns.
 * 12.32   "Callbacks can be registered to occur when a user-defined system
 *         task or function is encountered during compilation or execution";
 *         one registration covers every call of the name.
 *
 * DERIVATION. two_sites.va invokes $b7_cfn(1.0) and $b7_cfn(2.0), two
 * call sites, at every evaluation of its analog block; the analysis is this
 * banner's `tran 0 1m 1e-4`, which evaluates it at least once. So calltf runs
 * at least twice, and inside it vpi_handle(vpiSysTfCall, NULL) names two
 * distinct call objects over the run (vpi_compare_objects() tells them
 * apart). calltf puts vpiRealVal 2.0 each time, so V(a) = V(b) = 2.0 at
 * acbFinalStep, to the ideal sources' last bits (1e-12). Both wants are 2.0,
 * so the branch order does not matter. How many times beyond two calltf
 * runs is the solver's and is not asserted.
 *
 * 12.32.1 "One or more of the compiletf, calltf, and sizetf fields can be set
 *         to NULL if they are not needed": cfn sets compiletf, sizetf and
 *         derivtf to NULL, and the registration succeeds; the calltf alone
 *         runs, at each call site.
 *
 *! design   two_sites.va
 *! analysis tran 0 1m 1e-4
 */

//! lrm 12.32:2
//! lrm 12.32.1:9
//! lrm 12.32.1:1001
//! design two_sites.va
//! stdout b7-calltf-sites: sites=2 v=2

#include "p03_vpi_analog.h"

static int calls, sites;
static vpiHandle seen[4];

static PLI_INT32 cfn_calltf(p_cb_data cb)
{
  s_vpi_value v;
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  int k, known = 0;
  (void)cb;
  calls++;
  P03_CHECK(call != NULL, "12.32.1: calltf runs with no active call");
  for (k = 0; k < sites; k++)
    if (vpi_compare_objects(call, seen[k])) known = 1;
  if (!known) {
    P03_CHECK(sites < 4, "more than four distinct call objects");
    seen[sites++] = call;
  }
  v.format = vpiRealVal;
  v.value.real = 2.0;
  vpi_put_value(call, &v, NULL, vpiNoDelay);
  p03_no_error("vpi_put_value(vpiRealVal 2.0) onto a $b7_cfn call");
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  vpiHandle top, itr, br;
  int k = 0;
  (void)cb;
  P03_CHECK(calls > 0, "12.32.1: $b7_cfn is invoked from two call sites and its calltf ran %d times", calls);
  P03_CHECK(sites == 2, "12.32.1: calltf ran for %d distinct call objects, want the two sites", sites);
  top = vpi_handle_by_name((PLI_BYTE8 *)"b7_two_sites", NULL);
  itr = vpi_iterate(vpiBranchObj, top);
  P03_CHECK(itr != NULL, "11.6.6: the top module has no branches");
  while ((br = vpi_scan(itr)) != NULL) {
    P03_NEAR(p03_real_of(vpi_handle(vpiPotential, br), NULL), 2.0, 1e-12, "12.30: the value calltf put reached the node");
    k++;
  }
  P03_CHECK(k == 2, "11.6.6: two branches, got %d", k);
  printf("b7-calltf-sites: sites=2 v=2\n");
  fflush(stdout);
  return 0;
}

static void b7_after_compile(void)
{
  static s_cb_data fin_cb;
  fin_cb.reason = acbFinalStep;
  fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the callbacks
 * above register at cbEndOfCompile (p03_defer, VD-044). */
static void b7_startup(void)
{
  static s_vpi_analog_systf_data cfn;
  cfn.type = vpiAnalogSysFunc;
  cfn.sysfunctype = vpiRealFunc;
  cfn.tfname = (PLI_BYTE8 *)"$b7_cfn";
  cfn.calltf = cfn_calltf;
  cfn.compiletf = NULL;     /* 12.32.1: not needed. */
  cfn.sizetf = NULL;        /* 12.32.1: not needed. */
  cfn.derivtf = NULL;       /* 12.32.1: not needed. */
  cfn.user_data = NULL;
  P03_CHECK(vpi_register_analog_systf(&cfn) != NULL, "12.32: registering $b7_cfn failed");
  p03_no_error("12.32.1: vpi_register_analog_systf with compiletf/sizetf/derivtf NULL");
  p03_defer(b7_after_compile);
}

void (*vlog_startup_routines[])(void) = { b7_startup, 0 };
