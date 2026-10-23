/* IEEE 1364-2005 §26.2.5, §26.3.1's illegal tag-less access, §26.3.4, and
 * the behavioural diagrams §26.6.3-§26.6.4, §26.6.18-§26.6.19,
 * §26.6.24-§26.6.30 and §26.6.32-§26.6.41, walked over behaviour.v
 * (its header numbers main's statements 0-20).
 *
 * §26.2.5, p. 377: "Expressions with multiple operands will result in a
 *   handle of type vpiOperation. To determine how many operands, access the
 *   property vpiOpType."
 * §26.3.1, p. 379: "vpi_handle(vpiExpr, part_select_handle) would be illegal
 *   when the reference handle (part_select_handle) is a handle to a
 *   part-select because the part-select can refer to two expressions, a
 *   left-range and a right-range."
 * §26.3.4, p. 380: "Nets, primitives, module paths, timing checks, and
 *   continuous assignments can have delays specified within the HDL. ... To
 *   access the delay expressions that are specified within the HDL, use the
 *   method vpiDelay. These expressions shall be either an expression that
 *   evaluates to a constant if there is only one delay specified or an
 *   operation if there are more than one delay specified. If multiple delays
 *   are specified, then the operation's vpiOpType shall be vpiListOp."
 * §26.6.3, p. 389: scope (module, task func, named begin, named fork) ->
 *   name; scope ->> vpiInternalScope scope; stmt -> vpiScope.
 * §26.6.4, p. 389: io decl -> direction int: vpiDirection, name, scalar
 *   bool: vpiScalar, sign, size int: vpiSize, vector bool: vpiVector.
 * §26.6.18, p. 402: "A Verilog HDL function shall contain an object with the
 *   same name, size, and type as the function."
 * §26.6.19, p. 403 Details: "a) The system task/function that invoked an
 *   application shall be accessed with vpi_handle(vpiSysTfCall, NULL)".
 *   p. 404: "g) The property vpiDecompile shall return a string with a
 *   functionally equivalent system task/function call to what was in the
 *   original HDL."
 * §26.6.24, p. 406: cont assign -> vpiLhs, vpiRhs, vpiDelay expr, "-> net
 *   decl assign bool: vpiNetDeclAssign", "-> value vpi_get_value()".
 * §26.6.25, p. 407: simple expr: nets, regs, variables, ... var select, bit
 *   select; "a) For vectors, the vpiUse relationship shall access any use of
 *   the vector or part-selects or bit-selects thereof."
 * §26.6.26, p. 408 Details: "a) For an operator whose type is
 *   vpiMultiConcatOp, the first operand shall be the multiplier expression.
 *   The remaining operands shall be the expressions within the
 *   concatenation. b) The property vpiDecompile shall return a string with a
 *   functionally equivalent expression to the original expression within the
 *   HDL."
 * §26.6.27, p. 409: module ->> process (initial, always); process -> stmt;
 *   block (begin, named begin, fork, named fork) ->> stmt; event stmt ->
 *   named event.
 * §26.6.28, p. 410: assignment -> vpiLhs, vpiRhs, delay control, event
 *   control; "-> blocking bool: vpiBlocking".
 * §26.6.29, p. 410: "For delay control associated with assignment, the
 *   statement shall always be NULL."
 * §26.6.30, p. 410: "For event control associated with assignment, the
 *   statement shall always be NULL."
 * §26.6.32-§26.6.35, p. 411-412: while/repeat/wait -> vpiCondition, stmt;
 *   for -> vpiForInitStmt, vpiCondition, vpiForIncStmt, stmt; forever ->
 *   stmt; if/if else -> vpiCondition, stmt, vpiElseStmt.
 * §26.6.36, p. 412 Details: "a) The case item shall group all case
 *   conditions that branch to the same statement. b) vpi_iterate() shall
 *   return NULL for the default case item because there is no expression
 *   with the default case."
 * §26.6.37, p. 413: force, assign stmt -> vpiRhs, vpiLhs; deassign, release
 *   -> vpiLhs.
 * §26.6.38, p. 413: disable -> vpiExpr (function, task, named fork, named
 *   begin).
 * §26.6.39, p. 414 Details: "a) To get information about the callback
 *   object, the routine vpi_get_cb_info() can be used. b) To get callback
 *   objects not related to the above objects, the second argument to
 *   vpi_iterate() shall be NULL."
 * §26.6.40, p. 414 Details: "a) The time queue objects shall be returned in
 *   increasing order of simulation time."
 * §26.6.41, p. 414: "If $timeformat() has not been called,
 *   vpi_handle(vpiActiveTimeFormat,NULL) shall return a NULL."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * Five processes: one always and four initial (vpiAlways, vpiInitial); no
 * clause fixes the iteration order, so each is told apart by its statement
 * (main's is the named begin, the forever's the delay control #20). main is a
 * named begin ("main", "b26_behaviour.main") holding 21 statements; each is
 * identified by its type, an assignment by its lhs (a, b, d, q), and filed
 * under the design header's number. Its vpiScope is the module. The fork fk
 * is a named fork holding two assignments; the scope that contains it is
 * main, so (§12.5, p. 191: "each module instance, generate block instance,
 * task, function, or named begin-end or fork-join block defines a new
 * hierarchical level, or scope") its full name is "b26_behaviour.main.fk",
 * and main's statements, fk among them, have vpiScope main.
 *
 *   §26.2.5  statement 2's rhs `a + b`: a vpiOperation, vpiOpType vpiAddOp,
 *            operands a and b, each a reg (a leaf). Statement 18's
 *            `p2 = {2{a[1:0]}}`: vpiMultiConcatOp whose first operand is the
 *            multiplier, the constant 2 (reads 2; unsized, so vpiDecConst or
 *            vpiIntConst - Annex G does not say which), and whose remaining
 *            operand is the expression within the concatenation {a[1:0]}
 *            (Details a; A.8.1 multiple_concatenation ::= { constant_expression
 *            concatenation }): the part select a[1:0], vpiParent a,
 *            vpiLeftRange 1, vpiRightRange 0. A full traversal of a + b meets
 *            one operation and two leaves. The fork's two statements are told
 *            apart by their lhs (p2 is the concatenation's). The other's rhs
 *            `a[i +: 2]` is an indexed part select of vpiIndexedPartSelectType
 *            vpiPosIndexed: vpiParent a, vpiBaseExpr the reg i, vpiWidthExpr
 *            the constant 2.
 *            §26.6.26 b) decompiles `a + b` as "a + b" (operator and operands
 *            one space apart, no parentheses: none are needed for
 *            precedence), the concatenation as "{2{a[1:0]}}", the indexed
 *            part select as "a[i +: 2]" and statement 0's rhs as "4'd9".
 *   §26.3.4  w1's `assign #4` has one delay: vpiDelay is a constant reading
 *            4. w's `assign #(2,3)` has two: an operation of vpiListOp.
 *   §26.6.24 three continuous assignments: w's, w1's and nd's net
 *            declaration assignment (vpiNetDeclAssign TRUE; FALSE for the
 *            other two). w's lhs is the net w and its rhs a vpiBitAndOp. A
 *            cont assign has a value: nd's drives 4'd3 with no delay, so at
 *            time 0's read-write synch it reads "0011"; w's reads whatever
 *            its delayed driver holds, and reading it is no error.
 *   §26.6.28 statement 0: vpiLhs is the reg a, vpiBlocking TRUE, rhs 4'd9 a
 *            constant, vpiConstType vpiDecConst. The always's statement is an
 *            event control whose statement is the nonblocking p <= a:
 *            vpiBlocking FALSE.
 *   §26.6.29 statement 1 `b = #1 a` -> delay control with vpiDelay 1 and a
 *            NULL statement; statement 2 `#2 c = a + b` is a delay control
 *            with vpiDelay 2 whose statement is the assignment.
 *   §26.6.30 statement 17 `q = @(posedge clk) a` -> event control whose
 *            condition is a vpiPosedgeOp and whose statement is NULL.
 *   §26.6.32 statements 7-9: vpiWhile (condition vpiGtOp), vpiRepeat
 *            (condition the constant 2, reads 2), vpiWait (condition
 *            vpiEqOp); each has its statement.
 *   §26.6.33 statement 6: init `i = 0`, condition vpiLtOp, increment
 *            `i = i + 1`, body `d = d + 1` - all four present.
 *   §26.6.34 the fourth process `initial #20 forever #1 clk = ~clk`: a delay
 *            control whose statement is a vpiForever, whose statement is the
 *            delay control #1.
 *   §26.6.35 statement 3 vpiIfElse (condition vpiEqOp, statement and else
 *            statement); statement 4 vpiIf.
 *   §26.6.36 statement 5: condition the reg a, vpiCaseType vpiCaseExact, two
 *            items; the first groups `4'd1, 4'd2` (two expressions), the
 *            default has none (NULL) but has its statement.
 *   §26.6.37 statements 10-13: force and assign stmt have vpiLhs and vpiRhs,
 *            release and deassign vpiLhs; the lhs are w, w, e, e.
 *   §26.6.38 statement 20 `disable main`: vpiExpr is the named begin main.
 *   §26.6.27 statement 14 `-> go`: event stmt -> named event go.
 *   §26.6.3  the module's internal scopes are bump, twice and main; main's is
 *            fk (full name "b26_behaviour.main.fk", above).
 *   §26.6.4  bump's io decl `input [3:0] by`: "by", vpiInput, 4 bits,
 *            vpiVector TRUE, vpiScalar FALSE, vpiSigned FALSE (no `signed`).
 *   §26.6.18 bump is a vpiTask, twice a vpiFunction of vpiSize 8 and
 *            vpiFuncType vpiSizedFunc (`[7:0]`, no `signed`); the function
 *            holds an 8-bit reg named "twice" (found by scanning the
 *            function's regs, since no clause fixes its full name).
 *   §26.6.19 statement 15: task call -> task bump, one argument (the
 *            constant 1); statement 16's rhs: func call -> function twice,
 *            one argument, the reg d, and the call's vpiFuncType is the
 *            function's, vpiSizedFunc; statement 19: sys task call "$display",
 *            vpiUserDefn FALSE, five arguments (the format and d, c, q, p2),
 *            and (§26.6.19 g) a vpiDecompile string: the call as written,
 *            `$display("d=%0d c=%0d q=%0d p2=%b", d, c, q, p2)`, the
 *            arguments decompiled as expressions and separated as the source
 *            separates them.
 *            No application is running a calltf, so
 *            vpi_handle(vpiSysTfCall, NULL) is NULL.
 *   §26.6.25 statement 0's lhs IS the reg a; statement 9's rhs mem[1] IS
 *            vpi_handle_by_index(mem, 1). a is used (vpiUse) by statement 0,
 *            which writes it, and by the rhs `a & b` of w's continuous
 *            assignment (or `a[0]` of w1's: a bit select of a is a use of a,
 *            Details a), among others.
 *   §26.6.39 a cbValueChange on a is a vpiCallback; vpi_get_cb_info gives
 *            back its reason and object; vpi_iterate(vpiCallback, a) yields
 *            it, and vpi_iterate(vpiCallback, NULL) the cbEndOfSimulation
 *            registered at startup.
 *   §26.6.40 at time 0's read-write synch the pending times are: 1 (b = #1),
 *            2 (w: `a & b` goes from xxxx to x00x, not to zero or z, so IEEE
 *            1364 §6.1.3's rise delay, 2), 4 (w1: x -> 1 after #4), 20 (the
 *            forever's #20) and 30 ($finish) - in that increasing order.
 *   §26.6.41 at cbEndOfCompile $timeformat has not run: NULL. At time 0's
 *            read-write synch it has (the first process's first statement),
 *            so the active time format is that $timeformat call.
 *
 * REFUSALS, each NULL / vpiUndefined with vpi_chk_error() nonzero:
 *   §26.2.5  vpi_iterate(vpiOperand, a): a reg is a leaf, no operation.
 *   §26.3.1  vpi_handle(vpiExpr, a[1:0]): the illegal untagged access.
 *   §26.3.4  vpi_handle(vpiDelay, a): a reg carries no delay.
 *   §26.6.3  vpi_get(vpiSize, main): a scope draws no size.
 *   §26.6.4  vpi_get(vpiPortIndex, by): a port's property, not an io decl's.
 *   §26.6.18 vpi_get(vpiSize, bump): a task has no size (a function does).
 *   §26.6.19 vpi_iterate(vpiOperand, task call): a call has arguments.
 *   §26.6.24 vpi_handle(vpiCondition, w's cont assign).
 *   §26.6.25 vpi_iterate(vpiUse, 4'd9): vpiUse leaves the simple expr class
 *            only, and a constant is not in it.
 *   §26.6.26 vpi_get(vpiConstType, a + b): an operation is no constant.
 *   §26.6.27 vpi_iterate(vpiStmt, statement 0): an assignment is no block.
 *   §26.6.28 vpi_handle(vpiCondition, statement 0).
 *   §26.6.29 vpi_handle(vpiCondition, statement 2's delay control).
 *   §26.6.30 vpi_handle(vpiDelay, the always's event control).
 *   §26.6.32 vpi_handle(vpiElseStmt, while); §26.6.33 on for; §26.6.35 on
 *            the if without else.
 *   §26.6.34 vpi_handle(vpiCondition, forever): forever draws only stmt.
 *   §26.6.36 vpi_get(vpiBlocking, case).
 *   §26.6.37 vpi_handle(vpiRhs, release).
 *   §26.6.38 vpi_handle(vpiCondition, disable).
 *   §26.6.39 vpi_get(vpiSize, callback).
 *   §26.6.40 vpi_get(vpiSize, time queue).
 *   §26.6.41 vpi_iterate(vpiActiveTimeFormat, NULL): a single arrow.
 */

