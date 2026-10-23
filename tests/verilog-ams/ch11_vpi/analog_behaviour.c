/* p04 08 — the analog half of the behavioural diagrams over analog_object_relations.va:
 * 11.6.21's `analog` process, 11.6.20 (contribs), 11.6.19's accessfunc, and
 * 11.6.16's system task call with a user-defined name (NOTE 3).
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * analog_object_relations.va has one analog block, a begin-end of six statements:
 *   0, 1  `CHECK(...) — check.vh expands each to one $strobe call with five
 *         arguments (the format, the name, got, want, the comparison);
 *   2     $p04_tap(Vp(b1), 2.5);
 *   3     Ip(b1) <+ Vp(b1) / 1k;
 *   4     Ip(b2) <+ Vp(b2) / 1k;
 *   5     Ip(f)  <+ Vp(f) / 1k;
 * so module ->> process yields one process of type vpiAnalog (11.6.21 lists
 * `analog` beside initial and always), whose vpiStmt is an unnamed vpiBegin
 * holding six statements.
 *
 * 11.6.16. $strobe is built in: vpiUserDefn FALSE. $p04_tap is registered by
 * this application's startup routine with vpi_register_analog_systf() before
 * the object model is asked anything, so its call's vpiUserDefn is TRUE and,
 * NOTE 3, "the properties of the corresponding systf object shall be obtained
 * via vpi_get_systf_info()" — the analog twin here, vpi_get_analog_systf_info,
 * through vpi_handle(vpiUserSystf, call), which must be the very handle the
 * registration returned. Its arguments (tf call ->> vpiArgument) are the
 * accessfunc Vp(b1) and the real constant 2.5 (vpiRealConst, reads 2.5).
 *
 * 11.6.19 accessfunc -> branches, discipline: Vp(b1) names the declared
 * branch b1, whose discipline is p04_elec, and the accessfunc's discipline is
 * the very discipline object its branch has (5.4.1: "The name of the access
 * function is taken from the discipline of the net, port, or branch associated
 * with the signal"). The diagram gives an accessfunc those two relations and
 * the expr class's size and value, and no vpiName, so its name is not asserted
 * (reconciler, 2026-10-08: an earlier revision asserted vpiName == "Vp", a
 * property 11.6.19 does not draw; the check that replaced it keeps the count).
 *
 * 11.6.20. Statement 3 contributes to b1 with the `<+` operator, so it is a
 * direct contribution (vpiDirect TRUE), and Ip is p04_elec's FLOW access
 * (p04_amp's `access = Ip`), so vpiFlow is TRUE; contrib -> branches is b1,
 * and its vpiRhs is the division Vp(b1) / 1k: vpiDivOp over the accessfunc
 * and the real constant 1000.0 (§2.6.2: 1k is 1e3). Statement 4 is the same
 * over b2.
 *
 * REFUSALS: a direct contribution draws no vpiLhs (only the indirect members
 * of the class do, 11.6.20) and has no vpiBlocking (an assignment's); an
 * accessfunc has no vpiOpType (an operation's); the analog process draws no
 * vpiCondition.
 */

//! lrm 11.6.16
//! lrm 11.6.19
//! lrm 11.6.20
//! lrm-reject 11.6.20
//! lrm 11.6.21
//! lrm 12.13
//! lrm 12.32
//! lrm 12.33.2
//! lrm 11.6.20:1000
//! lrm 11.6.21:1000
//! lrm 12.32:1
//! design analog_object_relations.va
//! stdout p02: p04_08_analog_behaviour checks=76

#include "p02_check.h"

static vpiHandle tap_reg;

static PLI_INT32 tap_calltf(p_cb_data d) { (void)d; return 0; }

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

static void accessfunc(vpiHandle h, const char *branch)
{
  CHECK(vpi_get(vpiType, h) == vpiAccessFunc, "an accessfunc");
  CHECK(vpi_compare_objects(vpi_handle(vpiBranch, h), p02_by_name(branch)), "applied to %s", branch);
  CHECK(vpi_compare_objects(vpi_handle(vpiDiscipline, h), vpi_handle(vpiDiscipline, vpi_handle(vpiBranch, h))),
        "5.4.1: its discipline is its branch's");
  CHECK(strcmp(vpi_get_str(vpiName, vpi_handle(vpiDiscipline, h)), "p04_elec") == 0, "of discipline p04_elec");
}

