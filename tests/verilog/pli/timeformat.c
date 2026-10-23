/* IEEE 1364-2005 §26.6.41, p. 414: the vpiActiveTimeFormat single arrow
 * reaches the active time-format task call. "If $timeformat() has not been
 * called, vpi_handle(vpiActiveTimeFormat,NULL) shall return a NULL."
 * Annex G, p. 525, assigns the relationship number 119. §17.3.2, p. 300,
 * makes each invocation replace the previous format and allows a call
 * with no arguments to select the defaults. §26.6.19 describes the task
 * call's name, arguments and containing scope.
 *
 * DERIVATION: the source has four calls whose execution order is top at
 * 1 ns, a.set_format at 2 ns, b.set_format at 4 ns, then the top's default
 * reset at 5 ns. The children instantiate the same definition, so their
 * calls share a source token but have distinct handles and modules. At
 * end of compilation and read-only time 0, all call objects exist yet the active
 * handle is NULL with no error. At read-only times 1, 2, 4, 5 and 6 the
 * expected handles are respectively top, a, b, reset, reset. Executing
 * the zero-argument call still makes that actual call active; it does not
 * return NULL or manufacture four default argument expressions.
 *
 * The first call has arguments (-9, 2, " ns", 0), the two child calls
 * (-12, 1, " ps", 0), and the reset none. Compare handles obtained through
 * the source graph before simulation with the runtime active handle; a
 * static lookup or token-only match cannot satisfy the sequence.
 * REFUSAL: the circled single arrow takes NULL, not a module reference,
 * and is not a one-to-many vpi_iterate relationship. Both calls are
 * refused, next to a successful active lookup. The final marker requires
 * all six read-only checkpoints and the end-of-simulation callback.
 */
//! inherited IEEE 1364-2005 26.6.41
//! inherited-reject IEEE 1364-2005 26.6.41
//! inherited IEEE 1364-2005 26.6.19
//! design timeformat.v
//! stdout b26_timeformat: active call follows execution ok

#include "b_check.h"

static vpiHandle top, first, child_a, child_b, reset_call;
static int visited;
static const PLI_UINT32 times[] = { 0, 1, 2, 4, 5, 6 };

static vpiHandle item(PLI_INT32 type, vpiHandle ref, int at)
{
  vpiHandle it = vpi_iterate(type, ref), h = NULL;
  int i;
  CHECK(it != NULL, "relationship %d has an iterator", (int)type);
  for (i = 0; i <= at; i++) {
    h = vpi_scan(it);
    CHECK(h != NULL, "relationship %d has item %d", (int)type, i);
  }
  vpi_free_object(it);
  return h;
}

static int int_value(vpiHandle h)
{
  s_vpi_value v;
  memset(&v, 0, sizeof v);
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  expect_no_error("timeformat argument value");
  return v.value.integer;
}

static void call(vpiHandle h, vpiHandle module, int has_args, int units, int precision, const char *suffix)
{
  vpiHandle it, arg;
  int n = 0;
  CHECK(vpi_get(vpiType, h) == vpiSysTaskCall, "active format is a system task call");
  CHECK_STR(vpi_get_str(vpiName, h), "$timeformat", "time-format task name");
  CHECK(vpi_compare_objects(vpi_handle(vpiModule, h), module), "call belongs to the correct instance");
  it = vpi_iterate(vpiArgument, h);
  expect_no_error("timeformat arguments");
  CHECK((it != NULL) == has_args, "no-argument reset has no argument iterator");
  if (it == NULL) return;
  while ((arg = vpi_scan(it)) != NULL) {
    if (n == 0) {
      CHECK(vpi_get(vpiType, arg) == vpiOperation && vpi_get(vpiOpType, arg) == vpiMinusOp,
            "units are a unary minus expression");
      CHECK(int_value(item(vpiOperand, arg, 0)) == -units, "timeformat units magnitude");
    } else if (n == 2) {
      s_vpi_value v;
      memset(&v, 0, sizeof v);
      v.format = vpiStringVal;
      vpi_get_value(arg, &v);
      CHECK_STR(v.value.str, suffix, "timeformat suffix");
    } else {
      CHECK(n < 4 && int_value(arg) == (n == 1 ? precision : 0), "timeformat numeric argument %d", n);
    }
    n++;
  }
  CHECK(n == 4, "explicit format has four arguments");
}

