/* IEEE 1364-2005 §§9.7.3, 26.6.11, 27.17–18, 27.32.
 * Named event arrays have independently triggerable elements. §26.6.11
 * requires indices innermost first; §27.18 takes them leftmost first.
 *
 * DERIVATION: eva[1] is a member of [0:1]; descending[2] retains [3:2].
 * matrix[-1][4] is indexed by {-1,4}, while its vpiIndex iterator returns
 * {4,-1}. All paths to a declared element identify the same object. Scalar
 * events have vpiArray=0 and no indices. Ranges preserve declaration order.
 *
 * The HDL triggers eva[0] at t=1,3 and eva[1] at t=4. Changing i from 0 to
 * 1 at t=2 causes no occurrence: selected is 1 at t=2, then 2 at t=5.
 * At t=6, vpi_put_value(NULL, vpiNoDelay) adds one event to eva[1],
 * descending[3], matrix[0][3] and scalar. After their listeners resume,
 * c0=2, c1=2, selected=3 and each other counter=2. A source reference
 * eva[i] is triggered through VPI at t=7, when i=1, adding one more c1 and
 * selected occurrence. At t=8 a VPI index function returns 0, so c0=3;
 * it must not execute while constructing event metadata. Task/block-local
 * event arrays each wake once. At t=9 the completed static task retains
 * local_index=2 and its dynamic event reference remains usable: a module
 * waiter observes this occurrence and the HDL occurrence at t=8, hence 2.
 *
 * REFUSALS: an out-of-range/wrong-rank select is not a legal event select;
 * event arrays have no direction, and their elements hold no value. The
 * successful neighboring accesses and triggers distinguish these errors
 * from a blanket refusal. Startup only registers action callbacks (§26.2.4).
 * IMPLEMENTATION LIMIT: automatic VPI event references require §26.6.20
 * activation frames. VerA reports that named limitation before/after the
 * task invocation instead of using a declaration's unrelated static slot.
 * This is not tagged as a normative refusal; HDL automatic lifetimes run
 * separately in event_array_automatic.v.
 */
//! inherited IEEE 1364-2005 9.7.3
//! inherited IEEE 1364-2005 26.6.11
//! inherited-reject IEEE 1364-2005 26.6.11
//! inherited IEEE 1364-2005 27.17
//! inherited-reject IEEE 1364-2005 27.17
//! inherited IEEE 1364-2005 27.18
//! inherited-reject IEEE 1364-2005 27.18
//! inherited IEEE 1364-2005 27.32
//! lrm 5.10.4
//! design event_array.v
//! stdout p02: b_26_6_11_event_array checks=271
#include "b_check.h"

static vpiHandle e1, de3, me03, scalar, selected_ref, task_ref, automatic_ref;
static int delivered, constant_refs, index_calls, retained_done;

static PLI_INT32 event_index(PLI_BYTE8 *user)
{
  s_vpi_value v = { .format = vpiIntVal };
  (void)user;
  index_calls++;
  v.value.integer = 0;
  vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
  expect_no_error("event index function result");
  return 0;
}

static int integer(vpiHandle h)
{
  s_vpi_value v = { .format = vpiIntVal };
  CHECK(h != NULL, "integer object exists");
  vpi_get_value(h, &v);
  expect_no_error("integer read");
  return v.value.integer;
}

static void counter(const char *name, int want)
{
  char full[96];
  snprintf(full, sizeof full, "b26_event_array.%s", name);
  CHECK(integer(p02_by_name(full)) == want, "%s must equal %d", name, want);
}

static void range(vpiHandle itr, int left, int right)
{
  vpiHandle h = vpi_scan(itr);
  CHECK(h != NULL && vpi_get(vpiType, h) == vpiRange, "array range");
  CHECK(integer(vpi_handle(vpiLeftRange, h)) == left, "declared left bound");
  CHECK(integer(vpi_handle(vpiRightRange, h)) == right, "declared right bound");
}

/* Find the source's -> eva[i] reference: it is a named-event select with
 * a variable index, not a vector reg-bit object. */