//! inherited IEEE 1364-2005 26.2.5
//! inherited-reject IEEE 1364-2005 26.2.5
//! inherited-reject IEEE 1364-2005 26.3.1
//! inherited IEEE 1364-2005 26.3.4
//! inherited-reject IEEE 1364-2005 26.3.4
//! inherited IEEE 1364-2005 26.6.3
//! inherited-reject IEEE 1364-2005 26.6.3
//! inherited IEEE 1364-2005 26.6.4
//! inherited-reject IEEE 1364-2005 26.6.4
//! inherited IEEE 1364-2005 26.6.18
//! inherited-reject IEEE 1364-2005 26.6.18
//! inherited IEEE 1364-2005 26.6.19
//! inherited-reject IEEE 1364-2005 26.6.19
//! inherited IEEE 1364-2005 26.6.24
//! inherited-reject IEEE 1364-2005 26.6.24
//! inherited IEEE 1364-2005 26.6.25
//! inherited-reject IEEE 1364-2005 26.6.25
//! inherited IEEE 1364-2005 26.6.26
//! inherited-reject IEEE 1364-2005 26.6.26
//! inherited IEEE 1364-2005 26.6.27
//! inherited-reject IEEE 1364-2005 26.6.27
//! inherited IEEE 1364-2005 26.6.28
//! inherited-reject IEEE 1364-2005 26.6.28
//! inherited IEEE 1364-2005 26.6.29
//! inherited-reject IEEE 1364-2005 26.6.29
//! inherited IEEE 1364-2005 26.6.30
//! inherited-reject IEEE 1364-2005 26.6.30
//! inherited IEEE 1364-2005 26.6.32
//! inherited-reject IEEE 1364-2005 26.6.32
//! inherited IEEE 1364-2005 26.6.33
//! inherited-reject IEEE 1364-2005 26.6.33
//! inherited IEEE 1364-2005 26.6.34
//! inherited-reject IEEE 1364-2005 26.6.34
//! inherited IEEE 1364-2005 26.6.35
//! inherited-reject IEEE 1364-2005 26.6.35
//! inherited IEEE 1364-2005 26.6.36
//! inherited-reject IEEE 1364-2005 26.6.36
//! inherited IEEE 1364-2005 26.6.37
//! inherited-reject IEEE 1364-2005 26.6.37
//! inherited IEEE 1364-2005 26.6.38
//! inherited-reject IEEE 1364-2005 26.6.38
//! inherited IEEE 1364-2005 26.6.39
//! inherited-reject IEEE 1364-2005 26.6.39
//! inherited IEEE 1364-2005 26.6.40
//! inherited-reject IEEE 1364-2005 26.6.40
//! inherited IEEE 1364-2005 26.6.41
//! inherited-reject IEEE 1364-2005 26.6.41
//! design behaviour.v
//! stdout p02: b_26_6_behaviour checks=298
//! stdout d=12 c=1 q=9 p2=0101

