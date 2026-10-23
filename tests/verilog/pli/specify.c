/* IEEE 1364-2005 §26.6.15 (module path, path term) and §26.6.17 (timing
 * check), walked over ch11_vpi/specify.v at time 0.
 *
 * §26.6.15, p. 401: module ->> mod path; mod path -> vpiCondition expr,
 *   -> vpiDelay expr, ->> vpiModPathIn / vpiModPathOut / vpiModDataPathIn
 *   path term; path term -> expr, "-> direction int: vpiDirection", "-> edge
 *   int: vpiEdge"; mod path "-> path type int: vpiPathType", "-> polarity int:
 *   vpiPolarity int: vpiDataPolarity", "-> hasIfNone bool:
 *   vpiModPathHasIfNone".
 * §26.6.17, p. 402: module ->> tchk; tchk -> vpiTchkRefTerm, vpiTchkDataTerm
 *   tchk term, -> vpiTchkNotifier regs, ->> vpiExpr expr, "-> tchk type int:
 *   vpiTchkType"; tchk term -> expr, "-> edge int: vpiEdge". Details: "a) For
 *   the timing checks in 15.1, the relationship vpiTchkRefTerm shall denote
 *   the reference_event or controlled_reference_event, while vpiTchkDataTerm
 *   shall denote the data_event, if any. b) When iterating over vpiExpr from
 *   a tchk, the handles returned for a reference_event, a
 *   controlled_reference_event, or a data_event shall have the type
 *   vpiTchkTerm. All other arguments shall have types matching the
 *   expression."
 * §26.6.25, p. 407: the simple expr class is nets, regs, variables,
 *   parameter, specparam, var select, bit select - no port.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * p06_cell (instance p06_top.u) declares `input a, b, clk, d; output y, q;
 * reg q, notif;`, so a, b, clk, d and y are implicit nets (IEEE 1364 §4.5,
 * §12.3.3).
 *
 *   path 1  (a => y) = (2, 3): vpiPathParallel; one in term, direction
 *           input, no edge (vpiNoEdge), whose expr is the net a; one out
 *           term, y; no condition (NULL); no polarity written, so (§14.2.7.1:
 *           "By default, module paths shall have unknown polarity")
 *           vpiPolarity reads vpiUnknown; no ifnone: vpiModPathHasIfNone
 *           FALSE; vpiDelay is an expression (§26.6.15 draws the arrow;
 *           §26.3.4's constant-or-vpiListOp rule is checked in
 *           behaviour.c). Its module is u. No clause fixes the order
 *           of module ->> mod path, so each path is told apart by its type
 *           and its input edge.
 *   path 2  if (b) (b *> y) = 4: vpiPathFull, with a condition.
 *   path 3  (posedge clk => (q : d)) = (1, ..., 6): in term clk with edge
 *           vpiPosedge; its vpiModDataPathIn term is d.
 *   $setup(d, posedge clk, 5, notif): vpiTchkType reads vpiSetup.
 *           Details a: the reference event posedge clk is the ref term
 *           (a vpiTchkTerm of edge vpiPosedge whose expr is the net clk),
 *           the data event d the data term; the notifier is the reg
 *           notif. Details b: vpiExpr yields its four arguments, exactly two
 *           of them (the data and reference events) vpiTchkTerm. $setup is
 *           told apart from $width by its data term.
 *   $width(posedge clk, 10): no data event, so vpiTchkDataTerm is NULL.
 *
 * REFUSALS (vpiUndefined with vpi_chk_error() nonzero): vpi_get(vpiSize, mod path) and
 * vpi_get(vpiSize, tchk) - neither diagram draws a size.
 */

//! inherited IEEE 1364-2005 26.6.15
//! inherited-reject IEEE 1364-2005 26.6.15
//! inherited IEEE 1364-2005 26.6.17
//! inherited-reject IEEE 1364-2005 26.6.17
//! design ../../verilog-ams/ch11_vpi/specify.v
//! stdout p02: b_26_6_specify checks=58

#include "b_check.h"

/* Annex G's numbers, where src/vpi/vpi_user.h lacks the name. */
#ifndef vpiModPathHasIfNone
#define vpiModPathHasIfNone 71
#endif
#ifndef vpiModDataPathIn
#define vpiModDataPathIn 94
#endif

static vpiHandle only(PLI_INT32 type, vpiHandle ref)
{
  vpiHandle itr = vpi_iterate(type, ref), h;
  CHECK(itr != NULL, "vpi_iterate(%d) returned NULL", (int)type);
  h = vpi_scan(itr);
  CHECK(h != NULL && vpi_scan(itr) == NULL, "vpi_iterate(%d) should yield exactly one", (int)type);
  return h;
}

