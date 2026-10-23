/* IEEE 1364-2005 subroutine declarations, expressions and static storage.
 *
 * §26.6.18, p. 402: "A Verilog HDL function shall contain an object with
 * the same name, size, and type as the function." Its diagram gives the
 * function vpiSize, vpiSigned and vpiFuncType; §26.6.19 gives a function call
 * its function relationship and vpiFuncType. A result identifier denotes
 * the variable; a recursive call denotes the function declaration.
 * §26.6.3, p. 389, makes tasks/functions scopes with regs and variables;
 * §26.6.4 connects each IO declaration through vpiExpr to its variable.
 * §26.6.28 connects assignments to their lhs/rhs; §26.6.26 gives operations
 * their operands.
 * §26.6.20 marks automatic variables vpiAutomatic; their declaration
 * handles below are used only for metadata, not an inactive frame's value.
 *
 * DERIVATION: subroutines.v has W=8. first has an 8-bit result,
 * formal x and local_value; count is a 32-bit integer and scratch a real.
 * Its scope therefore has three regs, one integer and one real. recur has
 * three automatic integers; adjust has three integers and one scalar reg.
 * first's final assignment reaches its result variable on the lhs and a
 * call of later on the rhs. later is declared afterward: its call already
 * has vpiSizedFunc. The recursive call reaches recur (vpiIntFunc), while
 * both assignments reach recur's 32-bit implicit result variable. The
 * module's local_value=99 must not replace any subroutine's local variable.
 * IO variables and ordinary locals have their enclosing subroutine as
 * vpiScope and the top module as vpiModule. negate's signed 4-bit result
 * has vpiSizedSignedFunc; real_id has vpiRealFunc.
 *
 * At time 0's read-only callback, first(5) has set x=5, local_value=count=6,
 * scratch=2.5, and both first and later results to 12. recur(3)=1+1+2+3=7.
 * adjust(4, y, 1) keeps n=4, local_value=7, flag=1 and y=8 in static
 * storage. negate(3)=-3; real_id(1.5)=1.5. The exact binary
 * fractions 2.5 and 1.5 need no rounding tolerance.
 *
 * REFUSAL: an IO declaration has no vpiPortIndex (§26.6.4); requesting it
 * returns vpiUndefined and reports an error. Its direction/size/sign and
 * scalar/vector properties are the legal neighbour. The final marker is
 * printed only after every metadata and runtime assertion in the callback.
 */
//! inherited IEEE 1364-2005 26.6.3
//! inherited IEEE 1364-2005 26.6.4
//! inherited-reject IEEE 1364-2005 26.6.4
//! inherited IEEE 1364-2005 26.6.18
//! inherited IEEE 1364-2005 26.6.19
//! inherited IEEE 1364-2005 26.6.20
//! inherited IEEE 1364-2005 26.6.26
//! inherited IEEE 1364-2005 26.6.28
//! design subroutines.v
//! stdout b26_subroutines: metadata and runtime ok

#include "b_check.h"

static vpiHandle top;

static int count_objects(PLI_INT32 type, vpiHandle obj)
{
  vpiHandle it = vpi_iterate(type, obj);
  int n = 0;
  if (it != NULL) while (vpi_scan(it) != NULL) n++;
  return n;
}

static vpiHandle item(PLI_INT32 type, vpiHandle obj, int index)
{
  vpiHandle it = vpi_iterate(type, obj), h = NULL;
  int i;
  if (it != NULL) {
    for (i = 0; i <= index; i++) {
      h = vpi_scan(it);
      if (h == NULL) break;
    }
    if (h != NULL) vpi_free_object(it);
  }
  CHECK(h != NULL, "relationship %d has item %d", (int)type, index);
  return h;
}

static void edge(PLI_INT32 type, vpiHandle obj, vpiHandle want)
{
  CHECK(vpi_compare_objects(vpi_handle(type, obj), want), "relationship %d reaches the expected object", (int)type);
}

static vpiHandle variable(const char *name, vpiHandle scope, int type, int size, int automatic)
{
  vpiHandle h = p02_by_name(name);
  CHECK(vpi_get(vpiType, h) == type && vpi_get(vpiSize, h) == size && vpi_get(vpiAutomatic, h) == automatic,
        "%s has its declared type, size and lifetime", name);
  edge(vpiScope, h, scope);
  edge(vpiModule, h, top);
  return h;
}

static void io(vpiHandle scope, int index, vpiHandle formal, int dir, int size, int sign)
{
  vpiHandle h = item(vpiIODecl, scope, index);
  CHECK(vpi_get(vpiDirection, h) == dir && vpi_get(vpiSize, h) == size && vpi_get(vpiSigned, h) == sign &&
        vpi_get(vpiScalar, h) == (size == 1) && vpi_get(vpiVector, h) == (size > 1), "IO declaration properties");
  edge(vpiExpr, h, formal);
  edge(vpiScope, h, scope);
}