static void event_references(vpiHandle stmt)
{
  vpiHandle itr, child, event, ix;
  if (stmt == NULL) return;
  switch (vpi_get(vpiType, stmt)) {
    case vpiBegin: case vpiNamedBegin: case vpiFork: case vpiNamedFork:
      itr = vpi_iterate(vpiStmt, stmt);
      if (itr) while ((child = vpi_scan(itr)) != NULL) event_references(child);
      break;
    case vpiDelayControl: case vpiEventControl:
      event_references(vpi_handle(vpiStmt, stmt));
      break;
    case vpiEventStmt:
      event = vpi_handle(vpiNamedEvent, stmt);
      if (event && vpi_get(vpiArray, event)) {
        ix = vpi_handle(vpiIndex, event);
        if (ix && vpi_get(vpiType, ix) == vpiIntegerVar &&
            strcmp(vpi_get_str(vpiName, ix), "i") == 0) selected_ref = event;
        if (ix && vpi_get(vpiType, ix) == vpiIntegerVar &&
            strcmp(vpi_get_str(vpiName, ix), "local_index") == 0) task_ref = event;
        if (ix && vpi_get(vpiType, ix) == vpiIntegerVar &&
            strcmp(vpi_get_str(vpiName, ix), "automatic_index") == 0) automatic_ref = event;
        if (ix && vpi_get(vpiType, ix) == vpiConstant) {
          char full[128];
          snprintf(full, sizeof full, "%s", vpi_get_str(vpiFullName, event));
          CHECK(full[0] != 0, "constant event reference names its element");
          CHECK(vpi_compare_objects(event, p02_by_name(full)), "constant source identity");
          constant_refs++;
        }
      }
      break;
    default: break;
  }
}

static PLI_INT32 selected_complete(p_cb_data cb)
{
  (void)cb;
  counter("c1", 3); counter("selected", 4);
  delivered = 2;
  return 0;
}

static PLI_INT32 inject_selected(p_cb_data cb)
{
  static s_vpi_time now = { vpiSimTime, 0, 0, 0.0 };
  s_cb_data sync = { .reason = cbReadOnlySynch, .cb_rtn = selected_complete, .time = &now };
  (void)cb;
  CHECK(selected_ref != NULL, "variable-index source event reference");
  vpi_put_value(selected_ref, NULL, NULL, vpiNoDelay);
  expect_no_error("trigger source reference eva[i]");
  CHECK(vpi_register_cb(&sync) != NULL, "read after source event delivery");
  return 0;
}

static PLI_INT32 complete(p_cb_data cb)
{
  (void)cb;
  counter("c0", 2); counter("c1", 2); counter("selected", 3);
  counter("desc_hits", 2); counter("matrix_hits", 2); counter("scalar_hits", 2);
  delivered = 1;
  return 0;
}

static PLI_INT32 inject(p_cb_data cb)
{
  static s_vpi_time now = { vpiSimTime, 0, 0, 0.0 };
  s_cb_data sync = { .reason = cbReadOnlySynch, .cb_rtn = complete, .time = &now };
  (void)cb;
  counter("c0", 2); counter("c1", 1); counter("selected", 2);
  counter("desc_hits", 1); counter("matrix_hits", 1); counter("scalar_hits", 1);
  vpi_put_value(e1, NULL, NULL, vpiNoDelay); expect_no_error("trigger eva[1]");
  vpi_put_value(de3, NULL, NULL, vpiNoDelay); expect_no_error("trigger descending[3]");
  vpi_put_value(me03, NULL, NULL, vpiNoDelay); expect_no_error("trigger matrix[0][3]");
  vpi_put_value(scalar, NULL, NULL, vpiNoDelay); expect_no_error("trigger scalar");
  CHECK(vpi_register_cb(&sync) != NULL, "read after event delivery");
  return 0;
}

static PLI_INT32 index_change(p_cb_data cb)
{
  (void)cb;
  counter("c0", 1); counter("c1", 0); counter("selected", 1);
  return 0;
}

static PLI_INT32 finish(p_cb_data cb)
{
  (void)cb;
  CHECK(delivered == 2, "the VPI-triggered events reached their HDL waiters");
  counter("task_hits", 1); counter("block_hits", 1);
  counter("retained_hits", 2);
  counter("c0", 3);
  CHECK(index_calls == 1, "the source index function executes once, when triggered");
  CHECK(retained_done == 1, "event-reference lifetime checks ran after task completion");
  p02_done("b_26_6_11_event_array");
  return 0;
}

static PLI_INT32 retained(p_cb_data cb)
{
  (void)cb;
  counter("work.local_index", 2);
  vpi_put_value(task_ref, NULL, NULL, vpiNoDelay);
  expect_no_error("static task reference after its task returns");
  vpi_put_value(automatic_ref, NULL, NULL, vpiNoDelay);
  expect_refusal_saying("automatic reference after its task returns", "activation frame");
  retained_done = 1;
  return 0;
}