static PLI_INT32 inspect(p_cb_data cb)
{
  vpiHandle active, want;
  s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  (void)cb;
  vpi_get_time(NULL, &t);
  CHECK(visited < 6 && t.high == 0 && t.low == times[visited], "read-only checkpoint order");
  want = visited == 0 ? NULL : visited == 1 ? first : visited == 2 ? child_a : visited == 3 ? child_b : reset_call;
  active = vpi_handle(vpiActiveTimeFormat, NULL);
  expect_no_error("active time format lookup");
  if (want == NULL) CHECK(active == NULL, "no executed timeformat at time 0");
  else {
    CHECK(active != NULL && vpi_compare_objects(active, want), "active call follows execution at time %u", (unsigned)t.low);
    CHECK(vpi_compare_objects(vpi_handle(vpiActiveTimeFormat, NULL), active), "repeat lookup retains call identity");
    if (visited >= 4) call(active, top, 0, 0, 0, "");
  }
  if (visited == 1) {
    CHECK(vpi_handle(vpiActiveTimeFormat, top) == NULL, "active format has a NULL reference");
    expect_refusal("active time format from a module");
    CHECK(vpi_iterate(vpiActiveTimeFormat, NULL) == NULL, "active format is a single arrow");
    expect_refusal("iterate active time format");
  }
  visited++;
  return 0;
}

static PLI_INT32 finished(p_cb_data cb)
{
  (void)cb;
  CHECK(visited == 6, "all timeformat checkpoints ran");
  CHECK(vpi_compare_objects(vpi_handle(vpiActiveTimeFormat, NULL), reset_call), "last call stays active through end of simulation");
  puts("b26_timeformat: active call follows execution ok");
  return 0;
}

static PLI_INT32 compiled(p_cb_data ignored)
{
  vpiHandle process, body, a, b, task_a, task_b;
  s_cb_data cb;
  unsigned i;
  (void)ignored;
  top = p02_by_name("b26_timeformat");
  a = p02_by_name("b26_timeformat.a");
  b = p02_by_name("b26_timeformat.b");
  task_a = p02_by_name("b26_timeformat.a.set_format");
  task_b = p02_by_name("b26_timeformat.b.set_format");
  process = item(vpiProcess, top, 0);
  body = vpi_handle(vpiStmt, process);
  first = vpi_handle(vpiStmt, item(vpiStmt, body, 0));
  reset_call = vpi_handle(vpiStmt, item(vpiStmt, body, 1));
  child_a = vpi_handle(vpiStmt, task_a);
  child_b = vpi_handle(vpiStmt, task_b);
  CHECK(vpi_handle(vpiActiveTimeFormat, NULL) == NULL, "no call has executed during compilation");
  expect_no_error("active format before execution");
  call(first, top, 1, -9, 2, " ns");
  call(child_a, a, 1, -12, 1, " ps");
  call(child_b, b, 1, -12, 1, " ps");
  call(reset_call, top, 0, 0, 0, "");
  CHECK(!vpi_compare_objects(child_a, child_b), "same source call has distinct instance objects");
  CHECK(vpi_compare_objects(vpi_handle(vpiScope, child_a), task_a), "child call's enclosing task");
  for (i = 0; i < sizeof times / sizeof times[0]; i++) {
    s_vpi_time t = { vpiSimTime, 0, times[i], 0.0 };
    memset(&cb, 0, sizeof cb);
    cb.reason = cbReadOnlySynch;
    cb.cb_rtn = inspect;
    cb.time = &t;
    CHECK(vpi_register_cb(&cb) != NULL, "register read-only checkpoint");
  }
  memset(&cb, 0, sizeof cb);
  cb.reason = cbEndOfSimulation;
  cb.cb_rtn = finished;
  CHECK(vpi_register_cb(&cb) != NULL, "register end callback");
  return 0;
}

static void register_app(void)
{
  /* §26.2.4: startup registers; the design walk waits for compilation. */
  s_cb_data cb;
  memset(&cb, 0, sizeof cb);
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = compiled;
  CHECK(vpi_register_cb(&cb) != NULL, "register compile callback");
}

void (*vlog_startup_routines[])(void) = { register_app, NULL };