#include "b_check.h"

/* Annex G numbers that src/vpi/vpi_user.h does not define. */
#ifndef vpiNetDeclAssign
#define vpiNetDeclAssign 43
#endif
#ifndef vpiFuncType
#define vpiFuncType 44
#endif
#ifndef vpiDecompile
#define vpiDecompile 54
#endif
#ifndef vpiListOp
#define vpiListOp 37
#endif
#ifndef vpiUse
#define vpiUse 101
#endif
#ifndef vpiIndexedPartSelect
#define vpiIndexedPartSelect 130
#endif

static vpiHandle top, st[21], value_cb, end_cb;
static int atf_at_compile = -1;

static int int_value(vpiHandle h);

static int count(PLI_INT32 type, vpiHandle ref)
{
  vpiHandle itr = vpi_iterate(type, ref);
  int n = 0;
  if (itr != NULL)
    while (vpi_scan(itr) != NULL) n++;
  return n;
}

/* The first and second objects of vpi_iterate(type, ref). */
static void first_two(PLI_INT32 type, vpiHandle ref, vpiHandle *a, vpiHandle *b)
{
  vpiHandle itr = vpi_iterate(type, ref);
  CHECK(itr != NULL, "vpi_iterate(%d) returned NULL", (int)type);
  *a = vpi_scan(itr);
  *b = *a ? vpi_scan(itr) : NULL;
  if (*b != NULL) vpi_free_object(itr);
}

static int int_value(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  return (int)v.value.integer;
}

static int has_scope(vpiHandle ref, const char *full)
{
  vpiHandle itr = vpi_iterate(vpiInternalScope, ref), h;
  int found = 0;
  if (itr == NULL) return 0;
  while ((h = vpi_scan(itr)) != NULL)
    if (strcmp(vpi_get_str(vpiFullName, h), full) == 0) found = 1;
  return found;
}

/* §26.2.5's traverseExpr, counting what it meets. */
static void traverse(vpiHandle e, int *ops, int *leaves)
{
  if (vpi_get(vpiType, e) == vpiOperation) {
    vpiHandle itr = vpi_iterate(vpiOperand, e), h;
    (*ops)++;
    if (itr != NULL)
      while ((h = vpi_scan(itr)) != NULL) traverse(h, ops, leaves);
  } else {
    (*leaves)++;
  }
}

