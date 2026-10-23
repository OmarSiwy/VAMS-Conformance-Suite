/* b 26.6.20 frames — the variables of an automatic task, over
 * frames.v (task automatic at holds reg x; static reg s; at runs
 * once at t=1; $finish at t=2).
 *
 * IEEE 1364-2005 §26.6.20, p. 404: the frame diagram draws frame ->> regs,
 * reg array, variables, named event, named event array and parameter, a
 * class carrying "-> validity int: vpiValid" and "-> automatic bool:
 * vpiAutomatic", and frame -> vpiScope to its task or function. Details: "a)
 * It shall be illegal to place value change callbacks on automatic variables.
 * b) It shall be illegal to put a value with a delay on automatic
 * variables." §26.5.1, p. 384, of a class definition: "Properties of the
 * class are defined in this location." §26.6.3, p. 389: a scope (a task is
 * one) ->> reg.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * At cbEndOfCompile no frame is executing. "b26_frames.at" is the task, a
 * vpiTask. at ->> vpiReg yields its one reg, x, declared inside an automatic
 * task: vpiAutomatic, a property of the class x belongs to, is TRUE.
 *
 * The legal neighbours, on the static reg s, are accepted (vpi_chk_error()
 * is 0 after each): a cbValueChange callback (time vpiSuppressTime, value
 * vpiSuppressVal), removed at once; and vpi_put_value(s, 1'b0, #5,
 * vpiInertialDelay | vpiReturnEvent), which returns its scheduled event
 * (§27.32) and never matures, the design finishing at t=2.
 *
 * The two refusals, on x. §27.33 and §27.32 name no failure value for them,
 * so only vpi_chk_error() is read, and its message must say "automatic": x
 * has no static storage, so a refusal for that alone would pass too.
 *   Details a) the same cbValueChange registration on x: nonzero.
 *   Details b) the same delayed put onto x: nonzero.
 */

//! inherited IEEE 1364-2005 26.6.20
//! inherited-reject IEEE 1364-2005 26.6.20
//! inherited IEEE 1364-2005 26.5.1
//! design frames.v
//! stdout p02: b_26_6_20_frames checks=14

#include "b_check.h"

static PLI_INT32 never(p_cb_data d) { (void)d; return 0; }

static s_vpi_time none = { vpiSuppressTime, 0, 0, 0.0 };
static s_vpi_value nov = { vpiSuppressVal, { 0 } };

static vpiHandle on_change(vpiHandle obj)
{
  s_cb_data cb;
  memset(&cb, 0, sizeof cb);
  cb.reason = cbValueChange;
  cb.cb_rtn = never;
  cb.obj = obj;
  cb.time = &none;
  cb.value = &nov;
  return vpi_register_cb(&cb);
}

static vpiHandle put_later(vpiHandle obj)
{
  s_vpi_time t5 = { vpiSimTime, 0, 5, 0.0 };
  s_vpi_value v;
  v.format = vpiScalarVal;
  v.value.scalar = vpi0;
  return vpi_put_value(obj, &v, &t5, vpiInertialDelay | vpiReturnEvent);
}

static PLI_INT32 eoc(p_cb_data d)
{
  vpiHandle t = p02_by_name("b26_frames.at");
  vpiHandle s = p02_by_name("b26_frames.s");
  vpiHandle itr, r, h, x = NULL;
  int n = 0;
  (void)d;
  CHECK(vpi_get(vpiType, t) == vpiTask, "at is a task");

  h = on_change(s);
  CHECK(h != NULL, "a value change callback on the static s");
  expect_no_error("cbValueChange on s");
  CHECK(vpi_remove_cb(h) == 1, "s's callback is removed");
  CHECK(put_later(s) != NULL, "a delayed put onto the static s returns its event");
  expect_no_error("a delayed put onto s");

  itr = vpi_iterate(vpiReg, t);
  if (itr != NULL)
    while ((r = vpi_scan(itr)) != NULL) {
      n++;
      x = r;
    }
  CHECK(n == 1 && strcmp(vpi_get_str(vpiName, x), "x") == 0 && vpi_get(vpiAutomatic, x) == 1,
        "26.6.20: the automatic task at ->> vpiReg yields x, vpiAutomatic TRUE");
  (void)on_change(x);
  expect_refusal_saying("a) cbValueChange on the automatic x", "automatic");
  (void)put_later(x);
  expect_refusal_saying("b) a delayed put onto the automatic x", "automatic");
  p02_done("b_26_6_20_frames");
  return 0;
}

static void startup(void)
{
  static s_cb_data c;
  c.reason = cbEndOfCompile;
  c.cb_rtn = eoc;
  CHECK(vpi_register_cb(&c) != NULL, "cbEndOfCompile");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
