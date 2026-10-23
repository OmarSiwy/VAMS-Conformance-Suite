/* p04 07 — the behavioural diagrams, walked over behaviour.v:
 * 11.6.3 (scope, task, function, io decl), 11.6.10 (named event), 11.6.16
 * (task and function call), 11.6.17 (continuous assignment), 11.6.18/11.6.19
 * (expressions), 11.6.21 (process, block, statement, event statement),
 * 11.6.22 (assignment, delay/event control; while, repeat, wait, for),
 * 11.6.23 (if, if-else, case), 11.6.24 (assign stmt, deassign, force,
 * release, disable), and 12.11's vpi_get_delays() on the two objects those
 * diagrams give delays: the continuous assignment and the delay control.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * Read off behaviour.v's source, statement by statement (its header
 * numbers them 0-18). The §11.5.3 key turns each arrow into a call: a single
 * arrow is vpi_handle(tag, ref), a double arrow vpi_iterate(tag, ref).
 *
 *   module ->> process: the four initial/always constructs, in source order —
 *     initial (mem setup), initial : main, always, initial #10 — so types
 *     vpiInitial, vpiInitial, vpiAlways, vpiInitial.
 *   process -> stmt: main's is the named begin `main` (vpiNamedBegin, with
 *     11.6.3's vpiName "main" and vpiFullName "p04_behaviour.main"), and
 *     named begin ->> stmt yields its 19 statements in order. main is in
 *     the module; its statements are in main (stmt -> scope, 11.6.3's scope
 *     class holding the named begin).
 *   11.6.18: "simple expr" is the class of nets, regs, variables, parameters,
 *     memories and their words — an identifier in an expression IS that
 *     object, so statement 0's vpiLhs compares equal to the reg `a` found by
 *     name, and statement 9's rhs mem[1] to vpi_handle_by_index(mem, 1).
 *   Statement 0 `a = 4'd9`: vpiAssignment, vpiBlocking TRUE, rhs a constant
 *     reading 9; no intra-assignment control, so vpiDelayControl and
 *     vpiEventControl are NULL — drawn, absent, no error.
 *   Statement 1 `b = #1 a`: assignment -> delay control whose vpiDelay is the
 *     unsized decimal constant 1 (vpiConstType vpiDecConst), and whose
 *     vpiStmt is NULL: 11.6.22 NOTE "For delay control and event control
 *     associated with assignment, the statement shall always be NULL."
 *   Statement 2 `#2 c = a + b`: a delay control over the assignment; its
 *     rhs is an operation, vpiOpType vpiAddOp, operands a then b.
 *   Statement 3 is if-else (vpiIfElse, condition vpiEqOp); statement 4 an
 *     if with no else (vpiIf), which draws no vpiElseStmt at all.
 *   Statement 5, the case: vpiCaseType vpiCaseExact (a plain `case`), two
 *     items. 11.6.23 NOTE 1: "The case item shall group all case conditions
 *     which branch to the same statement" — so `4'd1, 4'd2:` is ONE item
 *     with two expressions. NOTE 2: "vpi_iterate() shall return NULL for the
 *     default case item since there is no expression with the default case."
 *   Statements 6-9: for (init, condition vpiLtOp, increment, body), while
 *     (vpiGtOp), repeat (condition the constant 2; body's rhs vpiBitNegOp),
 *     wait (vpiEqOp).
 *   Statements 10-13: force and assign stmt draw vpiLhs and vpiRhs;
 *     release and deassign draw only vpiLhs.
 *   14 `-> go`: event stmt -> named event, the module's one named event.
 *   15 `bump(4'd1)`: task call -> task bump, one argument. 16's rhs is a
 *     func call to twice, one argument (d). 17 is the system task call
 *     $display: vpiName "$display", two arguments, the first a string
 *     constant (vpiStringConst) reading the format; vpiUserDefn FALSE and
 *     vpi_handle(vpiUserSystf) NULL, because no application registered
 *     $display (11.6.16 NOTE 3).
 *   18 `disable main`: disable -> vpiScope, the named begin itself.
 *   always: event control, condition a vpiPosedgeOp operation over clk,
 *     statement a NONblocking assignment (vpiBlocking FALSE) whose rhs is
 *     {2{a[1:0]}} — vpiMultiConcatOp, and by 11.6.19's NOTE its first
 *     operand is the multiplier 2. The NOTE stops there; IEEE 1364-2005
 *     §26.6.26 a), whose Annex G numbering the VPI uses, goes on: "The
 *     remaining operands shall be the expressions within the concatenation"
 *     (A.8.1 multiple_concatenation ::= { constant_expression concatenation
 *     }), so the second and last operand is the part select a[1:0]:
 *     vpiParent a, vpiLeftRange 1, vpiRightRange 0.
 *   11.6.3: module ->> task and ->> function, one each; bump ->> io decl is
 *     `input [3:0] by` (vpiInput, size 4), twice's is `input [7:0] v`
 *     (size 8); each -> stmt is its body.
 *   11.6.17: module ->> cont assign, one: vpiLhs the net w, vpiRhs a
 *     vpiBitAndOp over a and b. 11.6.17 draws vpiDelay to an expr; IEEE
 *     1364-2005 §26.3.4 says which: "an operation if there are more than one
 *     delay specified ... the operation's vpiOpType shall be vpiListOp", so
 *     #(2,3) is a vpiListOp over two operands.
 *   12.11 over `assign #(2,3)`: under `timescale 1ns/1ns the module's unit
 *     and the simulation tick are both 1 ns, so vpiScaledRealTime gives 2.0
 *     and 3.0 and vpiSimTime gives low = 2, 3. A third delay (turn-off) is
 *     not written, and IEEE 1364 §7.14 derives it as the smaller of rise and
 *     fall: 2. With mtm_flag the one value fills min, typ and max (Table
 *     12-3: 3 * no_of_delays elements); with pulsere_flag the delay, reject
 *     and error limits, which for an inertial delay are the delay itself.
 *     Statement 2's delay control reads back its one delay, 2.0.
 *
 * REFUSALS, each a relationship or property the class's diagram does not
 * draw, or an argument 12.11 rules out — NULL / vpiUndefined plus the 12.2
 * error:
 *   11.6.3   a task has no vpiDirection (its io decls do)
 *   11.6.16  a system task call draws no vpiOperand (that is an operation's)
 *   11.6.17  a continuous assignment draws no vpiCondition
 *   11.6.18  a reg draws no vpiParent (a select does)
 *   11.6.19  an operation has no vpiConstType, and no scope arrow leaves it
 *   11.6.21  an assignment is not a block: no vpiStmt set
 *   11.6.22  an assignment draws no vpiCondition
 *   11.6.23  a vpiIf draws no vpiElseStmt
 *   11.6.24  a release draws no vpiRhs
 *   12.11    no_of_delays 4 on a continuous assignment (at most rise, fall,
 *            turn-off), 2 on a delay control (one delay), a NULL da, and a
 *            reg, which has no delays
 */

