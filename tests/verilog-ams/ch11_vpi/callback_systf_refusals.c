/* p04 04 — what the callback and system task/function routines REFUSE, over
 * objects.v.
 *
 * LRM 11.2.1: "VPI callbacks shall be registered by the user with the
 * functions vpi_register_cb(), vpi_register_systf() and
 * vpi_register_analog_systf(). These routines indicate the specific reason for
 * the callback, the application to be called, and what system and user data
 * shall be passed". A registration that names no reason the product knows,
 * or no application to call, cannot be kept:
 *
 *   12.31    cb_data_p "shall point to a s_cb_data structure": NULL is
 *            refused. "the reason field ... shall be set to a predefined
 *            constant": 9999 is none. "The cb_rtn field ... shall be set to the
 *            application routine name": NULL names none.
 *   12.31.1  cbValueChange: "cb_data_p->obj This field shall be assigned a
 *            handle to an expression, terminal, or statement for which the
 *            callback shall occur". NULL is none of those (only cbForce and
 *            cbRelease give NULL a meaning), and a MODULE is none of those
 *            either.
 *   12.31.4  "The only fields in the s_cb_data structure which need to be
 *            setup for simulation action/feature callbacks are the reason,
 *            cb_rtn, and user_data" — cb_rtn is one of the required ones, so
 *            cbEndOfSimulation with a NULL cb_rtn is refused.
 *   11.6.25 / 12.6  "vpiHandle obj  Handle to a simulation-related callback":
 *            vpi_get_cb_info() on a module handle, on NULL, and with a NULL
 *            cb_data_p ("The memory for this structure shall be allocated by
 *            the user") is refused. The callback diagram lists "cb info" and
 *            nothing else, so vpi_get(vpiSize, callback) is vpiUndefined —
 *            and vpiType is still answered (vpiCallback).
 *   12.14    "vpiHandle obj  Handle to a system task/function-related
 *            callback": a module is not one, NULL systf_data_p is not
 *            user-allocated memory, and a registration made with
 *            vpi_register_analog_systf() is not a "user-defined system task or
 *            function callback in an s_vpi_systf_data structure".
 *   12.13    the analog twin: a module is refused, and so is a digital
 *            registration.
 *   12.22 / 12.22.1  vpi_handle_multi(vpiDerivative, ...) "can only be called
 *            for those derivatives allocated during the derivtf phase of
 *            execution". No derivtf ran — no analog system function is ever
 *            called in this digital run — so no derivative exists for any pair
 *            of handles and the call is refused. 12.22's other type is
 *            vpiInterModPath; 9999 is neither.
 *
 * Every refused registration is also checked to have left nothing behind: a
 * refused callback's routine exits 1 if it is ever called. The two kept ones
 * are the census (cbReadOnlySynch at t=0) and `held`, a cbEndOfSimulation
 * that stays live for the whole run — a time callback is one-shot and its
 * handle is already spent while it runs (12.31.2), so the census cannot
 * probe its own handle.
 */

//! lrm-reject 11.2.1
//! lrm-reject 11.6.25
//! lrm-reject 12.6
//! lrm-reject 12.13
//! lrm-reject 12.14
//! lrm-reject 12.22
//! lrm-reject 12.22.1
//! lrm-reject 12.31
//! lrm-reject 12.31.1
//! lrm-reject 12.31.4
//! lrm 12.33.2
//! design objects.v
//! stdout p02: p04_04_callback_systf_refusals checks=83

#include "p02_check.h"

static PLI_INT32 never(p_cb_data cb_data)
{
  (void)cb_data;
  fprintf(stderr, "p04: a refused callback was called\n");
  exit(1);
  return 0;
}

static PLI_INT32 tf(PLI_BYTE8 *u) { (void)u; return 0; }
static PLI_INT32 atf(p_cb_data d) { (void)d; return 0; }

static vpiHandle held; /* a live cbEndOfSimulation: one-shot time callbacks are retired as they fire */
static PLI_INT32 at_end(p_cb_data d) { (void)d; return 0; }