static void contribution(vpiHandle c, const char *branch)
{
  vpiHandle rhs, ops[4];
  s_vpi_value v;
  CHECK(vpi_get(vpiType, c) == vpiContrib, "a contribution");
  CHECK(vpi_get(vpiDirect, c) == 1, "made with <+, so direct");
  CHECK(vpi_get(vpiFlow, c) == 1, "to Ip, the flow access, so a flow contribution");
  CHECK(vpi_compare_objects(vpi_handle(vpiBranch, c), p02_by_name(branch)), "contrib -> branch is %s", branch);
  rhs = vpi_handle(vpiRhs, c);
  CHECK(vpi_get(vpiType, rhs) == vpiOperation && vpi_get(vpiOpType, rhs) == vpiDivOp, "the rhs is a division");
  CHECK(scan_all(vpi_iterate(vpiOperand, rhs), ops, 4) == 2, "of two operands");
  accessfunc(ops[0], branch);
  CHECK(vpi_get(vpiConstType, ops[1]) == vpiRealConst, "1k is a real constant");
  v.format = vpiRealVal;
  vpi_get_value(ops[1], &v);
  CHECK(v.value.real == 1000.0, "2.6.2: 1k is 1000.0");
  expect_no_error("the contribution walk");
}

static void walk(void)
{
  vpiHandle top = p02_by_name("p04_analog");
  vpiHandle procs[4], s[8], args[8], blk;
  s_vpi_analog_systf_data info;
  s_vpi_value v;

  CHECK(scan_all(vpi_iterate(vpiProcess, top), procs, 4) == 1, "one process");
  CHECK(vpi_get(vpiType, procs[0]) == vpiAnalog, "an analog process");
  blk = vpi_handle(vpiStmt, procs[0]);
  CHECK(vpi_get(vpiType, blk) == vpiBegin, "whose statement is a begin-end");
  CHECK(scan_all(vpi_iterate(vpiStmt, blk), s, 8) == 6, "of six statements");
  CHECK(vpi_compare_objects(vpi_handle(vpiScope, s[3]), top), "stmt -> scope is the module");

  /* 11.6.16 */
  CHECK(vpi_get(vpiType, s[0]) == vpiSysTaskCall && strcmp(vpi_get_str(vpiName, s[0]), "$strobe") == 0, "0: $strobe");
  CHECK(vpi_get(vpiUserDefn, s[0]) == 0, "0: built in");
  CHECK(scan_all(vpi_iterate(vpiArgument, s[0]), args, 8) == 5, "0: five arguments");
  CHECK(vpi_get(vpiType, s[2]) == vpiSysTaskCall && strcmp(vpi_get_str(vpiName, s[2]), "$p04_tap") == 0, "2: $p04_tap");
  CHECK(vpi_get(vpiUserDefn, s[2]) == 1, "2: user-defined");
  CHECK(vpi_compare_objects(vpi_handle(vpiUserSystf, s[2]), tap_reg), "NOTE 3: the call leads to its registration");
  vpi_get_analog_systf_info(vpi_handle(vpiUserSystf, s[2]), &info);
  expect_no_error("vpi_get_analog_systf_info(the call's systf)");
  CHECK(strcmp(info.tfname, "$p04_tap") == 0 && info.calltf == tap_calltf, "and its registration reads back");
  CHECK(scan_all(vpi_iterate(vpiArgument, s[2]), args, 8) == 2, "2: two arguments");
  accessfunc(args[0], "p04_analog.b1");
  CHECK(vpi_get(vpiConstType, args[1]) == vpiRealConst, "2: a real constant");
  v.format = vpiRealVal;
  vpi_get_value(args[1], &v);
  CHECK(v.value.real == 2.5, "2: 2.5");

  /* 11.6.20 */
  contribution(s[3], "p04_analog.b1");
  contribution(s[4], "p04_analog.b2");
  CHECK(vpi_get(vpiType, s[5]) == vpiContrib, "5: a contribution too");

  /* refusals */
  CHECK(vpi_handle(vpiLhs, s[3]) == NULL, "11.6.20: a direct contribution draws no vpiLhs");
  expect_error("vpi_handle(vpiLhs, contrib)");
  CHECK(vpi_get(vpiBlocking, s[3]) == vpiUndefined, "11.6.20: a contribution has no vpiBlocking");
  expect_error("vpi_get(vpiBlocking, contrib)");
  CHECK(vpi_get(vpiOpType, args[0]) == vpiUndefined, "11.6.19: an accessfunc has no vpiOpType");
  expect_error("vpi_get(vpiOpType, accessfunc)");
  CHECK(vpi_handle(vpiCondition, procs[0]) == NULL, "11.6.21: a process draws no condition");
  expect_error("vpi_handle(vpiCondition, process)");
}

static void walk_and_report(void)
{
  walk();
  p02_done("p04_08_analog_behaviour");
}

static void startup(void)
{
  static s_vpi_analog_systf_data tap = {
    vpiAnalogSysTask, 0, (PLI_BYTE8 *)"$p04_tap", tap_calltf, NULL, NULL, NULL, NULL
  };
  tap_reg = vpi_register_analog_systf(&tap);
  CHECK(tap_reg != NULL, "$p04_tap registers");
  /* IEEE 1364-2005 26.2.4: the walk waits for cbEndOfCompile. */
  p02_defer(walk_and_report);
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