//! lrm 11.6.3
//! lrm-reject 11.6.3
//! lrm 11.6.10
//! lrm 11.6.16
//! lrm-reject 11.6.16
//! lrm 11.6.17
//! lrm-reject 11.6.17
//! lrm 11.6.18
//! lrm-reject 11.6.18
//! lrm 11.6.19
//! lrm-reject 11.6.19
//! lrm 11.6.21
//! lrm-reject 11.6.21
//! lrm 11.6.22
//! lrm-reject 11.6.22
//! lrm 11.6.23
//! lrm-reject 11.6.23
//! lrm 11.6.24
//! lrm-reject 11.6.24
//! lrm 12.11
//! lrm-reject 12.11
//! lrm 12.16
//! lrm 12.19
//! lrm 12.23
//! lrm 11.6.17:1000
//! lrm 11.6.21:1000
//! lrm 11.6.24:1000
//! lrm 12.11:1
//! lrm 12.11:2
//! lrm 12.11:4
//! lrm 12.11:5
//! lrm 12.11:6
//! lrm 12.11:12
//! lrm 12.11:13
//! lrm 12.11:14
//! design behaviour.v
//! stdout p02: p04_07_behaviour_objects checks=240
//! stdout p04_behaviour: d=12

#include "p02_check.h"

