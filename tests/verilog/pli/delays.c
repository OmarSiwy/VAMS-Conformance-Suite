/* b 27 delays — vpi_get_delays() and vpi_put_delays(), over
 * ch11_vpi/delays.v (`timescale 1ns/1ns: `assign #5 w = a;`,
 * `buf #(4,6) (y, a);`, a = 0 at 0, 1 at 10, 0 at 30).
 *
 * IEEE 1364-2005:
 *
 * §27.9, p. 424-425: "The VPI routine vpi_get_delays() shall retrieve the
 * delays or pulse limits of an object and place them in an s_vpi_delay
 * structure that has been allocated by the application. The format of the
 * delay information shall be controlled by the time_type flag in the
 * s_vpi_delay structure. This routine shall ignore the value of the type flag
 * in the s_vpi_time structure." "Legal values for the number of delays shall
 * be determined by the type of object: — For primitive objects, the
 * no_of_delays value shall be 2 or 3." "The application-allocated
 * s_vpi_delay array shall contain delays in the same order in which they
 * occur in the Verilog HDL description." Table 27-2: "mtm_flag = TRUE
 * pulsere_flag = FALSE 3 * no_of_delays 1st delay: da[0] -> min delay da[1]
 * -> typ delay da[2] -> max delay".
 *
 * §27.30, p. 447-448: "The VPI routine vpi_put_delays() shall set the delays
 * or timing limits of an object as indicated in the delay_p structure. The
 * same ordering of delays shall be used as described in the vpi_get_delays()
 * function." "For primitive objects, the no_of_delays value shall be 2 or 3."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * GET, at cbStartOfSimulation (before t=0):
 *   buf, 2 delays, vpiSimTime: [4, 6] in source order, although every da[k]
 *        was preset to type vpiSuppressTime (ignored).
 *   buf, 3 delays: [4, 6, 4] — the third, turn-off, is the smaller of rise
 *        and fall when two are given (§7.14, quoted below).
 *   buf, 2 delays, vpiScaledRealTime: [4.0, 6.0] in the 1 ns unit.
 *   buf, 2 delays, mtm_flag: 3*2 elements, each delay's min, typ, max; a
 *        delay written without min:typ:max is the same value in all three:
 *        [4, 4, 4, 6, 6, 6].
 *   assign, 3 delays: [5, 5, 5] — w is a scalar net, so §6.1.3 (p. 71)
 *        treats the delay "in the same way as for gate delays", and §7.14
 *        (p. 101): "When one delay value is given, then this value shall be
 *        used for all propagation delays associated with the gate or the
 *        net." The buf's third, [4, 6, 4], is §7.14's "The delay when the
 *        signal changes to high impedance or to unknown shall be the lesser
 *        of the two delay values."
 * REFUSED: the buf with 1 delay and with 4 (a primitive takes 2 or 3), a
 * NULL delay_p, and the module (no delays).
 *
 * PUT, at cbStartOfSimulation: the buf gets [2, 8] (rise 2, fall 8), read
 * back as [2, 8] and, with three, [2, 8, 2]. y then follows a with those
 * delays: 0 at 8 (x -> 0 falls), 1 at 12, 0 at 38.
 * REFUSED: [3] as one delay onto the buf, which leaves [2, 8] in place.
 */

//! lrm 12.11
//! lrm 12.11:3
//! inherited IEEE 1364-2005 27.9
//! inherited-reject IEEE 1364-2005 27.9
//! inherited IEEE 1364-2005 27.30
//! inherited-reject IEEE 1364-2005 27.30
//! design ../../verilog-ams/ch11_vpi/delays.v
//! stdout p02: b_27_delays checks=25

#include "b_check.h"

static vpiHandle top, buf, asg, y;
static int y_t[4], ny = 0;

static vpiHandle first(PLI_INT32 type, vpiHandle ref)
{
  vpiHandle itr = vpi_iterate(type, ref), h;
  CHECK(itr != NULL, "no object of type %d", (int)type);
  h = vpi_scan(itr);
  vpi_free_object(itr);
  return h;
}

static void get(vpiHandle h, s_vpi_time *da, int n, PLI_INT32 type, int mtm)
{
  s_vpi_delay d;
  int k;
  for (k = 0; k < 9; k++) { da[k].type = vpiSuppressTime; da[k].low = 0; da[k].real = 0; }
  memset(&d, 0, sizeof d);
  d.da = da;
  d.no_of_delays = n;
  d.time_type = type;
  d.mtm_flag = mtm;
  vpi_get_delays(h, &d);
}

