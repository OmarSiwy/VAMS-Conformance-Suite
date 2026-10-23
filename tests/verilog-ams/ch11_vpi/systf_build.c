/* p04 09 — registering user system tasks and functions (12.33.1, 12.32.1)
 * and the build-time callbacks of an analog one (12.32.1, 12.32.2), over
 * analog_object_relations.va, which calls $p04_tap once.
 *
 * 12.33.1: "The type field value shall be an integer constant of vpiSysTask
 * or vpiSysFunction ... The sysfunctype field ... shall be an integer
 * constant of vpiIntFunc, vpiRealFunc, vpiTimeFunc, or vpiSizedFunc. This
 * field shall only be used when the type field is set to vpiSysFunction ...
 * One or more of the compiletf, calltf, and sizetf fields can be set to NULL
 * if they are not needed."
 *
 * 12.32.1, the analog twin: "The type field value shall be an integer
 * constant of vpiAnalogSysTask or vpiAnalogSysFunction. The sysfunctype
 * field ... shall be an integer constant of vpiIntFunc of vpiRealFunc. This
 * field shall only be used when the type field is set to
 * vpiAnalogSysFunction." And: "Callbacks to the applications pointed to by
 * the compiletf and sizetf fields shall occur when the simulation data
 * structure is compiled or built ... Callbacks to the applications pointed
 * to by the derivtf fields shall occur when registering partial derivatives
 * ... Callbacks to the application pointed to by the calltf routine shall
 * occur each time the system task or function is invoked during simulation
 * execution." "The user_data field ... shall be passed back to the
 * compiletf, sizetf, derivtf, and calltf applications when a callback
 * occurs."
 *
 * 12.32.2: "The derivtf field ... can be called during the build process
 * (similar to sizetf) and returns a pointer to a t_vpi_stf_partials data
 * structure".
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * ACCEPTED: every type/sysfunctype pair the two sentences list; a task (of
 * either domain) with a sysfunctype that is no constant at all, because the
 * field "shall only be used" for a function; and registrations with every
 * callback NULL. Each reads back what was registered (12.14, 12.13).
 * REFUSED: a digital type 7, a digital function of sysfunctype 12345, an
 * analog registration of the DIGITAL type vpiSysTask, and an analog function
 * of vpiTimeFunc — none is in the list its sentence gives.
 *
 * BUILD: analog_object_relations.va holds one call of $p04_tap and none of the others,
 * so by the time cbEndOfCompile — "End of simulation data structure
 * compilation or build" (12.31.4) — runs, $p04_tap's compiletf has run
 * exactly once and its derivtf exactly once, each handed user_data "tap";
 * its calltf has run zero times, because nothing has been simulated. Inside
 * those two callbacks the call that invoked them is 11.6.16 NOTE 1's
 * vpi_handle(vpiSysTfCall, NULL): a vpiSysTaskCall named "$p04_tap" with two
 * arguments. Outside them there is no active call: NULL, and no error.
 *
 * 12.18: vpi_get_real() "is available to analog tasks and functions only.
 * Should an error occur, vpi_get_real() shall return vpiUndefined." Asked
 * from cbEndOfCompile - no analog task or function - it returns vpiUndefined
 * with an error; asked inside $p04_tap's compiletf for property 9999, which
 * is no real property at all, likewise. (Not from the startup routine: IEEE
 * 1364-2005 26.2.4 refuses every routine but the registrations there, so a
 * refusal at startup would not be 12.18's.)
 *
 * The registrations are made from the startup routine, the only routines
 * 26.2.4 allows there; each reads back (12.14, 12.13) at cbEndOfCompile.
 */

//! lrm 12.32.1
//! lrm-reject 12.32.1
//! lrm 12.32.2
//! lrm 12.33.1
//! lrm-reject 12.33.1
//! lrm 11.6.16
//! lrm 12.13
//! lrm 12.14
//! lrm-reject 12.18
//! lrm 12.31.4
//! lrm 11.2.1
//! lrm 11.2.1:4
//! lrm-reject 12.18:2
//! lrm-reject 12.18:3
//! lrm 12.31.4:8
//! lrm 12.32.1:1
//! lrm 12.32.1:2
//! lrm 12.32.1:4
//! lrm 12.32.1:5
//! lrm 12.32.1:6
//! lrm 12.32.1:7
//! lrm 12.32.1:8
//! lrm 12.32.1:10
//! lrm 12.33.1:2
//! lrm 12.33.1:4
//! lrm 12.33.1:5
//! design analog_object_relations.va
//! stdout p02: p04_09_systf_build checks=58