static void expressions(void)
{
  vpiHandle a = p02_by_name("b26_behaviour.a");
  vpiHandle b = p02_by_name("b26_behaviour.b");
  vpiHandle sum = vpi_handle(vpiRhs, vpi_handle(vpiStmt, st[2]));
  vpiHandle fk0, fk1, rep, x1, x2, inner, ps;
  int ops = 0, leaves = 0;

  /* §26.2.5 */
  CHECK(vpi_get(vpiType, sum) == vpiOperation && vpi_get(vpiOpType, sum) == vpiAddOp, "26.2.5: a + b");
  first_two(vpiOperand, sum, &x1, &x2);
  CHECK((vpi_compare_objects(x1, a) && vpi_compare_objects(x2, b)) ||
        (vpi_compare_objects(x1, b) && vpi_compare_objects(x2, a)), "26.2.5: operands a and b");
  traverse(sum, &ops, &leaves);
  CHECK(ops == 1 && leaves == 2, "26.2.5: a + b is one operation over two leaves, got %d/%d", ops, leaves);
  first_two(vpiStmt, st[18], &fk0, &fk1);
  if (!vpi_compare_objects(vpi_handle(vpiLhs, fk1), p02_by_name("b26_behaviour.p2"))) {
    x1 = fk0;
    fk0 = fk1;
    fk1 = x1;
  }
  CHECK(vpi_compare_objects(vpi_handle(vpiLhs, fk1), p02_by_name("b26_behaviour.p2")), "26.6.27: fk's p2 = ...");
  rep = vpi_handle(vpiRhs, fk1);
  expect_no_error("the traversal");
  CHECK(vpi_iterate(vpiOperand, a) == NULL, "26.2.5: a reg has no operands");
  expect_refusal("vpi_iterate(vpiOperand, reg)");

  /* §26.6.26 */
  CHECK(vpi_get(vpiOpType, rep) == vpiMultiConcatOp, "26.6.26: multiple concatenation");
  first_two(vpiOperand, rep, &x1, &inner);
  CHECK(vpi_get(vpiType, x1) == vpiConstant &&
        (vpi_get(vpiConstType, x1) == vpiDecConst || vpi_get(vpiConstType, x1) == vpiIntConst) && int_value(x1) == 2,
        "26.6.26 a: the first operand is the multiplier 2");
  CHECK(count(vpiOperand, rep) == 2 && vpi_get(vpiType, inner) == vpiPartSelect,
        "26.6.26 a: {2{a[1:0]}}'s second and last operand is a[1:0]");
  ps = inner;
  CHECK(vpi_get(vpiType, ps) == vpiPartSelect && vpi_compare_objects(vpi_handle(vpiParent, ps), a), "26.6.26: a[1:0]");
  CHECK(int_value(vpi_handle(vpiLeftRange, ps)) == 1 && int_value(vpi_handle(vpiRightRange, ps)) == 0,
        "26.6.26: its ranges 1 and 0");
  expect_no_error("the expression walk");
  {
    vpiHandle r0 = vpi_handle(vpiRhs, fk0);
    CHECK(r0 != NULL && vpi_get(vpiType, r0) == vpiIndexedPartSelect &&
          vpi_get(vpiIndexedPartSelectType, r0) == vpiPosIndexed, "26.6.26: a[i +: 2] is an indexed part select, +:");
    CHECK(vpi_compare_objects(vpi_handle(vpiParent, r0), a) &&
          vpi_compare_objects(vpi_handle(vpiBaseExpr, r0), p02_by_name("b26_behaviour.i")) &&
          int_value(vpi_handle(vpiWidthExpr, r0)) == 2, "26.6.26: of a, base i, width 2");
    expect_no_error("the indexed part select");
  }
  {
    vpiHandle k = vpi_handle(vpiRhs, st[0]);
    CHECK(vpi_get(vpiConstType, k) == vpiDecConst, "26.6.26: vpiConstType of 4'd9 is vpiDecConst");
  }
  {
    const char *s = vpi_get_str(vpiDecompile, sum);
    CHECK(s != NULL && strcmp(s, "a + b") == 0, "26.6.26 b: vpiDecompile of a + b is \"a + b\"");
    s = vpi_get_str(vpiDecompile, rep);
    CHECK(s != NULL && strcmp(s, "{2{a[1:0]}}") == 0, "26.6.26 b: vpiDecompile of {2{a[1:0]}}");
    s = vpi_get_str(vpiDecompile, vpi_handle(vpiRhs, fk0));
    CHECK(s != NULL && strcmp(s, "a[i +: 2]") == 0, "26.6.26 b: vpiDecompile of a[i +: 2]");
    s = vpi_get_str(vpiDecompile, vpi_handle(vpiRhs, st[0]));
    CHECK(s != NULL && strcmp(s, "4'd9") == 0, "26.6.26 b: vpiDecompile of 4'd9");
    expect_no_error("the decompiled expressions");
  }
  CHECK(vpi_get(vpiConstType, sum) == vpiUndefined, "26.6.26: an operation has no vpiConstType");
  expect_refusal("vpi_get(vpiConstType, operation)");

  /* §26.3.1 */
  CHECK(vpi_handle(vpiExpr, ps) == NULL, "26.3.1: vpi_handle(vpiExpr, part select) is illegal");
  expect_refusal("vpi_handle(vpiExpr, part select)");

  /* §26.6.25 */
  CHECK(vpi_compare_objects(vpi_handle(vpiLhs, st[0]), a), "26.6.25: an identifier is its object");
  CHECK(vpi_compare_objects(vpi_handle(vpiRhs, vpi_handle(vpiStmt, st[9])),
                            vpi_handle_by_index(p02_by_name("b26_behaviour.mem"), 1)),
        "26.6.25: mem[1] is the memory word");
  expect_no_error("the simple expressions");
  {
    vpiHandle ca_w, ca_w1, itr = vpi_iterate(vpiUse, a), u;
    int found_st0 = 0, found_rhs = 0;
    first_two(vpiContAssign, top, &ca_w, &ca_w1);
    CHECK(itr != NULL, "26.6.25: a has uses");
    while ((u = vpi_scan(itr)) != NULL) {
      if (vpi_compare_objects(u, st[0])) found_st0 = 1;
      if (vpi_compare_objects(u, vpi_handle(vpiRhs, ca_w)) || vpi_compare_objects(u, vpi_handle(vpiRhs, ca_w1)))
        found_rhs = 1;
    }
    CHECK(found_st0 && found_rhs, "26.6.25: a's uses include statement 0 and a continuous assignment's rhs");
    expect_no_error("the uses of a");
  }
  CHECK(vpi_iterate(vpiUse, vpi_handle(vpiRhs, st[0])) == NULL, "26.6.25: a constant is no simple expr");
  expect_refusal("vpi_iterate(vpiUse, constant)");
}

