/* p05 01 — VAMS-2023 12.29 vpi_put_delays(), on delays.v.
 *
 *   12.29 "The VPI routine vpi_put_delays() shall set the delays or timing
 *         limits of an object as indicated in the delay_p structure. The same
 *         ordering of delays shall be used as described in the
 *         vpi_get_delays() function ... For primitive objects, the
 *         no_of_delays value shall be 2 or 3."
 *
 * THE DERIVATION (delays.v's header gives both schedules). Before time 0
 * the application puts one delay, 2, on the continuous assignment and two,
 * rise 1 and fall 3, on the buffer. `a` is 0 at 0, 1 at 10, 0 at 30, so:
 *
 *     w (assign, #2):     0 at 2, 1 at 12, 0 at 32
 *     y (buf, #(1,3)):    0 at 3 (x -> 0 falls), 1 at 11, 0 at 33
 *
 * against 5/15/35 and 6/14/36 for the delays as written — every observed time
 * discriminates. vpi_get_delays reads the put values back, in the same order:
 * [2] for the assignment; [1, 3] and, for three, the derived turn-off
 * min(1, 3) = 1 for the buffer (IEEE 1364 §7.14).
 *
 * REFUSALS — the routine's own input rules, each NULL-free and error-reporting:
 *   a buffer given ONE delay        "no_of_delays value shall be 2 or 3"
 *   delay_p NULL                    no structure to read
 *   da NULL                         no delays in it
 *   a time_type that is neither vpiScaledRealTime nor vpiSimTime
 *   the module                      an object with no delays to set
 */

//! lrm 12.29
//! lrm-reject 12.29
//! lrm 11.3.2
//! lrm 11.3.2:1000
//! lrm 12.29:1
//! lrm 12.29:2
//! lrm 12.29:4
//! lrm 12.29:5
//! lrm 12.29:6
//! lrm 12.29:7
//! lrm 12.29:8
//! lrm 12.29:12
//! design delays.v
//! stdout p05-01: w=2/12/32 y=3/11/33
//! stdout p02: p05_01_put_delays checks=27

#include "p02_check.h"

static vpiHandle g_w, g_y;
static int w_t[4], y_t[4], nw, ny;

static PLI_INT32 on_change(p_cb_data cb)
{
  int t = (int)cb->time->low;
  if (cb->obj == g_w && nw < 4) w_t[nw++] = t;
  if (cb->obj == g_y && ny < 4) y_t[ny++] = t;
  return 0;
}

static PLI_INT32 at_end(p_cb_data cb)
{
  (void)cb;
  CHECK(nw == 3 && w_t[0] == 2 && w_t[1] == 12 && w_t[2] == 32,
        "12.29: w changes at 2/12/32 under the put #2, got %d changes %d/%d/%d", nw, w_t[0], w_t[1], w_t[2]);
  CHECK(ny == 3 && y_t[0] == 3 && y_t[1] == 11 && y_t[2] == 33,
        "12.29: y changes at 3/11/33 under the put #(1,3), got %d changes %d/%d/%d", ny, y_t[0], y_t[1], y_t[2]);
  printf("p05-01: w=%d/%d/%d y=%d/%d/%d\n", w_t[0], w_t[1], w_t[2], y_t[0], y_t[1], y_t[2]);
  p02_done("p05_01_put_delays");
  return 0;
}

static vpiHandle first(PLI_INT32 type, vpiHandle ref)
{
  vpiHandle itr = vpi_iterate(type, ref), h;
  CHECK(itr != NULL, "nothing of type %d", (int)type);
  h = vpi_scan(itr);
  vpi_free_object(itr);
  return h;
}

static PLI_INT32 at_compile(p_cb_data d)
{
  static s_cb_data cw, cy, ce;
  static s_vpi_time vt = { vpiSimTime, 0, 0, 0.0 };
  static s_vpi_value vv = { vpiScalarVal, { 0 } };
  s_vpi_time da[3];
  s_vpi_delay dl;
  vpiHandle top, ca, buf;

  top = vpi_handle_by_name("p05_delays", NULL);
  ca = first(vpiContAssign, top);
  buf = first(vpiPrimitive, top);
  g_w = vpi_handle_by_name("p05_delays.w", NULL);
  g_y = vpi_handle_by_name("p05_delays.y", NULL);
  CHECK(ca != NULL && buf != NULL && g_w != NULL && g_y != NULL, "the design's objects");

  memset(&dl, 0, sizeof dl);
  memset(da, 0, sizeof da);
  dl.da = da;
  dl.time_type = vpiScaledRealTime;

  /* the assignment: #5 -> #2 */
  dl.no_of_delays = 1;
  vpi_get_delays(ca, &dl);
  CHECK(da[0].real == 5.0, "12.11: the assignment's delay as written, 5");
  da[0].type = vpiScaledRealTime;
  da[0].real = 2.0;
  vpi_put_delays(ca, &dl);
  expect_no_error("vpi_put_delays(assign, 1)");
  da[0].real = -1;
  vpi_get_delays(ca, &dl);
  CHECK(da[0].real == 2.0, "12.29: vpi_get_delays reads the put 2 back");

  /* the buffer: #(4,6) -> #(1,3) */
  dl.no_of_delays = 2;
  da[0].type = da[1].type = vpiScaledRealTime;
  da[0].real = 1.0;
  da[1].real = 3.0;
  vpi_put_delays(buf, &dl);
  expect_no_error("vpi_put_delays(buf, 2)");
  dl.no_of_delays = 3;
  vpi_get_delays(buf, &dl);
  CHECK(da[0].real == 1.0 && da[1].real == 3.0 && da[2].real == 1.0, "12.29: rise 1, fall 3, turn-off min 1");

  /* refusals */
  dl.no_of_delays = 1;
  vpi_put_delays(buf, &dl);
  expect_error("vpi_put_delays(primitive, 1): a primitive takes 2 or 3");
  vpi_put_delays(buf, NULL);
  expect_error("vpi_put_delays(delay_p NULL)");
  dl.no_of_delays = 2;
  dl.da = NULL;
  vpi_put_delays(buf, &dl);
  expect_error("vpi_put_delays(da NULL)");
  dl.da = da;
  dl.time_type = 99;
  vpi_put_delays(buf, &dl);
  expect_error("vpi_put_delays(time_type 99)");
  dl.time_type = vpiScaledRealTime;
  vpi_put_delays(top, &dl);
  expect_error("vpi_put_delays(module): a module has no delays to set");

  cw.reason = cbValueChange; cw.cb_rtn = on_change; cw.obj = g_w; cw.time = &vt; cw.value = &vv;
  cy = cw; cy.obj = g_y;
  CHECK(vpi_register_cb(&cw) != NULL && vpi_register_cb(&cy) != NULL, "cbValueChange on w and y");
  ce.reason = cbEndOfSimulation; ce.cb_rtn = at_end;
  CHECK(vpi_register_cb(&ce) != NULL, "cbEndOfSimulation");
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