static vpiHandle top;

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

static vpiHandle one(PLI_INT32 tag, vpiHandle ref, PLI_INT32 want_type, const char *what)
{
  vpiHandle h = vpi_handle(tag, ref);
  CHECK(h != NULL, "%s: vpi_handle(%d) is NULL", what, (int)tag);
  CHECK(vpi_get(vpiType, h) == want_type, "%s: type %d, want %d", what, (int)vpi_get(vpiType, h), (int)want_type);
  return h;
}

static int same(vpiHandle a, const char *name)
{
  return vpi_compare_objects(a, p02_by_name(name));
}

static int int_value(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  return (int)v.value.integer;
}

static void operation(vpiHandle h, PLI_INT32 op, int operands, const char *what)
{
  vpiHandle got[4];
  CHECK(vpi_get(vpiType, h) == vpiOperation, "%s is an operation", what);
  CHECK(vpi_get(vpiOpType, h) == op, "%s: vpiOpType %d, want %d", what, (int)vpi_get(vpiOpType, h), (int)op);
  CHECK(scan_all(vpi_iterate(vpiOperand, h), got, 4) == operands, "%s has %d operands", what, operands);
}

static void declarations(void)
{
  vpiHandle got[8], io[4];
  s_vpi_delay dl;
  s_vpi_time da[9];
  vpiHandle ca, rhs;
  int k;

  CHECK(scan_all(vpi_iterate(vpiNamedEvent, top), got, 8) == 1, "one named event");
  CHECK(strcmp(vpi_get_str(vpiName, got[0]), "go") == 0 && strcmp(vpi_get_str(vpiFullName, got[0]), "p04_behaviour.go") == 0, "the event go");
  CHECK(vpi_get(vpiType, got[0]) == vpiNamedEvent, "go is a vpiNamedEvent");

  /* 11.6.3 */
  CHECK(scan_all(vpi_iterate(vpiTask, top), got, 8) == 1 && strcmp(vpi_get_str(vpiName, got[0]), "bump") == 0, "one task, bump");
  CHECK(vpi_get(vpiType, got[0]) == vpiTask, "bump is a vpiTask");
  CHECK(scan_all(vpi_iterate(vpiIODecl, got[0]), io, 4) == 1, "bump has one io decl");
  CHECK(strcmp(vpi_get_str(vpiName, io[0]), "by") == 0, "named by");
  CHECK(vpi_get(vpiDirection, io[0]) == vpiInput && vpi_get(vpiSize, io[0]) == 4, "input [3:0]");
  one(vpiStmt, got[0], vpiAssignment, "bump's body");
  CHECK(vpi_get(vpiDirection, got[0]) == vpiUndefined, "11.6.3: a task has no vpiDirection");
  expect_error("vpi_get(vpiDirection, task)");
  CHECK(scan_all(vpi_iterate(vpiFunction, top), got, 8) == 1 && strcmp(vpi_get_str(vpiName, got[0]), "twice") == 0, "one function, twice");
  CHECK(scan_all(vpi_iterate(vpiIODecl, got[0]), io, 4) == 1 && vpi_get(vpiSize, io[0]) == 8, "twice's input [7:0] v");

  /* 11.6.17 */
  CHECK(scan_all(vpi_iterate(vpiContAssign, top), got, 8) == 1, "one continuous assignment");
  ca = got[0];
  CHECK(vpi_get(vpiType, ca) == vpiContAssign, "a vpiContAssign");
  CHECK(same(vpi_handle(vpiLhs, ca), "p04_behaviour.w"), "its lhs is the net w");
  rhs = vpi_handle(vpiRhs, ca);
  operation(rhs, vpiBitAndOp, 2, "a & b");
  CHECK(scan_all(vpi_iterate(vpiOperand, rhs), got, 8) == 2 && same(got[0], "p04_behaviour.a") && same(got[1], "p04_behaviour.b"),
        "whose operands are the regs a and b");
  operation(vpi_handle(vpiDelay, ca), vpiListOp, 2, "IEEE 1364-2005 §26.3.4: vpiDelay of #(2,3)");
  CHECK(vpi_handle(vpiCondition, ca) == NULL, "11.6.17: no vpiCondition");
  expect_error("vpi_handle(vpiCondition, cont assign)");

  /* 12.11 */
  memset(&dl, 0, sizeof dl);
  dl.da = da;
  dl.no_of_delays = 2;
  dl.time_type = vpiScaledRealTime;
  vpi_get_delays(ca, &dl);
  expect_no_error("vpi_get_delays(2, scaled)");
  CHECK(da[0].real == 2.0 && da[1].real == 3.0, "rise 2, fall 3, got %g %g", da[0].real, da[1].real);
  dl.no_of_delays = 3;
  dl.time_type = vpiSimTime;
  vpi_get_delays(ca, &dl);
  CHECK(da[0].low == 2 && da[0].high == 0 && da[1].low == 3 && da[2].low == 2, "in ticks 2, 3, and the derived turn-off 2");
  dl.no_of_delays = 1;
  dl.time_type = vpiScaledRealTime;
  dl.mtm_flag = 1;
  vpi_get_delays(ca, &dl);
  for (k = 0; k < 3; k++) CHECK(da[k].real == 2.0, "mtm: min/typ/max of rise are 2");
  dl.mtm_flag = 0;
  dl.pulsere_flag = 1;
  dl.no_of_delays = 2;
  vpi_get_delays(ca, &dl);
  CHECK(da[0].real == 2.0 && da[1].real == 2.0 && da[2].real == 2.0 && da[3].real == 3.0 && da[5].real == 3.0,
        "pulsere: delay, reject, error for each of rise and fall");
  expect_no_error("vpi_get_delays(pulsere)");
  dl.pulsere_flag = 0;
  dl.no_of_delays = 4;
  vpi_get_delays(ca, &dl);
  expect_error("vpi_get_delays(no_of_delays 4)");
  dl.no_of_delays = 1;
  dl.da = NULL;
  vpi_get_delays(ca, &dl);
  expect_error("vpi_get_delays(da NULL)");
  dl.da = da;
  vpi_get_delays(p02_by_name("p04_behaviour.a"), &dl);
  expect_error("vpi_get_delays(reg)");
}

