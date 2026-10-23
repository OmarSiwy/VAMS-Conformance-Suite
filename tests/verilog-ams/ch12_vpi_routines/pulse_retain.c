/* b7 pulse retain: VAMS-2023 12.29. A put of delays alone leaves the pulse
 * limits where they were.
 *
 * 12.29  "If only the delay changes, and not the pulse limits, the pulse
 *        limits shall retain the values they had before the delays where
 *        altered." Table 12-5: with pulsere_flag each delay is (delay, reject
 *        limit, error limit); without it, the delay alone.
 *
 * DERIVATION. specify.v's u1 path (a => y), 2 delays. The limits are SET
 * first, by a put with pulsere_flag, so the values to retain are written here
 * and not any default (IEEE 1364 §14.6's PATHPULSE$ defaults never enter):
 *     put, pulsere_flag:  (6, reject 1, error 2), (7, reject 3, error 4)
 *     put, no flags:      8, 9            only the delays change
 *     get, pulsere_flag:  (8, 1, 2), (9, 3, 4)
 * The limits stay below the new delays (1 <= 2 <= 8, 3 <= 4 <= 9), so no
 * clamping question arises. Integers of the 1 ns unit, compared with ==.
 */

//! lrm 12.29:3
//! design specify.v
//! stdout p02: b7_pulse_retain checks=14

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

static s_vpi_time da[6];
static s_vpi_delay dl;

static void delays(int pulse, const double *v, int count)
{
  int k;
  for (k = 0; k < 6; k++) {
    da[k].type = vpiScaledRealTime;
    da[k].real = k < count ? v[k] : -1.0;
  }
  dl.da = da;
  dl.no_of_delays = 2;
  dl.time_type = vpiScaledRealTime;
  dl.mtm_flag = 0;
  dl.append_flag = 0;
  dl.pulsere_flag = pulse;
}

static PLI_INT32 walk(p_cb_data cb)
{
  static const double limits[6] = { 6, 1, 2, 7, 3, 4 };
  static const double plain[2] = { 8, 9 };
  static const double after[6] = { 8, 1, 2, 9, 3, 4 };
  vpiHandle u, paths[4], ins[2];
  int k;
  (void)cb;

  u = p02_by_name("b7_specify.u1");
  CHECK(scan_all(vpi_iterate(vpiModPath, u), paths, 4) == 2, "u1 declares two module paths");
  CHECK(scan_all(vpi_iterate(vpiModPathIn, paths[0]), ins, 2) == 1 &&
        strcmp(vpi_get_str(vpiName, vpi_handle(vpiExpr, ins[0])), "a") == 0, "path 1 is (a => y)");

  delays(1, limits, 6);
  vpi_put_delays(paths[0], &dl);
  expect_no_error("vpi_put_delays(path 1, 2, pulsere_flag)");
  delays(0, plain, 2);
  vpi_put_delays(paths[0], &dl);
  expect_no_error("vpi_put_delays(path 1, 2)");
  delays(1, NULL, 0);
  vpi_get_delays(paths[0], &dl);
  expect_no_error("vpi_get_delays(path 1, 2, pulsere_flag)");
  for (k = 0; k < 6; k++)
    CHECK(da[k].real == after[k], "12.29: a put of the delays alone kept the pulse limits: da[%d] is %.17g, want %.17g",
          k, da[k].real, after[k]);

  p02_done("b7_pulse_retain");
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