static PLI_INT32 start(p_cb_data cb)
{
  vpiHandle mod = p02_by_name("b26_event_array");
  vpiHandle eva = p02_by_name("b26_event_array.eva");
  vpiHandle descending = p02_by_name("b26_event_array.descending");
  vpiHandle matrix = p02_by_name("b26_event_array.matrix");
  vpiHandle m, itr, h;
  PLI_INT32 indices[2] = { -1, 4 };
  int arrays = 0;
  s_vpi_value v = { .format = vpiIntVal };
  static s_vpi_time two = { vpiSimTime, 0, 2, 0.0 };
  static s_vpi_time six = { vpiSimTime, 0, 6, 0.0 };
  static s_vpi_time seven = { vpiSimTime, 0, 7, 0.0 };
  static s_vpi_time nine = { vpiSimTime, 0, 9, 0.0 };
  s_cb_data at_two = { .reason = cbReadOnlySynch, .cb_rtn = index_change, .time = &two };
  s_cb_data at_six = { .reason = cbAfterDelay, .cb_rtn = inject, .time = &six };
  s_cb_data at_seven = { .reason = cbAfterDelay, .cb_rtn = inject_selected, .time = &seven };
  s_cb_data at_nine = { .reason = cbAfterDelay, .cb_rtn = retained, .time = &nine };
  (void)cb;
  CHECK(index_calls == 0, "building event metadata does not execute its index function");
  CHECK(vpi_get(vpiType, eva) == vpiNamedEventArray, "named event array type");
  CHECK_STR(vpi_get_str(vpiName, eva), "eva", "array name");
  itr = vpi_iterate(vpiNamedEventArray, mod);
  CHECK(itr != NULL, "module event arrays");
  while ((h = vpi_scan(itr)) != NULL) { CHECK(vpi_get(vpiType, h) == vpiNamedEventArray, "array iteration type"); arrays++; }
  CHECK(arrays == 3, "three declared arrays");
  e1 = vpi_handle_by_index(eva, 1);
  CHECK(e1 != NULL && vpi_get(vpiType, e1) == vpiNamedEvent, "selected event type");
  CHECK(vpi_compare_objects(e1, p02_by_name("b26_event_array.eva[1]")), "stable event identity");
  CHECK_STR(vpi_get_str(vpiFullName, e1), "b26_event_array.eva[1]", "event full name");
  CHECK(vpi_get(vpiArray, e1) == 1, "array member");
  CHECK(vpi_compare_objects(vpi_handle(vpiParent, e1), eva), "element parent");
  CHECK(vpi_compare_objects(vpi_handle(vpiModule, e1), mod), "element module");
  itr = vpi_iterate(vpiIndex, e1);
  CHECK(itr != NULL && integer(vpi_scan(itr)) == 1, "one-dimensional index");
  CHECK(vpi_scan(itr) == NULL, "only one index");
  itr = vpi_iterate(vpiRange, eva); range(itr, 0, 1);
  CHECK(vpi_scan(itr) == NULL, "one-dimensional range");
  itr = vpi_iterate(vpiRange, descending); range(itr, 3, 2);
  CHECK(vpi_scan(itr) == NULL, "descending range count");
  de3 = vpi_handle_by_index(descending, 3);
  CHECK(de3 != NULL, "descending array access");
  m = vpi_handle_by_multi_index(matrix, 2, indices);
  CHECK(m != NULL && vpi_get(vpiType, m) == vpiNamedEvent, "multidimensional event");
  CHECK(vpi_compare_objects(m, p02_by_name("b26_event_array.matrix[-1][4]")), "multi-index identity");
  CHECK(vpi_compare_objects(vpi_handle(vpiParent, m), matrix), "multi-index parent");
  CHECK(integer(vpi_handle(vpiIndex, m)) == 4, "innermost single index");
  itr = vpi_iterate(vpiIndex, m);
  CHECK(itr != NULL && integer(vpi_scan(itr)) == 4, "inner index first");
  CHECK(integer(vpi_scan(itr)) == -1, "outer index second");
  CHECK(vpi_scan(itr) == NULL, "two indices only");
  itr = vpi_iterate(vpiRange, matrix); range(itr, -1, 0); range(itr, 4, 3);
  CHECK(vpi_scan(itr) == NULL, "two declared dimensions");
  indices[0] = 0; indices[1] = 3;
  me03 = vpi_handle_by_multi_index(matrix, 2, indices);
  CHECK(me03 != NULL && !vpi_compare_objects(me03, m), "different elements differ");
  scalar = p02_by_name("b26_event_array.scalar");
  CHECK(vpi_get(vpiArray, scalar) == 0, "scalar is no array member");
  CHECK(vpi_iterate(vpiIndex, scalar) == NULL, "scalar has no indices");
  expect_no_error("scalar index iteration");
  CHECK(vpi_handle_by_index(eva, 2) == NULL, "out-of-bounds index");
  expect_refusal_saying("event index", "has no element");
  indices[0] = -2;
  CHECK(vpi_handle_by_multi_index(matrix, 2, indices) == NULL, "multi-index out of bounds");
  expect_refusal_saying("event multi-index", "no event");
  CHECK(vpi_handle_by_multi_index(matrix, 1, indices) == NULL, "incomplete multi-index");
  expect_refusal_saying("event index rank", "no event");
  CHECK(vpi_get(vpiDirection, eva) == vpiUndefined, "event array has no direction");
  expect_refusal_saying("event direction", "property");
  vpi_get_value(e1, &v);
  expect_refusal_saying("event value", "has no value");
  h = p02_by_name("b26_event_array.work.local_ev[2]");
  CHECK(vpi_compare_objects(vpi_handle(vpiScope, h), p02_by_name("b26_event_array.work")), "task event scope");
  CHECK(vpi_compare_objects(vpi_handle(vpiParent, h), p02_by_name("b26_event_array.work.local_ev")), "task event parent");
  h = p02_by_name("b26_event_array.local_block.local_ev[-1]");
  CHECK(vpi_compare_objects(vpi_handle(vpiScope, h), p02_by_name("b26_event_array.local_block")), "block event scope");
  CHECK(vpi_compare_objects(vpi_handle(vpiModule, h), mod), "block event module");
  itr = vpi_iterate(vpiProcess, mod);
  while ((h = vpi_scan(itr)) != NULL) event_references(vpi_handle(vpiStmt, h));
  /* Two eva[0] statements, descending[2], matrix[-1][4], block local_ev[-1]. */
  CHECK(constant_refs == 5, "constant source references include negative matrix/block indices");
  event_references(vpi_handle(vpiStmt, p02_by_name("b26_event_array.work")));
  event_references(vpi_handle(vpiStmt, p02_by_name("b26_event_array.auto_work")));
  CHECK(task_ref != NULL, "static task's dynamic event reference");
  CHECK(automatic_ref != NULL, "automatic task's dynamic event reference");
  CHECK(vpi_get(vpiAutomatic, task_ref) == 0, "static event reference lifetime");
  CHECK(vpi_get(vpiAutomatic, automatic_ref) == 1, "automatic event reference lifetime");
  vpi_put_value(automatic_ref, NULL, NULL, vpiNoDelay);
  expect_refusal_saying("automatic event reference", "activation frame");
  h = p02_by_name("b26_event_array.auto_work.local_ev[0]");
  CHECK(vpi_get(vpiAutomatic, h) == 1, "automatic event element lifetime");
  vpi_put_value(h, NULL, NULL, vpiNoDelay);
  expect_refusal_saying("automatic event element", "activation frame");
  CHECK(vpi_register_cb(&at_two) != NULL, "check index change at t=2");
  CHECK(vpi_register_cb(&at_six) != NULL, "inject at t=6");
  CHECK(vpi_register_cb(&at_seven) != NULL, "inject source reference at t=7");
  CHECK(vpi_register_cb(&at_nine) != NULL, "inspect retained task references at t=9");
  return 0;
}

static void setup(void)
{
  s_cb_data cb = { .reason = cbStartOfSimulation, .cb_rtn = start };
  s_vpi_systf_data tf = { .type = vpiSysFunc, .sysfunctype = vpiIntFunc,
                        .tfname = "$event_index", .calltf = event_index };
  CHECK(vpi_register_systf(&tf) != NULL, "register event index function");
  CHECK(vpi_register_cb(&cb) != NULL, "start callback");
  cb.reason = cbEndOfSimulation; cb.cb_rtn = finish;
  CHECK(vpi_register_cb(&cb) != NULL, "end callback");
}
void (*vlog_startup_routines[])(void) = { setup, 0 };
