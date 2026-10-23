/* b7 path delays: VAMS-2023 12.11 and 12.29 on specify.v's module paths
 * and timing check. The counts each object takes, read and put, and Table
 * 12-5's layouts on a put.
 *
 * 12.11  "For path delay objects, the no_of_delays value shall be 1, 2, 3, 6,
 *        or 12." "The user-allocated s_vpi_delay array shall contain delays
 *        in the same order in which they occur in the Verilog-AMS HDL
 *        description."
 * 12.29  "shall set the delays or timing limits of an object as indicated in
 *        the delay_p structure. The same ordering of delays shall be used as
 *        described in the vpi_get_delays() function." The same counts:
 *        "For path delay objects, the no_of_delays value shall be 1, 2, 3, 6,
 *        or 12. For timing check objects, the no_of_delays value shall match
 *        the number of limits existing in the timing check." "The number of
 *        elements for each delay shall be determined by the flags mtm_flag
 *        and pulsere_flag, as shown in Table 12-5": with mtm_flag, da[0..2]
 *        are the 1st delay's min, typ, max; with pulsere_flag, its delay,
 *        reject limit, error limit; the 2nd delay follows.
 *
 * DERIVATION (u1's objects, in declaration order; every value an integer
 * number of the module's 1 ns unit, exact in binary64, so compared with ==):
 *   path 2 (c => z) = (2, 3, 4): read 3 -> 2, 3, 4, the written order. No
 *          other count is read: which of Table 14-3's transitions a 3-delay
 *          path shows at 1, 2, 6 or 12 is IEEE 1364's, not this row's.
 *   path 1 (a => y): each put read back with the same count (1 is p06_01's):
 *          put 2 (5, 6)          -> 5, 6
 *          put 3 (5, 6, 7)       -> 5, 6, 7
 *          put 6 (11 .. 16)      -> 11 .. 16
 *          put 12 (21 .. 32)     -> 21 .. 32
 *   $setup(d, posedge clk, 5, notif): one limit; put 1 (7) -> 7.
 *   path 2, the layouts:
 *     mtm_flag, 2 delays, da = {8,8,8, 10,10,10}. Each delay's min = typ =
 *          max, so a tool that keeps only the selected one of the three still
 *          holds 8 and 10. Read with no flags: 8, 10. Read with mtm_flag:
 *          8,8,8, 10,10,10. A put that took the array as two plain delays
 *          would hold 8, 8.
 *     pulsere_flag, 2 delays, da = {9,1,2, 11,3,4} (delay, reject, error;
 *          reject <= error <= delay). Read with no flags: 9, 11. A flat read
 *          would hold 9, 1. Whether the limits read back is
 *          pulse_limits.c's question.
 */

//! lrm 12.11
//! lrm 12.29
//! lrm 12.11:9
//! lrm 12.11:12
//! lrm 12.29:9
//! lrm 12.29:10
//! lrm 12.29:13
//! design specify.v
//! stdout p02: b7_path_delays checks=60

#include "../ch11_vpi/p02_check.h"

static s_vpi_time da[18];
static s_vpi_delay dl;

static void delays(int n, int mtm, int pulse)
{
  dl.da = da;
  dl.no_of_delays = n;
  dl.time_type = vpiScaledRealTime;
  dl.mtm_flag = mtm;
  dl.append_flag = 0;
  dl.pulsere_flag = pulse;
}

/* Put `count` elements of `v` as `n` delays under the two flags. */
static void put(vpiHandle obj, int n, int mtm, int pulse, const double *v, int count, const char *what)
{
  int k;
  memset(da, 0, sizeof da);
  for (k = 0; k < count; k++) {
    da[k].type = vpiScaledRealTime;
    da[k].real = v[k];
  }
  delays(n, mtm, pulse);
  vpi_put_delays(obj, &dl);
  expect_no_error(what);
}

/* Read `n` delays under the two flags into a poisoned array. */
static void get(vpiHandle obj, int n, int mtm, int pulse, const char *what)
{
  int k;
  for (k = 0; k < 18; k++) {
    da[k].type = vpiScaledRealTime;
    da[k].real = -1.0;
  }
  delays(n, mtm, pulse);
  vpi_get_delays(obj, &dl);
  expect_no_error(what);
}