static void cont_assigns(void)
{
  vpiHandle a = p02_by_name("b26_behaviour.a");
  vpiHandle ca_w, ca_w1, d;

  first_two(vpiContAssign, top, &ca_w, &ca_w1);
  if (!vpi_compare_objects(vpi_handle(vpiLhs, ca_w), p02_by_name("b26_behaviour.w"))) {
    d = ca_w;
    ca_w = ca_w1;
    ca_w1 = d;
  }
  CHECK(vpi_compare_objects(vpi_handle(vpiLhs, ca_w), p02_by_name("b26_behaviour.w")), "26.6.24: w's lhs");
  CHECK(vpi_get(vpiOpType, vpi_handle(vpiRhs, ca_w)) == vpiBitAndOp, "26.6.24: w's rhs a & b");
  CHECK(vpi_compare_objects(vpi_handle(vpiLhs, ca_w1), p02_by_name("b26_behaviour.w1")), "26.6.24: w1's lhs");
  /* §26.3.4 */
  d = vpi_handle(vpiDelay, ca_w1);
  CHECK(d != NULL && vpi_get(vpiType, d) == vpiConstant && int_value(d) == 4, "26.3.4: one delay is a constant, 4");
  expect_no_error("the continuous assignments");
  d = vpi_handle(vpiDelay, ca_w);
  CHECK(d != NULL && vpi_get(vpiType, d) == vpiOperation && vpi_get(vpiOpType, d) == vpiListOp && count(vpiOperand, d) == 2,
        "26.3.4: two delays are a vpiListOp operation over two operands");
  expect_no_error("the list of delays");
  CHECK(vpi_handle(vpiDelay, a) == NULL, "26.3.4: a reg has no delay");
  expect_refusal("vpi_handle(vpiDelay, reg)");
  {
    vpiHandle itr = vpi_iterate(vpiContAssign, top), ca, ca_nd = NULL;
    s_vpi_value v;
    int n = 0;
    while ((ca = vpi_scan(itr)) != NULL) {
      n++;
      if (vpi_compare_objects(vpi_handle(vpiLhs, ca), p02_by_name("b26_behaviour.nd"))) ca_nd = ca;
    }
    CHECK(n == 3 && ca_nd != NULL, "26.6.24: three continuous assignments, nd's net declaration assignment among them");
    CHECK(vpi_get(vpiNetDeclAssign, ca_nd) == 1 && vpi_get(vpiNetDeclAssign, ca_w) == 0 &&
          vpi_get(vpiNetDeclAssign, ca_w1) == 0, "26.6.24: vpiNetDeclAssign is TRUE for nd's alone");
    v.format = vpiBinStrVal;
    vpi_get_value(ca_nd, &v);
    CHECK(strcmp(v.value.str, "0011") == 0, "26.6.24: nd's assignment drives 4'd3, got %s", v.value.str);
    v.format = vpiBinStrVal;
    vpi_get_value(ca_w, &v);
    expect_no_error("the continuous assignments' values");
  }
  CHECK(vpi_handle(vpiCondition, ca_w) == NULL, "26.6.24: a cont assign has no condition");
  expect_refusal("vpi_handle(vpiCondition, cont assign)");
}

