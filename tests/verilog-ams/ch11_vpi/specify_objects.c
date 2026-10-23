/* p06 01 — VAMS-2023 11.6.15 "Module path, timing check, intermodule path",
 * walked over specify.v, with 12.11's and 12.29's rules for these objects.
 *
 * THE DIAGRAM, as IEEE 1364 §26.6.15 (which 11.6.15 reproduces) draws it:
 *   module ->> mod path; mod path ->> path term tagged vpiModPathIn /
 *   vpiModPathOut; path term -> expr (vpiExpr) with vpiDirection, vpiEdge;
 *   mod path -> expr tagged vpiCondition; mod path has vpiPathType,
 *   vpiPolarity, vpiDataPolarity and its delays (12.11);
 *   module ->> tchk; tchk -> tchk term tagged vpiTchkRefTerm / vpiTchkDataTerm
 *   (each -> expr, with vpiEdge); tchk -> reg tagged vpiTchkNotifier; tchk has
 *   vpiTchkType and its limits (12.11: "the no_of_delays value shall match the
 *   number of limits existing in the timing check");
 *   vpi_handle_multi(vpiInterModPath, port, port) the inter-module path.
 *
 * THE DERIVATION, off specify.v's header:
 *   path 1  (a => y) = (2, 3): parallel, in `a` no edge, out `y`, polarity
 *           unknown (none written), no condition; 2 delays read back 2, 3;
 *           6 read back IEEE 1364 §14.3.1 Table 14-3's two-value row —
 *           0->1 2, 1->0 3, 0->z 2, z->1 2, 1->z 3, z->0 3.
 *   path 2  if (b) (b *> y) = 4: full, condition present; 1 delay reads 4.
 *   path 3  (posedge clk => (q : d)) = (1..6): parallel, `clk` in with
 *           vpiPosedge; 12 read back the six and the x transitions Table 14-3
 *           derives — 0->x min(1,3)=1, x->1 max(1,4)=4, 1->x min(2,5)=2,
 *           x->0 max(2,6)=6, x->z max(5,3)=5, z->x min(4,6)=4.
 *   $setup  vpiSetup; ref term `clk` posedge; data term `d`; notifier `notif`;
 *           its one limit, 5.
 *   $width  vpiWidth; ref term `clk` posedge; NO data term; limit 10.
 *
 * REFUSALS (12.11 / 12.29 / 11.6.15):
 *   vpi_get_delays(path, 4)          "1, 2, 3, 6, or 12"
 *   vpi_get_delays($setup, 2)        "shall match the number of limits"
 *   vpi_put_delays(path, 5)          the same counts bind a put
 *   vpi_handle_multi(vpiInterModPath, a module, a net) — not ports
 *   vpi_handle_multi(vpiInterModPath, port a, port y) — ports, and no delay is
 *           annotated between them (an inter-module path is an SDF
 *           interconnect annotation; none is read), so NULL with an error.
 * And a put that IS legal: path 1 given one delay 7 reads back 7.
 */

//! lrm 11.6.15
//! lrm-reject 11.6.15
//! lrm 12.11
//! lrm-reject 12.11
//! lrm 12.29
//! lrm-reject 12.29
//! lrm 11.6.15:1000
//! lrm 12.11:7
//! lrm 12.11:10
//! design specify.v
//! stdout p02: p06_01_specify_objects checks=59

#include "p02_check.h"

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

static const char *term_name(vpiHandle term)
{
  vpiHandle e = vpi_handle(vpiExpr, term);
  return e ? vpi_get_str(vpiName, e) : "(null)";
}