static void main_block(vpiHandle blk)
{
  vpiHandle s[24], got[8], x, y;
  s_vpi_value v;
  s_vpi_delay dl;
  s_vpi_time da[1];
  int n, k;

  CHECK(vpi_get(vpiType, blk) == vpiNamedBegin, "main is a named begin");
  CHECK(strcmp(vpi_get_str(vpiName, blk), "main") == 0 && strcmp(vpi_get_str(vpiFullName, blk), "p04_behaviour.main") == 0,
        "11.6.3: the named begin's names");
  n = scan_all(vpi_iterate(vpiStmt, blk), s, 24);
  CHECK(n == 19, "main holds 19 statements, got %d", n);
  /* 11.6.21 stmt -> scope: 11.6.3's scope class holds the named begin, so a
   * statement of main is in main (IEEE 1364-2005 §12.5: a named begin-end
   * block "defines a new hierarchical level, or scope"). Not for 18: a
   * disable's vpiScope is the scope it disables (11.6.24), checked below. */
  for (k = 0; k < 18; k++) CHECK(vpi_compare_objects(vpi_handle(vpiScope, s[k]), blk), "stmt %d -> scope is main", k);
  CHECK(vpi_compare_objects(vpi_handle(vpiScope, blk), top), "main -> scope is the module");

  /* 0 */
  CHECK(vpi_get(vpiType, s[0]) == vpiAssignment && vpi_get(vpiBlocking, s[0]) == 1, "0: a blocking assignment");
  CHECK(same(vpi_handle(vpiLhs, s[0]), "p04_behaviour.a"), "0: its lhs IS the reg a (11.6.18)");
  x = one(vpiRhs, s[0], vpiConstant, "0: rhs");
  CHECK(int_value(x) == 9, "0: the constant 4'd9 reads 9");
  CHECK(vpi_handle(vpiDelayControl, s[0]) == NULL && vpi_handle(vpiEventControl, s[0]) == NULL, "0: no intra control");
  expect_no_error("vpi_handle(vpiDelayControl) — drawn, absent");
  CHECK(vpi_iterate(vpiStmt, s[0]) == NULL, "11.6.21: an assignment is not a block");
  expect_error("vpi_iterate(vpiStmt, assignment)");
  CHECK(vpi_handle(vpiCondition, s[0]) == NULL, "11.6.22: an assignment has no condition");
  expect_error("vpi_handle(vpiCondition, assignment)");

  /* 1 */
  x = one(vpiDelayControl, s[1], vpiDelayControl, "1: intra delay");
  y = one(vpiDelay, x, vpiConstant, "1: its delay");
  CHECK(int_value(y) == 1 && vpi_get(vpiConstType, y) == vpiDecConst, "1: the unsized decimal 1");
  CHECK(vpi_handle(vpiStmt, x) == NULL, "11.6.22 NOTE: an assignment's delay control has a NULL statement");
  expect_no_error("vpi_handle(vpiStmt, intra delay control)");

  /* 2 */
  CHECK(vpi_get(vpiType, s[2]) == vpiDelayControl, "2: a delay control");
  CHECK(int_value(vpi_handle(vpiDelay, s[2])) == 2, "2: #2");
  memset(&dl, 0, sizeof dl);
  dl.da = da;
  dl.no_of_delays = 1;
  dl.time_type = vpiScaledRealTime;
  vpi_get_delays(s[2], &dl);
  CHECK(da[0].real == 2.0, "12.11: the delay control's delay is 2");
  dl.no_of_delays = 2;
  vpi_get_delays(s[2], &dl);
  expect_error("vpi_get_delays(delay control, 2)");
  x = one(vpiStmt, s[2], vpiAssignment, "2: its statement");
  operation(vpi_handle(vpiRhs, x), vpiAddOp, 2, "2: a + b");

  /* 3, 4 */
  CHECK(vpi_get(vpiType, s[3]) == vpiIfElse, "3: if-else");
  operation(vpi_handle(vpiCondition, s[3]), vpiEqOp, 2, "3: a == 4'd9");
  one(vpiStmt, s[3], vpiAssignment, "3: then");
  one(vpiElseStmt, s[3], vpiAssignment, "3: else");
  CHECK(vpi_get(vpiType, s[4]) == vpiIf, "4: if");
  CHECK(same(vpi_handle(vpiCondition, s[4]), "p04_behaviour.c"), "4: the condition is c itself");
  CHECK(vpi_handle(vpiElseStmt, s[4]) == NULL, "11.6.23: a vpiIf draws no else");
  expect_error("vpi_handle(vpiElseStmt, if)");

  /* 5 */
  CHECK(vpi_get(vpiType, s[5]) == vpiCase && vpi_get(vpiCaseType, s[5]) == vpiCaseExact, "5: a plain case");
  CHECK(same(vpi_handle(vpiCondition, s[5]), "p04_behaviour.a"), "5: on a");
  CHECK(scan_all(vpi_iterate(vpiCaseItem, s[5]), got, 8) == 2, "5: two case items");
  CHECK(vpi_get(vpiType, got[0]) == vpiCaseItem, "a vpiCaseItem");
  {
    vpiHandle e[4];
    CHECK(scan_all(vpi_iterate(vpiExpr, got[0]), e, 4) == 2 && int_value(e[0]) == 1 && int_value(e[1]) == 2,
          "NOTE 1: one item groups 4'd1 and 4'd2");
  }
  CHECK(vpi_iterate(vpiExpr, got[1]) == NULL, "NOTE 2: the default item has no expression");
  expect_no_error("vpi_iterate(vpiExpr, default)");
  one(vpiStmt, got[1], vpiAssignment, "5: default's statement");

  /* 6-9 */
  CHECK(vpi_get(vpiType, s[6]) == vpiFor, "6: for");
  one(vpiForInitStmt, s[6], vpiAssignment, "6: init");
  operation(vpi_handle(vpiCondition, s[6]), vpiLtOp, 2, "6: i < 3");
  one(vpiForIncStmt, s[6], vpiAssignment, "6: increment");
  one(vpiStmt, s[6], vpiAssignment, "6: body");
  CHECK(vpi_get(vpiType, s[7]) == vpiWhile, "7: while");
  operation(vpi_handle(vpiCondition, s[7]), vpiGtOp, 2, "7: i > 0");
  CHECK(vpi_get(vpiType, s[8]) == vpiRepeat, "8: repeat");
  CHECK(int_value(vpi_handle(vpiCondition, s[8])) == 2, "8: twice");
  operation(vpi_handle(vpiRhs, vpi_handle(vpiStmt, s[8])), vpiBitNegOp, 1, "8: ~clk");
  CHECK(vpi_get(vpiType, s[9]) == vpiWait, "9: wait");
  x = vpi_handle(vpiRhs, vpi_handle(vpiStmt, s[9]));
  CHECK(vpi_compare_objects(x, vpi_handle_by_index(p02_by_name("p04_behaviour.mem"), 1)), "9: mem[1] IS the memory word (11.6.18)");

  /* 10-13 */
  CHECK(vpi_get(vpiType, s[10]) == vpiForce && same(vpi_handle(vpiLhs, s[10]), "p04_behaviour.w"), "10: force w");
  CHECK(int_value(vpi_handle(vpiRhs, s[10])) == 0, "10: to 0");
  CHECK(vpi_get(vpiType, s[11]) == vpiRelease && same(vpi_handle(vpiLhs, s[11]), "p04_behaviour.w"), "11: release w");
  CHECK(vpi_handle(vpiRhs, s[11]) == NULL, "11.6.24: a release draws no vpiRhs");
  expect_error("vpi_handle(vpiRhs, release)");
  CHECK(vpi_get(vpiType, s[12]) == vpiAssignStmt && int_value(vpi_handle(vpiRhs, s[12])) == 5, "12: assign e = 5");
  CHECK(vpi_get(vpiType, s[13]) == vpiDeassign && same(vpi_handle(vpiLhs, s[13]), "p04_behaviour.e"), "13: deassign e");

  /* 14-18 */
  CHECK(vpi_get(vpiType, s[14]) == vpiEventStmt && same(vpi_handle(vpiNamedEvent, s[14]), "p04_behaviour.go"), "14: -> go");
  CHECK(vpi_get(vpiType, s[15]) == vpiTaskCall && same(vpi_handle(vpiTask, s[15]), "p04_behaviour.bump"), "15: bump(...)");
  CHECK(scan_all(vpi_iterate(vpiArgument, s[15]), got, 8) == 1 && int_value(got[0]) == 1, "15: one argument, 1");
  x = one(vpiRhs, s[16], vpiFuncCall, "16: twice(d)");
  CHECK(strcmp(vpi_get_str(vpiName, x), "twice") == 0 && same(vpi_handle(vpiFunction, x), "p04_behaviour.twice"), "16: calls twice");
  CHECK(scan_all(vpi_iterate(vpiArgument, x), got, 8) == 1 && same(got[0], "p04_behaviour.d"), "16: of d");
  CHECK(vpi_get(vpiType, s[17]) == vpiSysTaskCall && strcmp(vpi_get_str(vpiName, s[17]), "$display") == 0, "17: $display");
  CHECK(vpi_get(vpiUserDefn, s[17]) == 0, "17: not a user systf");
  CHECK(vpi_handle(vpiUserSystf, s[17]) == NULL, "17: so no systf object");
  expect_no_error("vpi_handle(vpiUserSystf, built-in call)");
  CHECK(scan_all(vpi_iterate(vpiArgument, s[17]), got, 8) == 2, "17: two arguments");
  CHECK(vpi_get(vpiConstType, got[0]) == vpiStringConst, "17: a string constant");
  v.format = vpiStringVal;
  vpi_get_value(got[0], &v);
  CHECK_STR(v.value.str, "p04_behaviour: d=%0d", "17: the format");
  CHECK(vpi_iterate(vpiOperand, s[17]) == NULL, "11.6.16: a call has no operands");
  expect_error("vpi_iterate(vpiOperand, sys task call)");
  CHECK(vpi_get(vpiType, s[18]) == vpiDisable && vpi_compare_objects(vpi_handle(vpiScope, s[18]), blk), "18: disable main");
}

