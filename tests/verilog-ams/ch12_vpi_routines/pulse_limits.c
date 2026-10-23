/* b7 pulse limits: VAMS-2023 12.29 Table 12-5, both flags set. A put with
 * mtm_flag and pulsere_flag carries nine elements per delay, and a get with
 * the same flags returns them in the same order.
 *
 * 12.29  "shall set the delays or timing limits of an object as indicated in
 *        the delay_p structure. The same ordering of delays shall be used as
 *        described in the vpi_get_delays() function." Table 12-5,
 *        "mtm_flag = true pulsere_flag = true 9 * no_of_delays 1st delay:
 *        da[0] -> min delay da[1] -> typ delay da[2] -> max delay da[3] ->
 *        min reject da[4] -> typ reject da[5] -> max reject da[6] -> min
 *        error da[7] -> typ error da[8] -> max error 2nd delay: ..."
 * 12.11  vpi_get_delays() "shall retrieve the delays or pulse limits of an
 *        object", the same Table (12-3) for the get.
 *
 * DERIVATION. specify.v's u1 path (a => y), 2 delays (a module path
 * takes 2, 12.29). The put, per delay, min = typ = max so that keeping only
 * the selected one of the three changes nothing, with distinct reject and
 * error limits (reject <= error <= delay, a well-formed pulse window):
 *     1st delay: 8, 8, 8,   reject 2, 2, 2,   error 3, 3, 3
 *     2nd delay: 10, 10, 10, reject 4, 4, 4,  error 5, 5, 5
 * The get with both flags returns those 18 values in that order. Every value
 * is an integer number of the 1 ns unit, so compared with ==.
 */

//! lrm 12.29:14
//! design specify.v
//! stdout p02: b7_pulse_limits checks=25

#include "../ch11_vpi/p02_check.h"

static int scan_all(vpiHandle itr, vpiHandle *out, int max)
{
  int n = 0;
  vpiHandle h;
  if (itr == NULL) return 0;
  while ((h = vpi_scan(itr)) != NULL) {
    if (n < max) out[n] = h;
    n++;
  }
  return n;
}

static PLI_INT32 walk(p_cb_data cb)
{
  static const double v[18] = { 8, 8, 8, 2, 2, 2, 3, 3, 3, 10, 10, 10, 4, 4, 4, 5, 5, 5 };
  static s_vpi_time da[18];
  static s_vpi_delay dl;
  vpiHandle u, paths[4], ins[2];
  int k;
  (void)cb;

  u = p02_by_name("b7_specify.u1");
  CHECK(scan_all(vpi_iterate(vpiModPath, u), paths, 4) == 2, "u1 declares two module paths");
  CHECK(scan_all(vpi_iterate(vpiModPathIn, paths[0]), ins, 2) == 1 &&
        strcmp(vpi_get_str(vpiName, vpi_handle(vpiExpr, ins[0])), "a") == 0, "path 1 is (a => y)");

  for (k = 0; k < 18; k++) {
    da[k].type = vpiScaledRealTime;
    da[k].real = v[k];
  }
  dl.da = da;
  dl.no_of_delays = 2;
  dl.time_type = vpiScaledRealTime;
  dl.mtm_flag = 1;
  dl.append_flag = 0;
  dl.pulsere_flag = 1;
  vpi_put_delays(paths[0], &dl);
  expect_no_error("vpi_put_delays(path 1, 2, mtm_flag, pulsere_flag)");

  for (k = 0; k < 18; k++) da[k].real = -1.0;
  vpi_get_delays(paths[0], &dl);
  expect_no_error("vpi_get_delays(path 1, 2, mtm_flag, pulsere_flag)");
  for (k = 0; k < 18; k++)
    CHECK(da[k].real == v[k], "12.29 Table 12-5: a put's delays, reject and error limits read back in order: da[%d] is %.17g, want %.17g",
          k, da[k].real, v[k]);

  p02_done("b7_pulse_limits");
  return 0;
}

static void setup(void)
{
  static s_cb_data cb;
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = walk;
  CHECK(vpi_register_cb(&cb) != NULL, "cbEndOfCompile registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