static PLI_INT32 walk(p_cb_data cb)
{
  vpiHandle u, paths[4], tchks[4], ins[2], outs[2], ports[8], t;
  s_vpi_time da[12];
  s_vpi_delay dl;
  int k;
  (void)cb;

  u = p02_by_name("p06_top.u");
  CHECK(scan_all(vpi_iterate(vpiModPath, u), paths, 4) == 3, "11.6.15: three module paths");
  CHECK(scan_all(vpi_iterate(vpiTchk, u), tchks, 4) == 2, "11.6.15: two timing checks");
  for (k = 0; k < 3; k++) CHECK(vpi_get(vpiType, paths[k]) == vpiModPath, "path %d is a vpiModPath", k);

  memset(&dl, 0, sizeof dl);
  memset(da, 0, sizeof da);
  dl.da = da;
  dl.time_type = vpiScaledRealTime;

  /* path 1 */
  CHECK(vpi_get(vpiPathType, paths[0]) == vpiPathParallel, "(a => y) is parallel");
  CHECK(vpi_get(vpiPolarity, paths[0]) == vpiUnknown, "no polarity written");
  CHECK(vpi_handle(vpiCondition, paths[0]) == NULL, "no condition");
  CHECK(scan_all(vpi_iterate(vpiModPathIn, paths[0]), ins, 2) == 1 && strcmp(term_name(ins[0]), "a") == 0, "in a");
  CHECK(vpi_get(vpiDirection, ins[0]) == vpiInput && vpi_get(vpiEdge, ins[0]) == vpiNoEdge, "an input, no edge");
  CHECK(scan_all(vpi_iterate(vpiModPathOut, paths[0]), outs, 2) == 1 && strcmp(term_name(outs[0]), "y") == 0, "out y");
  dl.no_of_delays = 2;
  vpi_get_delays(paths[0], &dl);
  expect_no_error("vpi_get_delays(path 1, 2)");
  CHECK(da[0].real == 2.0 && da[1].real == 3.0, "rise 2, fall 3");
  dl.no_of_delays = 6;
  vpi_get_delays(paths[0], &dl);
  CHECK(da[0].real == 2 && da[1].real == 3 && da[2].real == 2 && da[3].real == 2 && da[4].real == 3 && da[5].real == 3,
        "Table 14-3's two-value row");

  /* path 2 */
  CHECK(vpi_get(vpiPathType, paths[1]) == vpiPathFull, "(b *> y) is full");
  CHECK(vpi_handle(vpiCondition, paths[1]) != NULL, "if (b) is its condition");
  dl.no_of_delays = 1;
  vpi_get_delays(paths[1], &dl);
  CHECK(da[0].real == 4.0, "one delay, 4");

  /* path 3 */
  CHECK(scan_all(vpi_iterate(vpiModPathIn, paths[2]), ins, 2) == 1 && strcmp(term_name(ins[0]), "clk") == 0, "in clk");
  CHECK(vpi_get(vpiEdge, ins[0]) == vpiPosedge, "on its positive edge");
  dl.no_of_delays = 12;
  vpi_get_delays(paths[2], &dl);
  for (k = 0; k < 6; k++) CHECK(da[k].real == (double)(k + 1), "transition %d is %d", k, k + 1);
  CHECK(da[6].real == 1 && da[7].real == 4 && da[8].real == 2 && da[9].real == 6 && da[10].real == 5 && da[11].real == 4,
        "the x transitions Table 14-3 derives");

  /* $setup */
  CHECK(vpi_get(vpiTchkType, tchks[0]) == vpiSetup, "$setup");
  t = vpi_handle(vpiTchkRefTerm, tchks[0]);
  CHECK(t != NULL && strcmp(term_name(t), "clk") == 0 && vpi_get(vpiEdge, t) == vpiPosedge, "reference: posedge clk");
  t = vpi_handle(vpiTchkDataTerm, tchks[0]);
  CHECK(t != NULL && strcmp(term_name(t), "d") == 0, "data: d");
  t = vpi_handle(vpiTchkNotifier, tchks[0]);
  CHECK(t != NULL && strcmp(vpi_get_str(vpiName, t), "notif") == 0, "notifier: notif");
  dl.no_of_delays = 1;
  vpi_get_delays(tchks[0], &dl);
  CHECK(da[0].real == 5.0, "its limit, 5");

  /* $width */
  CHECK(vpi_get(vpiTchkType, tchks[1]) == vpiWidth, "$width");
  CHECK(vpi_handle(vpiTchkDataTerm, tchks[1]) == NULL, "$width has no data event");
  vpi_get_delays(tchks[1], &dl);
  CHECK(da[0].real == 10.0, "its limit, 10");

  /* a legal put, read back */
  dl.no_of_delays = 1;
  da[0].type = vpiScaledRealTime;
  da[0].real = 7.0;
  vpi_put_delays(paths[0], &dl);
  expect_no_error("vpi_put_delays(path 1, 1)");
  da[0].real = -1;
  vpi_get_delays(paths[0], &dl);
  CHECK(da[0].real == 7.0, "12.29: path 1 reads back 7");

  /* refusals */
  dl.no_of_delays = 4;
  vpi_get_delays(paths[0], &dl);
  expect_error("vpi_get_delays(path, 4)");
  dl.no_of_delays = 2;
  vpi_get_delays(tchks[0], &dl);
  expect_error("vpi_get_delays($setup, 2)");
  dl.no_of_delays = 5;
  vpi_put_delays(paths[0], &dl);
  expect_error("vpi_put_delays(path, 5)");
  CHECK(vpi_handle_multi(vpiInterModPath, u, p02_by_name("p06_top.y")) == NULL, "not two ports");
  expect_error("vpi_handle_multi(vpiInterModPath, module, net)");
  CHECK(scan_all(vpi_iterate(vpiPort, u), ports, 8) == 6, "the cell's six ports");
  CHECK(vpi_handle_multi(vpiInterModPath, ports[0], ports[4]) == NULL, "no annotated inter-module path");
  expect_error("vpi_handle_multi(vpiInterModPath, a, y)");

  p02_done("p06_01_specify_objects");
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