static void want(const double *v, int count, const char *what)
{
  int k;
  for (k = 0; k < count; k++)
    CHECK(da[k].real == v[k], "%s: da[%d] is %.17g, want %.17g", what, k, da[k].real, v[k]);
}

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

/* The name of a path's one input terminal's expression. */
static const char *in_name(vpiHandle path)
{
  vpiHandle ins[2];
  vpiHandle e;
  if (scan_all(vpi_iterate(vpiModPathIn, path), ins, 2) != 1) return "(not one input)";
  e = vpi_handle(vpiExpr, ins[0]);
  return e ? vpi_get_str(vpiName, e) : "(null)";
}

static PLI_INT32 walk(p_cb_data cb)
{
  static const double three[] = { 2, 3, 4 };
  static const double two[] = { 5, 6 };
  static const double three2[] = { 5, 6, 7 };
  static const double six[] = { 11, 12, 13, 14, 15, 16 };
  static const double twelve[] = { 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32 };
  static const double seven[] = { 7 };
  static const double mtm[] = { 8, 8, 8, 10, 10, 10 };
  static const double plain_mtm[] = { 8, 10 };
  static const double pulse[] = { 9, 1, 2, 11, 3, 4 };
  static const double plain_pulse[] = { 9, 11 };
  vpiHandle u, paths[4], tchks[2];
  (void)cb;

  u = p02_by_name("b7_specify.u1");
  CHECK(scan_all(vpi_iterate(vpiModPath, u), paths, 4) == 2, "u1 declares two module paths");
  CHECK(scan_all(vpi_iterate(vpiTchk, u), tchks, 2) == 1, "u1 declares one timing check");
  CHECK(strcmp(in_name(paths[0]), "a") == 0, "path 1 is (a => y), got input %s", in_name(paths[0]));
  CHECK(strcmp(in_name(paths[1]), "c") == 0, "path 2 is (c => z), got input %s", in_name(paths[1]));

  /* 12.11:9 and 12.11:12 */
  get(paths[1], 3, 0, 0, "vpi_get_delays(path 2, 3)");
  want(three, 3, "12.11: (c => z) = (2, 3, 4) read as 3 delays");

  /* 12.29:9 */
  put(paths[0], 2, 0, 0, two, 2, "vpi_put_delays(path 1, 2)");
  get(paths[0], 2, 0, 0, "vpi_get_delays(path 1, 2)");
  want(two, 2, "12.29: path 1 put 2 delays");
  put(paths[0], 3, 0, 0, three2, 3, "vpi_put_delays(path 1, 3)");
  get(paths[0], 3, 0, 0, "vpi_get_delays(path 1, 3)");
  want(three2, 3, "12.29: path 1 put 3 delays");
  put(paths[0], 6, 0, 0, six, 6, "vpi_put_delays(path 1, 6)");
  get(paths[0], 6, 0, 0, "vpi_get_delays(path 1, 6)");
  want(six, 6, "12.29: path 1 put 6 delays");
  put(paths[0], 12, 0, 0, twelve, 12, "vpi_put_delays(path 1, 12)");
  get(paths[0], 12, 0, 0, "vpi_get_delays(path 1, 12)");
  want(twelve, 12, "12.29: path 1 put 12 delays");

  /* 12.29:10 */
  put(tchks[0], 1, 0, 0, seven, 1, "vpi_put_delays($setup, 1)");
  get(tchks[0], 1, 0, 0, "vpi_get_delays($setup, 1)");
  want(seven, 1, "12.29: $setup's one limit put to 7");

  /* 12.29:13 */
  put(paths[1], 2, 1, 0, mtm, 6, "vpi_put_delays(path 2, 2, mtm_flag)");
  get(paths[1], 2, 0, 0, "vpi_get_delays(path 2, 2)");
  want(plain_mtm, 2, "12.29: an mtm put's delays are da[0..2] and da[3..5]");
  get(paths[1], 2, 1, 0, "vpi_get_delays(path 2, 2, mtm_flag)");
  want(mtm, 6, "12.29: an mtm put read back with mtm_flag");
  put(paths[1], 2, 0, 1, pulse, 6, "vpi_put_delays(path 2, 2, pulsere_flag)");
  get(paths[1], 2, 0, 0, "vpi_get_delays(path 2, 2) after pulsere");
  want(plain_pulse, 2, "12.29: a pulsere put's delays are da[0] and da[3]");

  p02_done("b7_path_delays");
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