#include "p02_check.h"

static char tap_ud[] = "tap";
static int compiles = 0, derivs = 0, calls = 0;

static void check_active(p_cb_data d, const char *who)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  vpiHandle itr;
  int n = 0;
  CHECK(call != NULL, "%s: NOTE 1 names the invoking call", who);
  CHECK(vpi_get(vpiType, call) == vpiSysTaskCall, "%s: a system task call", who);
  CHECK(strcmp(vpi_get_str(vpiName, call), "$p04_tap") == 0, "%s: of $p04_tap", who);
  itr = vpi_iterate(vpiArgument, call);
  while (vpi_scan(itr) != NULL) n++;
  CHECK(n == 2, "%s: with two arguments, got %d", who, n);
  CHECK(d != NULL && d->user_data == tap_ud, "%s: user_data is passed back", who);
}

static PLI_INT32 tap_compiletf(p_cb_data d)
{
  compiles++;
  check_active(d, "compiletf");
  CHECK(vpi_get_real(9999, NULL) == (double)vpiUndefined, "12.18: 9999 is no real property");
  expect_error("vpi_get_real(9999) in compiletf");
  return 0;
}
static PLI_INT32 tap_calltf(p_cb_data d) { (void)d; calls++; return 0; }

static p_vpi_stf_partials tap_derivtf(p_cb_data d)
{
  static PLI_INT32 of[] = { 1 };
  static PLI_INT32 wrt[] = { 2 };
  static t_vpi_stf_partials p;
  derivs++;
  check_active(d, "derivtf");
  p.count = 1;
  p.derivative_of = of;
  p.derivative_wrt = wrt;
  return &p;
}

static PLI_INT32 d_tf(PLI_BYTE8 *u) { (void)u; return 0; }

/* The registrations' handles, read back at cbEndOfCompile: IEEE 1364-2005
 * 26.2.4 allows only the registration routines in a startup routine. */
static const PLI_INT32 types[] = { vpiIntFunc, vpiRealFunc, vpiTimeFunc, vpiSizedFunc };
static vpiHandle f_h[4], t_h, ai_h;

static void digital(void)
{
  static char names[4][8] = { "$p04_f0", "$p04_f1", "$p04_f2", "$p04_f3" };
  s_vpi_systf_data d;
  int k;

  for (k = 0; k < 4; k++) {
    memset(&d, 0, sizeof d);
    d.type = vpiSysFunction;
    d.sysfunctype = types[k];
    d.tfname = names[k];
    d.calltf = d_tf;
    f_h[k] = vpi_register_systf(&d);
    CHECK(f_h[k] != NULL, "12.33.1: a function of sysfunctype %d registers", (int)types[k]);
  }
  memset(&d, 0, sizeof d);
  d.type = vpiSysTask;
  d.sysfunctype = 12345;
  d.tfname = (PLI_BYTE8 *)"$p04_t";
  t_h = vpi_register_systf(&d);
  CHECK(t_h != NULL, "12.33.1: a task's sysfunctype is not used, so any value registers");
  expect_no_error("vpi_register_systf(task, all callbacks NULL)");

  d.type = 7;
  d.tfname = (PLI_BYTE8 *)"$p04_bad_type";
  CHECK(vpi_register_systf(&d) == NULL, "12.33.1: type 7 is neither vpiSysTask nor vpiSysFunction");
  expect_error("vpi_register_systf(type 7)");
  d.type = vpiSysFunction;
  d.sysfunctype = 12345;
  d.tfname = (PLI_BYTE8 *)"$p04_bad_ret";
  CHECK(vpi_register_systf(&d) == NULL, "12.33.1: a function of sysfunctype 12345");
  expect_error("vpi_register_systf(function, 12345)");
}