static void statements(void)
{
  vpiHandle a = p02_by_name("b26_behaviour.a");
  vpiHandle mainb = p02_by_name("b26_behaviour.main");
  vpiHandle proc_main = NULL, proc_always = NULL, proc_forever = NULL, all[21], itr, x, y, dc, ec, fv, s;
  int n = 0, initials = 0, k;

  /* §26.6.27, each process told apart by what it holds */
  itr = vpi_iterate(vpiProcess, top);
  CHECK(itr != NULL, "26.6.27: module ->> process");
  while ((x = vpi_scan(itr)) != NULL) {
    n++;
    s = vpi_handle(vpiStmt, x);
    if (vpi_get(vpiType, x) == vpiAlways) {
      CHECK(proc_always == NULL, "26.6.27: one always");
      proc_always = x;
    } else {
      CHECK(vpi_get(vpiType, x) == vpiInitial, "26.6.27: the rest are initial");
      initials++;
      if (vpi_compare_objects(s, mainb)) proc_main = x;
      if (vpi_get(vpiType, s) == vpiDelayControl && int_value(vpi_handle(vpiDelay, s)) == 20) proc_forever = x;
    }
  }
  CHECK(n == 5 && initials == 4, "26.6.27: five processes, four initial, got %d/%d", n, initials);
  CHECK(proc_main != NULL && proc_always != NULL && proc_forever != NULL, "26.6.27: process -> stmt");
  CHECK(vpi_compare_objects(vpi_handle(vpiModule, proc_main), top), "26.6.27: process -> module");
  CHECK(vpi_get(vpiType, mainb) == vpiNamedBegin, "26.6.27: main is a named begin");
  n = 0;
  itr = vpi_iterate(vpiStmt, mainb);
  while ((x = vpi_scan(itr)) != NULL) {
    CHECK(n < 21, "26.6.27: 21 statements");
    all[n++] = x;
  }
  CHECK(n == 21, "26.6.27: main holds 21 statements, got %d", n);
  /* Each statement found by what it is (its type, and an assignment by its
   * lhs), then filed under the header's number. */
  for (k = 0; k < 21; k++) st[k] = NULL;
  for (k = 0; k < 21; k++) {
    PLI_INT32 t = vpi_get(vpiType, all[k]);
    int at = -1;
    if (t == vpiAssignment) {
      const char *lhs = vpi_get_str(vpiName, vpi_handle(vpiLhs, all[k]));
      at = !strcmp(lhs, "a") ? 0 : !strcmp(lhs, "b") ? 1 : !strcmp(lhs, "d") ? 16 : !strcmp(lhs, "q") ? 17 : -1;
    } else {
      static const PLI_INT32 types[21] = { 0, 0, vpiDelayControl, vpiIfElse, vpiIf, vpiCase, vpiFor, vpiWhile,
                                           vpiRepeat, vpiWait, vpiForce, vpiRelease, vpiAssignStmt, vpiDeassign,
                                           vpiEventStmt, vpiTaskCall, 0, 0, vpiNamedFork, vpiSysTaskCall, vpiDisable };
      int j;
      for (j = 0; j < 21; j++)
        if (types[j] == t) at = j;
    }
    CHECK(at >= 0 && st[at] == NULL, "26.6.27: statement of type %d is main's one such", (int)t);
    st[at] = all[k];
  }
  CHECK(vpi_get(vpiType, st[14]) == vpiEventStmt &&
        vpi_compare_objects(vpi_handle(vpiNamedEvent, st[14]), p02_by_name("b26_behaviour.go")),
        "26.6.27: -> go");
  CHECK(vpi_get(vpiType, st[18]) == vpiNamedFork && count(vpiStmt, st[18]) == 2, "26.6.27: fk holds two");
  expect_no_error("the process walk");
  CHECK(vpi_iterate(vpiStmt, st[0]) == NULL, "26.6.27: an assignment is no block");
  expect_refusal("vpi_iterate(vpiStmt, assignment)");

  /* §26.6.3 */
  CHECK_STR(vpi_get_str(vpiName, mainb), "main", "26.6.3 name");
  CHECK_STR(vpi_get_str(vpiFullName, mainb), "b26_behaviour.main", "26.6.3 full name");
  CHECK(vpi_compare_objects(vpi_handle(vpiScope, mainb), top), "26.6.3: main's scope is the module");
  CHECK_STR(vpi_get_str(vpiFullName, st[18]), "b26_behaviour.main.fk", "26.6.3: the named fork is a scope");
  CHECK(has_scope(top, "b26_behaviour.bump") && has_scope(top, "b26_behaviour.twice") &&
        has_scope(top, "b26_behaviour.main"), "26.6.3: module ->> vpiInternalScope is bump, twice, main");
  CHECK(has_scope(mainb, "b26_behaviour.main.fk"), "26.6.3: main ->> vpiInternalScope is fk");
  CHECK(vpi_compare_objects(vpi_handle(vpiScope, st[18]), mainb), "26.6.3: fk's vpiScope is main");
  CHECK(vpi_compare_objects(vpi_handle(vpiScope, st[0]), mainb), "26.6.3: main's statements are in main");
  expect_no_error("the scope walk");
  CHECK(vpi_get(vpiSize, mainb) == vpiUndefined, "26.6.3: a scope has no size");
  expect_refusal("vpi_get(vpiSize, named begin)");

  /* §26.6.28 */
  CHECK(vpi_get(vpiType, st[0]) == vpiAssignment && vpi_get(vpiBlocking, st[0]) == 1, "26.6.28: a = 4'd9 blocks");
  CHECK(vpi_get(vpiType, vpi_handle(vpiRhs, st[0])) == vpiConstant && int_value(vpi_handle(vpiRhs, st[0])) == 9,
        "26.6.28: rhs 4'd9");
  ec = vpi_handle(vpiStmt, proc_always);
  CHECK(vpi_get(vpiType, ec) == vpiEventControl, "26.6.30: the always's event control");
  s = vpi_handle(vpiStmt, ec);
  CHECK(vpi_get(vpiType, s) == vpiAssignment && vpi_get(vpiBlocking, s) == 0, "26.6.28: p <= a does not block");
  expect_no_error("the assignment walk");
  CHECK(vpi_handle(vpiCondition, st[0]) == NULL, "26.6.28: an assignment has no condition");
  expect_refusal("vpi_handle(vpiCondition, assignment)");

  /* §26.6.29 */
  dc = vpi_handle(vpiDelayControl, st[1]);
  CHECK(dc != NULL && int_value(vpi_handle(vpiDelay, dc)) == 1, "26.6.29: b = #1 a");
  CHECK(vpi_handle(vpiStmt, dc) == NULL, "26.6.29: an assignment's delay control has no statement");
  CHECK(vpi_get(vpiType, st[2]) == vpiDelayControl && int_value(vpi_handle(vpiDelay, st[2])) == 2 &&
        vpi_get(vpiType, vpi_handle(vpiStmt, st[2])) == vpiAssignment, "26.6.29: #2 c = a + b");
  expect_no_error("the delay controls");
  CHECK(vpi_handle(vpiCondition, st[2]) == NULL, "26.6.29: a delay control has no condition");
  expect_refusal("vpi_handle(vpiCondition, delay control)");

  /* §26.6.30 */
  x = vpi_handle(vpiEventControl, st[17]);
  CHECK(x != NULL && vpi_get(vpiOpType, vpi_handle(vpiCondition, x)) == vpiPosedgeOp, "26.6.30: @(posedge clk)");
  CHECK(vpi_handle(vpiStmt, x) == NULL, "26.6.30: an assignment's event control has no statement");
  CHECK(vpi_get(vpiOpType, vpi_handle(vpiCondition, ec)) == vpiPosedgeOp, "26.6.30: the always's condition");
  expect_no_error("the event controls");
  CHECK(vpi_handle(vpiDelay, ec) == NULL, "26.6.30: an event control has no delay");
  expect_refusal("vpi_handle(vpiDelay, event control)");

  /* §26.6.32 */
  CHECK(vpi_get(vpiType, st[7]) == vpiWhile && vpi_get(vpiOpType, vpi_handle(vpiCondition, st[7])) == vpiGtOp &&
        vpi_handle(vpiStmt, st[7]) != NULL, "26.6.32: while (i > 0)");
  CHECK(vpi_get(vpiType, st[8]) == vpiRepeat && int_value(vpi_handle(vpiCondition, st[8])) == 2 &&
        vpi_handle(vpiStmt, st[8]) != NULL, "26.6.32: repeat (2)");
  CHECK(vpi_get(vpiType, st[9]) == vpiWait && vpi_get(vpiOpType, vpi_handle(vpiCondition, st[9])) == vpiEqOp &&
        vpi_handle(vpiStmt, st[9]) != NULL, "26.6.32: wait (clk == 0)");
  expect_no_error("the loops");
  CHECK(vpi_handle(vpiElseStmt, st[7]) == NULL, "26.6.32: a while has no else");
  expect_refusal("vpi_handle(vpiElseStmt, while)");

  /* §26.6.33 */
  CHECK(vpi_get(vpiType, st[6]) == vpiFor && vpi_get(vpiType, vpi_handle(vpiForInitStmt, st[6])) == vpiAssignment &&
        vpi_get(vpiOpType, vpi_handle(vpiCondition, st[6])) == vpiLtOp &&
        vpi_get(vpiType, vpi_handle(vpiForIncStmt, st[6])) == vpiAssignment &&
        vpi_get(vpiType, vpi_handle(vpiStmt, st[6])) == vpiAssignment, "26.6.33: for's four parts");
  expect_no_error("the for");
  CHECK(vpi_handle(vpiElseStmt, st[6]) == NULL, "26.6.33: a for has no else");
  expect_refusal("vpi_handle(vpiElseStmt, for)");

  /* §26.6.34 */
  x = vpi_handle(vpiStmt, proc_forever);
  CHECK(vpi_get(vpiType, x) == vpiDelayControl, "26.6.34: initial #20 ...");
  fv = vpi_handle(vpiStmt, x);
  CHECK(vpi_get(vpiType, fv) == vpiForever, "26.6.34: a forever");
  CHECK(vpi_get(vpiType, vpi_handle(vpiStmt, fv)) == vpiDelayControl, "26.6.34: forever -> stmt, #1 clk = ~clk");
  expect_no_error("the forever");
  CHECK(vpi_handle(vpiCondition, fv) == NULL, "26.6.34: forever draws no condition");
  expect_refusal("vpi_handle(vpiCondition, forever)");

  /* §26.6.35 */
  CHECK(vpi_get(vpiType, st[3]) == vpiIfElse && vpi_get(vpiOpType, vpi_handle(vpiCondition, st[3])) == vpiEqOp &&
        vpi_handle(vpiStmt, st[3]) != NULL && vpi_handle(vpiElseStmt, st[3]) != NULL, "26.6.35: if else");
  CHECK(vpi_get(vpiType, st[4]) == vpiIf && vpi_handle(vpiStmt, st[4]) != NULL, "26.6.35: if");
  expect_no_error("the ifs");
  CHECK(vpi_handle(vpiElseStmt, st[4]) == NULL, "26.6.35: an if without else draws no else");
  expect_refusal("vpi_handle(vpiElseStmt, if)");

  /* §26.6.36 */
  CHECK(vpi_get(vpiType, st[5]) == vpiCase && vpi_compare_objects(vpi_handle(vpiCondition, st[5]), a) &&
        vpi_get(vpiCaseType, st[5]) == vpiCaseExact, "26.6.36: case (a)");
  first_two(vpiCaseItem, st[5], &x, &y);
  if (vpi_iterate(vpiExpr, x) == NULL) {
    s = x;
    x = y;
    y = s;
  }
  CHECK(count(vpiExpr, x) == 2, "26.6.36 a: 4'd1, 4'd2 is one item");
  CHECK(vpi_iterate(vpiExpr, y) == NULL && vpi_handle(vpiStmt, y) != NULL, "26.6.36 b: default has no expression");
  expect_no_error("the case");
  CHECK(vpi_get(vpiBlocking, st[5]) == vpiUndefined, "26.6.36: a case is no assignment");
  expect_refusal("vpi_get(vpiBlocking, case)");

  /* §26.6.37 */
  CHECK(vpi_get(vpiType, st[10]) == vpiForce && vpi_handle(vpiRhs, st[10]) != NULL &&
        vpi_compare_objects(vpi_handle(vpiLhs, st[10]), p02_by_name("b26_behaviour.w")), "26.6.37: force w");
  CHECK(vpi_get(vpiType, st[11]) == vpiRelease &&
        vpi_compare_objects(vpi_handle(vpiLhs, st[11]), p02_by_name("b26_behaviour.w")), "26.6.37: release w");
  CHECK(vpi_get(vpiType, st[12]) == vpiAssignStmt && vpi_handle(vpiRhs, st[12]) != NULL &&
        vpi_compare_objects(vpi_handle(vpiLhs, st[12]), p02_by_name("b26_behaviour.e")), "26.6.37: assign e");
  CHECK(vpi_get(vpiType, st[13]) == vpiDeassign &&
        vpi_compare_objects(vpi_handle(vpiLhs, st[13]), p02_by_name("b26_behaviour.e")), "26.6.37: deassign e");
  expect_no_error("force and assign");
  CHECK(vpi_handle(vpiRhs, st[11]) == NULL, "26.6.37: release draws no rhs");
  expect_refusal("vpi_handle(vpiRhs, release)");

  /* §26.6.38 */
  CHECK(vpi_get(vpiType, st[20]) == vpiDisable, "26.6.38: disable main");
  CHECK(vpi_compare_objects(vpi_handle(vpiExpr, st[20]), mainb), "26.6.38: disable -> vpiExpr is main");
  expect_no_error("the disable");
  CHECK(vpi_handle(vpiCondition, st[20]) == NULL, "26.6.38: disable has no condition");
  expect_refusal("vpi_handle(vpiCondition, disable)");
}