static PLI_INT32 on_y(p_cb_data cb)
{
  if (ny < 4) y_t[ny] = (int)cb->time->low;
  ny++;
  return 0;
}

static PLI_INT32 at_end(p_cb_data cb)
{
  (void)cb;
  CHECK(ny == 3 && y_t[0] == 8 && y_t[1] == 12 && y_t[2] == 38,
        "27.30: y changes at 8/12/38 under #(2,8), got %d: %d/%d/%d", ny, y_t[0], y_t[1], y_t[2]);
  p02_done("b_27_delays");
  return 0;
}

static PLI_INT32 start(p_cb_data cb)
{
  s_vpi_time da[9];
  s_vpi_delay d;
  static s_vpi_time vt;
  static s_vpi_value vv;
  static s_cb_data vc, end;
  (void)cb;

  top = p02_by_name("p05_delays");
  y = p02_by_name("p05_delays.y");
  buf = first(vpiPrimitive, top);
  asg = first(vpiContAssign, top);

  get(buf, da, 2, vpiSimTime, 0);
  expect_no_error("vpi_get_delays(buf, 2)");
  CHECK(da[0].low == 4 && da[1].low == 6 && da[0].high == 0, "27.9: [4, 6] in source order");
  get(buf, da, 3, vpiSimTime, 0);
  CHECK(da[0].low == 4 && da[1].low == 6 && da[2].low == 4, "27.9: [4, 6, 4]");
  get(buf, da, 2, vpiScaledRealTime, 0);
  CHECK(da[0].real == 4.0 && da[1].real == 6.0, "27.9: time_type controls the format");
  get(buf, da, 2, vpiSimTime, 1);
  expect_no_error("vpi_get_delays(buf, mtm)");
  CHECK(da[0].low == 4 && da[1].low == 4 && da[2].low == 4 && da[3].low == 6 && da[4].low == 6 &&
        da[5].low == 6, "27.9: min, typ, max of each delay");
  get(asg, da, 3, vpiSimTime, 0);
  expect_no_error("vpi_get_delays(assign, 3)");
  CHECK(da[0].low == 5 && da[1].low == 5 && da[2].low == 5, "27.9: the assignment's #5 for all three");

  get(buf, da, 1, vpiSimTime, 0);
  expect_refusal("vpi_get_delays(buf, 1)");
  get(buf, da, 4, vpiSimTime, 0);
  expect_refusal("vpi_get_delays(buf, 4)");
  vpi_get_delays(buf, NULL);
  expect_refusal("vpi_get_delays(buf, NULL)");
  get(top, da, 2, vpiSimTime, 0);
  expect_refusal("vpi_get_delays(module)");

  memset(&d, 0, sizeof d);
  d.da = da;
  d.no_of_delays = 2;
  d.time_type = vpiSimTime;
  da[0].type = da[1].type = vpiSimTime;
  da[0].high = da[1].high = 0;
  da[0].low = 2;
  da[1].low = 8;
  vpi_put_delays(buf, &d);
  expect_no_error("vpi_put_delays(buf, [2, 8])");
  d.no_of_delays = 1;
  da[0].low = 3;
  vpi_put_delays(buf, &d);
  expect_refusal("vpi_put_delays(buf, 1 delay)");
  get(buf, da, 3, vpiSimTime, 0);
  CHECK(da[0].low == 2 && da[1].low == 8 && da[2].low == 2, "27.30: [2, 8, 2], the refused put left no trace");

  vt.type = vpiSimTime;
  vv.format = vpiSuppressVal;
  vc.reason = cbValueChange;
  vc.cb_rtn = on_y;
  vc.obj = y;
  vc.time = &vt;
  vc.value = &vv;
  CHECK(vpi_register_cb(&vc) != NULL, "cbValueChange on y");
  end.reason = cbEndOfSimulation;
  end.cb_rtn = at_end;
  CHECK(vpi_register_cb(&end) != NULL, "cbEndOfSimulation");
  return 0;
}

static void startup(void)
{
  static s_cb_data cb;
  cb.reason = cbStartOfSimulation;
  cb.cb_rtn = start;
  CHECK(vpi_register_cb(&cb) != NULL, "cbStartOfSimulation");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