static vpiHandle analog(void)
{
  s_vpi_analog_systf_data a;
  vpiHandle tap;

  memset(&a, 0, sizeof a);
  a.type = vpiAnalogSysTask;
  a.sysfunctype = 0;
  a.tfname = (PLI_BYTE8 *)"$p04_tap";
  a.calltf = tap_calltf;
  a.compiletf = tap_compiletf;
  a.derivtf = tap_derivtf;
  a.user_data = tap_ud;
  tap = vpi_register_analog_systf(&a);
  CHECK(tap != NULL, "$p04_tap registers");

  memset(&a, 0, sizeof a);
  a.type = vpiAnalogSysFunction;
  a.sysfunctype = vpiIntFunc;
  a.tfname = (PLI_BYTE8 *)"$p04_ai";
  ai_h = vpi_register_analog_systf(&a);
  CHECK(ai_h != NULL, "12.32.1: an analog function of vpiIntFunc, every callback NULL");
  a.sysfunctype = vpiRealFunc;
  a.tfname = (PLI_BYTE8 *)"$p04_ar";
  CHECK(vpi_register_analog_systf(&a) != NULL, "12.32.1: and of vpiRealFunc");
  a.type = vpiAnalogSysTask;
  a.sysfunctype = 12345;
  a.tfname = (PLI_BYTE8 *)"$p04_at";
  CHECK(vpi_register_analog_systf(&a) != NULL, "12.32.1: a task's sysfunctype is not used");
  expect_no_error("vpi_register_analog_systf(task, 12345)");

  a.type = vpiAnalogSysFunction;
  a.sysfunctype = vpiTimeFunc;
  a.tfname = (PLI_BYTE8 *)"$p04_atime";
  CHECK(vpi_register_analog_systf(&a) == NULL, "12.32.1: an analog function is vpiIntFunc or vpiRealFunc");
  expect_error("vpi_register_analog_systf(vpiTimeFunc)");
  a.type = vpiSysTask;
  a.sysfunctype = 0;
  a.tfname = (PLI_BYTE8 *)"$p04_adig";
  CHECK(vpi_register_analog_systf(&a) == NULL, "12.32.1: vpiSysTask is the digital type");
  expect_error("vpi_register_analog_systf(vpiSysTask)");
  return tap;
}

static PLI_INT32 end_of_compile(p_cb_data d)
{
  s_vpi_systf_data got;
  s_vpi_analog_systf_data agot;
  int k;
  (void)d;
  for (k = 0; k < 4; k++) {
    vpi_get_systf_info(f_h[k], &got);
    CHECK(got.type == vpiSysFunction && got.sysfunctype == types[k], "and reads back");
  }
  vpi_get_systf_info(t_h, &got);
  CHECK(got.type == vpiSysTask && got.calltf == NULL && got.compiletf == NULL && got.sizetf == NULL,
        "the task reads back, every callback NULL");
  vpi_get_analog_systf_info(ai_h, &agot);
  CHECK(agot.type == vpiAnalogSysFunction && agot.sysfunctype == vpiIntFunc && agot.derivtf == NULL, "reads back");
  CHECK(compiles == 1, "compiletf ran once, at the build, got %d", compiles);
  CHECK(derivs == 1, "derivtf ran once, at the build, got %d", derivs);
  CHECK(calls == 0, "calltf has not run: nothing was simulated, got %d", calls);
  CHECK(vpi_handle(vpiSysTfCall, NULL) == NULL, "outside a callback there is no active call");
  expect_no_error("vpi_handle(vpiSysTfCall, NULL)");
  CHECK(vpi_get_real(vpiEndTime, NULL) == (double)vpiUndefined, "12.18: cbEndOfCompile is no analog task");
  expect_error("vpi_get_real in cbEndOfCompile");
  p02_done("p04_09_systf_build");
  return 0;
}

static void startup(void)
{
  static s_cb_data cb;
  digital();
  analog();
  CHECK(compiles == 0 && derivs == 0, "nothing is built while the startup routines run");
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = end_of_compile;
  CHECK(vpi_register_cb(&cb) != NULL, "cbEndOfCompile registration failed");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