static PLI_INT32 walk(p_cb_data cb_data)
{
  vpiHandle u = p02_by_name("p06_top.u");
  vpiHandle path[4], tchk[3], itr, h, in, out, rt, dt, e;
  int n = 0;

  (void)cb_data;

  /* §26.6.15 */
  itr = vpi_iterate(vpiModPath, u);
  CHECK(itr != NULL, "26.6.15: module ->> mod path");
  path[0] = path[1] = path[2] = NULL;
  while ((h = vpi_scan(itr)) != NULL) {
    /* no clause fixes the order: full is path 2, a posedge input path 3 */
    int k = vpi_get(vpiPathType, h) == vpiPathFull ? 1 : vpi_get(vpiEdge, only(vpiModPathIn, h)) == vpiPosedge ? 2 : 0;
    CHECK(path[k] == NULL, "26.6.15: paths 1, 2, 3 are told apart");
    path[k] = h;
    n++;
  }
  CHECK(n == 3, "26.6.15: three paths, got %d", n);
  CHECK(vpi_get(vpiPathType, path[0]) == vpiPathParallel, "26.6.15: path 1 is parallel");
  CHECK(vpi_get(vpiPathType, path[1]) == vpiPathFull, "26.6.15: path 2 is full");
  CHECK(vpi_compare_objects(vpi_handle(vpiModule, path[0]), u), "26.6.15: mod path -> module");
  in = only(vpiModPathIn, path[0]);
  out = only(vpiModPathOut, path[0]);
  CHECK(vpi_get(vpiType, in) == vpiPathTerm && vpi_get(vpiDirection, in) == vpiInput &&
        vpi_get(vpiEdge, in) == vpiNoEdge, "26.6.15: path 1's in term a, no edge");
  CHECK_STR(vpi_get_str(vpiName, vpi_handle(vpiExpr, in)), "a", "26.6.15: in term -> expr");
  CHECK_STR(vpi_get_str(vpiName, vpi_handle(vpiExpr, out)), "y", "26.6.15: out term -> expr");
  CHECK(vpi_handle(vpiCondition, path[0]) == NULL, "26.6.15: path 1 has no condition");
  CHECK(vpi_handle(vpiCondition, path[1]) != NULL, "26.6.15: path 2's if (b)");
  CHECK(vpi_get(vpiEdge, only(vpiModPathIn, path[2])) == vpiPosedge, "26.6.15: path 3's posedge clk");
  expect_no_error("the path walk");
  CHECK(vpi_get(vpiType, vpi_handle(vpiExpr, in)) == vpiNet, "26.6.15: path term -> expr is the net a");
  CHECK(vpi_get(vpiPolarity, path[0]) == vpiUnknown, "26.6.15: no polarity written is vpiUnknown");
  CHECK(vpi_get(vpiModPathHasIfNone, path[0]) == 0, "26.6.15: path 1 has no ifnone");
  e = vpi_handle(vpiDelay, path[0]);
  CHECK(e != NULL, "26.6.15: mod path -> vpiDelay");
  CHECK(vpi_handle(vpiModDataPathIn, path[2]) != NULL || vpi_iterate(vpiModDataPathIn, path[2]) != NULL,
        "26.6.15: path 3's vpiModDataPathIn");
  CHECK(vpi_get(vpiSize, path[0]) == vpiUndefined, "26.6.15: a mod path has no size");
  expect_refusal("vpi_get(vpiSize, mod path)");

  /* §26.6.17 */
  n = 0;
  itr = vpi_iterate(vpiTchk, u);
  CHECK(itr != NULL, "26.6.17: module ->> tchk");
  tchk[0] = tchk[1] = NULL;
  while ((h = vpi_scan(itr)) != NULL) {
    /* $setup has a data event, $width none */
    int k = vpi_handle(vpiTchkDataTerm, h) != NULL ? 0 : 1;
    CHECK(tchk[k] == NULL, "26.6.17: $setup and $width are told apart");
    tchk[k] = h;
    n++;
  }
  CHECK(n == 2, "26.6.17: two timing checks, got %d", n);
  rt = vpi_handle(vpiTchkRefTerm, tchk[0]);
  dt = vpi_handle(vpiTchkDataTerm, tchk[0]);
  CHECK(rt != NULL && vpi_get(vpiType, rt) == vpiTchkTerm && vpi_get(vpiEdge, rt) == vpiPosedge,
        "26.6.17 a: the reference event posedge clk");
  CHECK_STR(vpi_get_str(vpiName, vpi_handle(vpiExpr, rt)), "clk", "26.6.17: ref term -> expr");
  CHECK(dt != NULL && vpi_get(vpiType, dt) == vpiTchkTerm, "26.6.17 a: the data event");
  CHECK_STR(vpi_get_str(vpiName, vpi_handle(vpiExpr, dt)), "d", "26.6.17: data term -> expr");
  CHECK(vpi_compare_objects(vpi_handle(vpiTchkNotifier, tchk[0]), p02_by_name("p06_top.u.notif")),
        "26.6.17: the notifier");
  CHECK(vpi_handle(vpiTchkDataTerm, tchk[1]) == NULL, "26.6.17 a: $width has no data event");
  expect_no_error("the timing check walk");
  CHECK(vpi_get(vpiTchkType, tchk[0]) == vpiSetup, "26.6.17: $setup's vpiTchkType");
  CHECK(vpi_get(vpiType, vpi_handle(vpiExpr, rt)) == vpiNet, "26.6.17: tchk term -> expr is the net clk");
  {
    int args = 0, terms = 0;
    itr = vpi_iterate(vpiExpr, tchk[0]);
    if (itr != NULL)
      while ((h = vpi_scan(itr)) != NULL) {
        if (vpi_get(vpiType, h) == vpiTchkTerm) terms++;
        args++;
      }
    CHECK(args == 4 && terms == 2, "26.6.17 b: tchk ->> vpiExpr yields four arguments, two of them tchk terms");
  }
  CHECK(vpi_get(vpiSize, tchk[0]) == vpiUndefined, "26.6.17: a timing check has no size");
  expect_refusal("vpi_get(vpiSize, tchk)");

  p02_done("b_26_6_specify");
  return 0;
}

static PLI_INT32 start(p_cb_data cb_data)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data cb;
  (void)cb_data;
  cb.reason = cbReadOnlySynch;
  cb.cb_rtn = walk;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadOnlySynch(0) registration failed");
  return 0;
}

/* §26.2.4: from the startup routine only the action callbacks may be
 * registered, so the time callback is registered once simulation starts. */
static void setup(void)
{
  static s_cb_data ss;
  ss.reason = cbStartOfSimulation;
  ss.cb_rtn = start;
  CHECK(vpi_register_cb(&ss) != NULL, "cbStartOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