static PLI_INT32 census(p_cb_data cb_data)
{
  s_cb_data info;
  s_vpi_systf_data dinfo;
  s_vpi_analog_systf_data ainfo;
  vpiHandle top = p02_by_name("p04_objects");
  vpiHandle i = p02_by_name("p04_objects.i");
  vpiHandle x = p02_by_name("p04_objects.x");
  vpiHandle dig, ana;
  s_vpi_systf_data d = { vpiSysTask, 0, (PLI_BYTE8 *)"$p04_task", tf, NULL, NULL, NULL };
  s_vpi_analog_systf_data a = { vpiAnalogSysFunc, vpiRealFunc, (PLI_BYTE8 *)"$p04_afunc",
                                atf, NULL, NULL, NULL, NULL };
  (void)cb_data;

  /* 11.6.25 / 12.6 */
  vpi_get_cb_info(top, &info);
  expect_error("vpi_get_cb_info(module)");
  vpi_get_cb_info(NULL, &info);
  expect_error("vpi_get_cb_info(NULL)");
  vpi_get_cb_info(held, NULL);
  expect_error("vpi_get_cb_info(cb, NULL)");
  CHECK(vpi_get(vpiType, held) == vpiCallback, "11.6.25: a callback's type is vpiCallback");
  expect_no_error("vpi_get(vpiType, callback)");
  CHECK(vpi_get(vpiSize, held) == vpiUndefined, "11.6.25: a callback has no vpiSize");
  expect_error("vpi_get(vpiSize, callback)");

  /* 12.13 / 12.14 */
  dig = vpi_register_systf(&d);
  CHECK(dig != NULL, "the digital registration is kept");
  ana = vpi_register_analog_systf(&a);
  CHECK(ana != NULL, "the analog registration is kept");
  vpi_get_systf_info(top, &dinfo);
  expect_error("vpi_get_systf_info(module)");
  vpi_get_systf_info(dig, NULL);
  expect_error("vpi_get_systf_info(dig, NULL)");
  vpi_get_systf_info(ana, &dinfo);
  expect_error("vpi_get_systf_info(analog registration)");
  vpi_get_systf_info(dig, &dinfo);
  expect_no_error("vpi_get_systf_info(dig)");
  CHECK(strcmp(dinfo.tfname, "$p04_task") == 0, "and the kept one reads back");
  vpi_get_analog_systf_info(top, &ainfo);
  expect_error("vpi_get_analog_systf_info(module)");
  vpi_get_analog_systf_info(dig, &ainfo);
  expect_error("vpi_get_analog_systf_info(digital registration)");
  vpi_get_analog_systf_info(ana, NULL);
  expect_error("vpi_get_analog_systf_info(ana, NULL)");

  /* 12.22 / 12.22.1 */
  CHECK(vpi_handle_multi(vpiDerivative, i, x) == NULL, "12.22.1: no derivtf allocated d(i)/d(x)");
  expect_error("vpi_handle_multi(vpiDerivative, i, x)");
  CHECK(vpi_handle_multi(vpiDerivative, NULL, NULL) == NULL, "12.22.1: nor anything of NULL");
  expect_error("vpi_handle_multi(vpiDerivative, NULL, NULL)");
  CHECK(vpi_handle_multi(9999, i, x) == NULL, "12.22: 9999 is no many-to-one type");
  expect_error("vpi_handle_multi(9999)");

  p02_done("p04_04_callback_systf_refusals");
  return 0;
}

static PLI_INT32 at_compile(p_cb_data d)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data cb, bad;
  vpiHandle top = p02_by_name("p04_objects");

  /* 12.31 */
  CHECK(vpi_register_cb(NULL) == NULL, "12.31: NULL is no s_cb_data");
  expect_error("vpi_register_cb(NULL)");
  bad.reason = 9999;
  bad.cb_rtn = never;
  CHECK(vpi_register_cb(&bad) == NULL, "12.31: 9999 is no reason");
  expect_error("vpi_register_cb(reason 9999)");
  bad.reason = cbAtStartOfSimTime;
  bad.cb_rtn = NULL;
  bad.time = &t;
  CHECK(vpi_register_cb(&bad) == NULL, "12.31: a NULL cb_rtn is no routine");
  expect_error("vpi_register_cb(cb_rtn NULL)");

  /* 12.31.1 */
  bad.reason = cbValueChange;
  bad.cb_rtn = never;
  bad.obj = NULL;
  bad.time = NULL;
  CHECK(vpi_register_cb(&bad) == NULL, "12.31.1: cbValueChange needs an object");
  expect_error("vpi_register_cb(cbValueChange, NULL)");
  bad.obj = top;
  CHECK(vpi_register_cb(&bad) == NULL, "12.31.1: a module is not an expression or terminal");
  expect_error("vpi_register_cb(cbValueChange, module)");

  /* 12.31.4 */
  bad.reason = cbEndOfSimulation;
  bad.cb_rtn = NULL;
  bad.obj = NULL;
  CHECK(vpi_register_cb(&bad) == NULL, "12.31.4: cb_rtn is a required field");
  expect_error("vpi_register_cb(cbEndOfSimulation, cb_rtn NULL)");

  cb.reason = cbReadOnlySynch;
  cb.cb_rtn = census;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadOnlySynch(0) registration failed");
  bad.reason = cbEndOfSimulation;
  bad.cb_rtn = at_end;
  held = vpi_register_cb(&bad);
  CHECK(held != NULL, "cbEndOfSimulation registration failed");
  (void)d;
  return 0;
}

/* The design is read at cbEndOfCompile: a startup routine runs "just after
 * the simulator is invoked" (§12.33.2), before the design is built. */
static void setup(void)
{
  static s_cb_data built;
  built.reason = cbEndOfCompile;
  built.cb_rtn = at_compile;
  (void)vpi_register_cb(&built);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