static void tasks_and_calls(void)
{
  vpiHandle bump = p02_by_name("b26_behaviour.bump");
  vpiHandle twice = p02_by_name("b26_behaviour.twice");
  vpiHandle io, rest, fc, arg;

  /* §26.6.18 / §26.6.4 */
  CHECK(vpi_get(vpiType, bump) == vpiTask && vpi_get(vpiType, twice) == vpiFunction, "26.6.18: a task, a function");
  first_two(vpiIODecl, bump, &io, &rest);
  CHECK(io != NULL && rest == NULL, "26.6.4: bump has one io decl");
  CHECK_STR(vpi_get_str(vpiName, io), "by", "26.6.4 name");
  CHECK(vpi_get(vpiDirection, io) == vpiInput && vpi_get(vpiSize, io) == 4, "26.6.4: input [3:0]");
  CHECK(count(vpiIODecl, twice) == 1, "26.6.18: twice's io decl");
  expect_no_error("the task walk");
  CHECK(vpi_get(vpiVector, io) == 1 && vpi_get(vpiScalar, io) == 0 && vpi_get(vpiSigned, io) == 0,
        "26.6.4: input [3:0] is a vector, not a scalar, unsigned");
  CHECK(vpi_get(vpiSize, twice) == 8, "26.6.18: vpiSize of function [7:0] twice is 8");
  CHECK(vpi_get(vpiFuncType, twice) == vpiSizedFunc, "26.6.18: vpiFuncType of function [7:0] is vpiSizedFunc");
  {
    vpiHandle itr = vpi_iterate(vpiReg, twice), h;
    int found = 0;
    if (itr != NULL)
      while ((h = vpi_scan(itr)) != NULL)
        if (strcmp(vpi_get_str(vpiName, h), "twice") == 0 && vpi_get(vpiSize, h) == 8) found = 1;
    CHECK(found, "26.6.18: the function holds an 8-bit reg named twice");
  }
  expect_no_error("the function's properties");
  CHECK(vpi_get(vpiPortIndex, io) == vpiUndefined, "26.6.4: an io decl has no port index");
  expect_refusal("vpi_get(vpiPortIndex, io decl)");
  CHECK(vpi_get(vpiSize, bump) == vpiUndefined, "26.6.18: a task has no size");
  expect_refusal("vpi_get(vpiSize, task)");

  /* §26.6.19 */
  CHECK(vpi_get(vpiType, st[15]) == vpiTaskCall && vpi_compare_objects(vpi_handle(vpiTask, st[15]), bump),
        "26.6.19: task call -> task");
  first_two(vpiArgument, st[15], &arg, &rest);
  CHECK(rest == NULL && int_value(arg) == 1, "26.6.19: bump(4'd1)");
  fc = vpi_handle(vpiRhs, st[16]);
  CHECK(vpi_get(vpiType, fc) == vpiFuncCall && vpi_compare_objects(vpi_handle(vpiFunction, fc), twice),
        "26.6.19: func call -> function");
  first_two(vpiArgument, fc, &arg, &rest);
  CHECK(rest == NULL && vpi_compare_objects(arg, p02_by_name("b26_behaviour.d")), "26.6.19: twice(d)");
  CHECK(vpi_get(vpiType, st[19]) == vpiSysTaskCall, "26.6.19: $display is a system task call");
  CHECK_STR(vpi_get_str(vpiName, st[19]), "$display", "26.6.19 tf name");
  CHECK(vpi_get(vpiUserDefn, st[19]) == 0 && count(vpiArgument, st[19]) == 5, "26.6.19: built in, five arguments");
  expect_no_error("the call walk");
  CHECK(vpi_handle(vpiSysTfCall, NULL) == NULL, "26.6.19 a: no application is running");
  CHECK(vpi_get(vpiFuncType, fc) == vpiSizedFunc, "26.6.19: vpiFuncType of the call twice(d) is its function's");
  {
    const char *s = vpi_get_str(vpiDecompile, st[19]);
    CHECK(s != NULL && strcmp(s, "$display(\"d=%0d c=%0d q=%0d p2=%b\", d, c, q, p2)") == 0,
          "26.6.19 g: vpiDecompile of the $display call");
  }
  CHECK(vpi_iterate(vpiOperand, st[15]) == NULL, "26.6.19: a call draws arguments, not operands");
  expect_refusal("vpi_iterate(vpiOperand, task call)");
}