static void always_block(vpiHandle ev)
{
  vpiHandle a, rhs, ops[4];
  CHECK(vpi_get(vpiType, ev) == vpiEventControl, "the always body is an event control");
  operation(vpi_handle(vpiCondition, ev), vpiPosedgeOp, 1, "posedge clk");
  a = one(vpiStmt, ev, vpiAssignment, "q <= ...");
  CHECK(vpi_get(vpiBlocking, a) == 0, "a nonblocking assignment");
  rhs = vpi_handle(vpiRhs, a);
  operation(rhs, vpiMultiConcatOp, 2, "{2{a[1:0]}}");
  scan_all(vpi_iterate(vpiOperand, rhs), ops, 4);
  CHECK(int_value(ops[0]) == 2, "11.6.19 NOTE: the first operand is the multiplier");
  ops[0] = ops[1];
  CHECK(vpi_get(vpiType, ops[0]) == vpiPartSelect, "then the expression within the concatenation, the part select");
  CHECK(same(vpi_handle(vpiParent, ops[0]), "p04_behaviour.a"), "of a");
  CHECK(int_value(vpi_handle(vpiLeftRange, ops[0])) == 1 && int_value(vpi_handle(vpiRightRange, ops[0])) == 0, "[1:0]");
  CHECK(vpi_get(vpiConstType, rhs) == vpiUndefined, "11.6.19: an operation has no vpiConstType");
  expect_error("vpi_get(vpiConstType, operation)");
  CHECK(vpi_handle(vpiScope, rhs) == NULL, "11.6.19: no scope arrow leaves an expression");
  expect_error("vpi_handle(vpiScope, operation)");
  CHECK(vpi_handle(vpiParent, p02_by_name("p04_behaviour.a")) == NULL, "11.6.18: a reg draws no vpiParent");
  expect_error("vpi_handle(vpiParent, reg)");
}

static PLI_INT32 walk(p_cb_data cb_data)
{
  vpiHandle procs[8];
  int n;
  (void)cb_data;
  top = p02_by_name("p04_behaviour");
  declarations();
  n = scan_all(vpi_iterate(vpiProcess, top), procs, 8);
  CHECK(n == 4, "four processes, got %d", n);
  CHECK(vpi_get(vpiType, procs[0]) == vpiInitial && vpi_get(vpiType, procs[1]) == vpiInitial &&
        vpi_get(vpiType, procs[2]) == vpiAlways && vpi_get(vpiType, procs[3]) == vpiInitial,
        "initial, initial, always, initial");
  main_block(vpi_handle(vpiStmt, procs[1]));
  always_block(vpi_handle(vpiStmt, procs[2]));
  p02_done("p04_07_behaviour_objects");
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