static int integer(vpiHandle h)
{
  s_vpi_value v = { vpiIntVal, { 0 } };
  vpi_get_value(h, &v);
  expect_no_error("static integer value");
  return v.value.integer;
}

static double real_value(vpiHandle h)
{
  s_vpi_value v = { vpiRealVal, { 0 } };
  vpi_get_value(h, &v);
  expect_no_error("static real value");
  return v.value.real;
}

static PLI_INT32 inspect(p_cb_data data)
{
  vpiHandle first, later, recur, adjust, negate, real_id;
  vpiHandle result, x, local, count, scratch, later_result, later_x;
  vpiHandle recursive_result, n, recursive_local, task_n, task_y, task_flag, task_local;
  vpiHandle negative_result, negative_x, real_result, real_x;
  vpiHandle body, assignment, call, branch, sum, task_body;
  (void)data;
  top = p02_by_name("b26_subroutines");
  first = p02_by_name("b26_subroutines.first");
  later = p02_by_name("b26_subroutines.later");
  recur = p02_by_name("b26_subroutines.recur");
  adjust = p02_by_name("b26_subroutines.adjust");
  negate = p02_by_name("b26_subroutines.negate");
  real_id = p02_by_name("b26_subroutines.real_id");

  /* This first body check distinguishes the result variable from the
   * function object, independently of the remaining formal/local checks. */
  result = p02_by_name("b26_subroutines.first.first");
  body = vpi_handle(vpiStmt, first);
  assignment = item(vpiStmt, body, 3);
  edge(vpiLhs, assignment, result);
  CHECK(vpi_get(vpiSize, first) == 8 && vpi_get(vpiFuncType, first) == vpiSizedFunc && vpi_get(vpiSigned, first) == 0,
        "parameter-sized first is an unsigned 8-bit function");
  edge(vpiScope, result, first);
  CHECK(vpi_get(vpiType, result) == vpiReg && vpi_get(vpiSize, result) == 8, "first contains its 8-bit result reg");
  x = variable("b26_subroutines.first.x", first, vpiReg, 8, 0);
  local = variable("b26_subroutines.first.local_value", first, vpiReg, 8, 0);
  count = variable("b26_subroutines.first.count", first, vpiIntegerVar, 32, 0);
  scratch = variable("b26_subroutines.first.scratch", first, vpiRealVar, 64, 0);
  later_result = variable("b26_subroutines.later.later", later, vpiReg, 8, 0);
  later_x = variable("b26_subroutines.later.x", later, vpiReg, 8, 0);
  CHECK(count_objects(vpiReg, first) == 3 && count_objects(vpiIntegerVar, first) == 1 && count_objects(vpiRealVar, first) == 1,
        "first iterates its result, formal and ordinary locals by class");
  io(first, 0, x, vpiInput, 8, 0);
  edge(vpiLhs, item(vpiStmt, body, 0), local);
  edge(vpiLhs, item(vpiStmt, body, 1), count);
  edge(vpiRhs, item(vpiStmt, body, 1), local);
  edge(vpiLhs, item(vpiStmt, body, 2), scratch);
  CHECK(vpi_compare_objects(item(vpiOperand, vpi_handle(vpiRhs, item(vpiStmt, body, 0)), 0), x), "first's expression reads its formal");
  call = vpi_handle(vpiRhs, assignment);
  edge(vpiFunction, call, later);
  CHECK(vpi_get(vpiFuncType, call) == vpiSizedFunc, "forward-declared later gives its call vpiSizedFunc");
  CHECK(vpi_compare_objects(item(vpiArgument, call, 0), local), "forward call argument is the local reg");
  edge(vpiLhs, vpi_handle(vpiStmt, later), later_result);
  CHECK(vpi_compare_objects(item(vpiOperand, vpi_handle(vpiRhs, vpi_handle(vpiStmt, later)), 0), later_x), "later's expression reads its own formal");

  recursive_result = variable("b26_subroutines.recur.recur", recur, vpiIntegerVar, 32, 1);
  n = variable("b26_subroutines.recur.n", recur, vpiIntegerVar, 32, 1);
  recursive_local = variable("b26_subroutines.recur.local_value", recur, vpiIntegerVar, 32, 1);
  CHECK(count_objects(vpiIntegerVar, recur) == 3, "recur iterates its three automatic integers");
  body = vpi_handle(vpiStmt, recur);
  edge(vpiLhs, item(vpiStmt, body, 0), recursive_local);
  edge(vpiRhs, item(vpiStmt, body, 0), n);
  branch = item(vpiStmt, body, 1);
  edge(vpiLhs, vpi_handle(vpiStmt, branch), recursive_result);
  assignment = vpi_handle(vpiElseStmt, branch);
  edge(vpiLhs, assignment, recursive_result);
  sum = vpi_handle(vpiRhs, assignment);
  call = item(vpiOperand, sum, 0);
  edge(vpiFunction, call, recur);
  CHECK(vpi_get(vpiType, call) == vpiFuncCall && vpi_get(vpiFuncType, call) == vpiIntFunc, "recursive call remains a call of the integer function");
  CHECK(vpi_compare_objects(item(vpiOperand, sum, 1), recursive_local), "recursive expression uses its own local");
  CHECK(vpi_compare_objects(item(vpiOperand, item(vpiArgument, call, 0), 0), n), "recursive argument reads its formal n");
  io(recur, 0, n, vpiInput, 32, 1);

  task_n = variable("b26_subroutines.adjust.n", adjust, vpiIntegerVar, 32, 0);
  task_y = variable("b26_subroutines.adjust.y", adjust, vpiIntegerVar, 32, 0);
  task_flag = variable("b26_subroutines.adjust.flag", adjust, vpiReg, 1, 0);
  task_local = variable("b26_subroutines.adjust.local_value", adjust, vpiIntegerVar, 32, 0);
  CHECK(count_objects(vpiIntegerVar, adjust) == 3 && count_objects(vpiReg, adjust) == 1, "adjust iterates its integer variables and scalar formal");
  io(adjust, 0, task_n, vpiInput, 32, 1);
  io(adjust, 1, task_y, vpiOutput, 32, 1);
  io(adjust, 2, task_flag, vpiInput, 1, 0);
  task_body = vpi_handle(vpiStmt, adjust);
  edge(vpiLhs, item(vpiStmt, task_body, 0), task_local);
  edge(vpiLhs, item(vpiStmt, task_body, 1), task_y);
  sum = vpi_handle(vpiRhs, item(vpiStmt, task_body, 1));
  CHECK(vpi_compare_objects(item(vpiOperand, sum, 0), task_local) && vpi_compare_objects(item(vpiOperand, sum, 1), task_flag), "task output reads its local and formal");

  negative_result = variable("b26_subroutines.negate.negate", negate, vpiReg, 4, 0);
  negative_x = variable("b26_subroutines.negate.x", negate, vpiReg, 4, 0);
  CHECK(vpi_get(vpiFuncType, negate) == vpiSizedSignedFunc && vpi_get(vpiSigned, negate) == 1, "negate is a signed sized function");
  io(negate, 0, negative_x, vpiInput, 4, 1);
  real_result = variable("b26_subroutines.real_id.real_id", real_id, vpiRealVar, 64, 0);
  real_x = variable("b26_subroutines.real_id.x", real_id, vpiRealVar, 64, 0);
  CHECK(vpi_get(vpiFuncType, real_id) == vpiRealFunc, "real_id is a real function");
  edge(vpiExpr, item(vpiIODecl, real_id, 0), real_x);

  CHECK(vpi_get(vpiPortIndex, item(vpiIODecl, first, 0)) == vpiUndefined, "an IO declaration has no port index");
  expect_refusal("vpiPortIndex on an IO declaration");
  CHECK(integer(result) == 12 && integer(x) == 5 && integer(local) == 6 && integer(count) == 6 && real_value(scratch) == 2.5,
        "first's static frame retains its independently derived values");
  CHECK(integer(later_result) == 12 && integer(later_x) == 6, "later's static result and formal");
  CHECK(integer(task_n) == 4 && integer(task_y) == 8 && integer(task_flag) == 1 && integer(task_local) == 7, "task formals and local retain their values");
  CHECK(integer(negative_result) == -3 && integer(negative_x) == 3, "signed function storage");
  CHECK(real_value(real_result) == 1.5 && real_value(real_x) == 1.5, "real function storage");
  CHECK(integer(p02_by_name("b26_subroutines.result")) == 12 && integer(p02_by_name("b26_subroutines.recursive_result")) == 7 &&
        integer(p02_by_name("b26_subroutines.task_out")) == 8 && integer(p02_by_name("b26_subroutines.negative_result")) == -3 &&
        real_value(p02_by_name("b26_subroutines.real_result")) == 1.5 &&
        integer(p02_by_name("b26_subroutines.local_value")) == 99, "HDL execution and module shadow remain correct");
  expect_no_error("subroutine metadata and runtime walk");
  puts("b26_subroutines: metadata and runtime ok");
  return 0;
}

static PLI_INT32 start(p_cb_data data)
{
  static s_vpi_time now = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data cb;
  (void)data;
  cb.reason = cbReadOnlySynch;
  cb.cb_rtn = inspect;
  cb.time = &now;
  CHECK(vpi_register_cb(&cb) != NULL, "read-only callback");
  return 0;
}

static void startup(void)
{
  static s_cb_data cb;
  cb.reason = cbStartOfSimulation;
  cb.cb_rtn = start;
  CHECK(vpi_register_cb(&cb) != NULL, "start callback");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