static PLI_INT32 on_change(p_cb_data d)
{
  (void)d;
  return 0;
}

static void callbacks_and_time(void)
{
  vpiHandle a = p02_by_name("b26_behaviour.a");
  static s_vpi_time t_none = { vpiSuppressTime, 0, 0, 0.0 };
  static s_vpi_value v_none = { vpiSuppressVal, { 0 } };
  s_cb_data cb, info;
  PLI_UINT32 want[5] = { 1, 2, 4, 20, 30 }, last = 0;
  vpiHandle itr, q, atf;
  int n = 0, ordered = 1;

  /* §26.6.39 */
  memset(&cb, 0, sizeof cb);
  cb.reason = cbValueChange;
  cb.cb_rtn = on_change;
  cb.obj = a;
  cb.time = &t_none;
  cb.value = &v_none;
  value_cb = vpi_register_cb(&cb);
  CHECK(value_cb != NULL && vpi_get(vpiType, value_cb) == vpiCallback, "26.6.39: a callback object");
  memset(&info, 0, sizeof info);
  vpi_get_cb_info(value_cb, &info);
  CHECK(info.reason == cbValueChange && vpi_compare_objects(info.obj, a), "26.6.39 a: vpi_get_cb_info");
  expect_no_error("the callback walk");
  CHECK(count(vpiCallback, a) == 1, "26.6.39: iterate the callback on a");
  CHECK(count(vpiCallback, NULL) >= 1, "26.6.39: iterate global callbacks");
  CHECK(vpi_get(vpiSize, value_cb) == vpiUndefined, "26.6.39: a callback has no size");
  expect_refusal("vpi_get(vpiSize, callback)");

  /* §26.6.40 */
  itr = vpi_iterate(vpiTimeQueue, NULL);
  CHECK(itr != NULL, "26.6.40: pending times");
  while ((q = vpi_scan(itr)) != NULL) {
    s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
    CHECK(vpi_get(vpiType, q) == vpiTimeQueue, "26.6.40: a time queue");
    vpi_get_time(q, &t);
    CHECK(n < 5 && t.high == 0 && t.low == want[n], "26.6.40: time %d is %u", n, (unsigned)t.low);
    if (n > 0 && t.low <= last) ordered = 0;
    last = t.low;
    n++;
  }
  CHECK(n == 5 && ordered, "26.6.40 a: 1, 2, 4, 20, 30 in increasing order");
  itr = vpi_iterate(vpiTimeQueue, NULL);
  q = vpi_scan(itr);
  vpi_free_object(itr);
  expect_no_error("the time queue");
  CHECK(vpi_get(vpiSize, q) == vpiUndefined, "26.6.40: a time queue has no size");
  expect_refusal("vpi_get(vpiSize, time queue)");

  /* §26.6.41 */
  CHECK(atf_at_compile == 1, "26.6.41: NULL before $timeformat runs");
  atf = vpi_handle(vpiActiveTimeFormat, NULL);
  CHECK(atf != NULL && vpi_get(vpiType, atf) == vpiSysTaskCall,
        "26.6.41: the executed $timeformat is the active task call");
  CHECK(vpi_iterate(vpiActiveTimeFormat, NULL) == NULL, "26.6.41: a single arrow, not a double");
  expect_refusal("vpi_iterate(vpiActiveTimeFormat, NULL)");
}

static PLI_INT32 walk(p_cb_data cb_data)
{
  (void)cb_data;
  top = p02_by_name("b26_behaviour");
  statements();
  expressions();
  cont_assigns();
  tasks_and_calls();
  callbacks_and_time();
  p02_done("b_26_6_behaviour");
  return 0;
}

static PLI_INT32 end_of_compile(p_cb_data cb_data)
{
  (void)cb_data;
  atf_at_compile = vpi_handle(vpiActiveTimeFormat, NULL) == NULL && vpi_chk_error(NULL) == 0;
  return 0;
}

static PLI_INT32 end_of_sim(p_cb_data cb_data)
{
  (void)cb_data;
  return 0;
}

static PLI_INT32 start(p_cb_data cb_data)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data cb;
  (void)cb_data;
  cb.reason = cbReadWriteSynch;
  cb.cb_rtn = walk;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadWriteSynch(0) registration failed");
  return 0;
}

/* §26.2.4: from the startup routine only the action callbacks may be
 * registered, so the time callback is registered once simulation starts. */
static void setup(void)
{
  static s_cb_data ss, ec, es;
  ec.reason = cbEndOfCompile;
  ec.cb_rtn = end_of_compile;
  CHECK(vpi_register_cb(&ec) != NULL, "cbEndOfCompile registration failed");
  es.reason = cbEndOfSimulation;
  es.cb_rtn = end_of_sim;
  end_cb = vpi_register_cb(&es);
  CHECK(end_cb != NULL, "cbEndOfSimulation registration failed");
  ss.reason = cbStartOfSimulation;
  ss.cb_rtn = start;
  CHECK(vpi_register_cb(&ss) != NULL, "cbStartOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
