/* IEEE 1364-2005 §26.6.39, p. 414: callbacks related to expressions,
 * primitive terminals, statements or time queues are reached from those
 * objects; callbacks not related to those objects use a NULL reference.
 * §27.21 returns NULL for an empty set. §27.35 invalidates a removed
 * callback; a later traversal must not rediscover it. Callback information
 * comes from vpi_get_cb_info (§26.6.39(a), §27.7).
 *
 * DERIVATION: register two value callbacks and a force callback on q, one
 * value callback on r, a global force callback, an end-of-simulation
 * callback, and time callbacks at 3 and 5 ns plus cbNextSimTime. q's set
 * has exactly its three object callbacks; r's set has one. The NULL set
 * has exactly the global force and end-of-simulation callbacks. A timed
 * callback's obj supplies timescale context (§27.33.2), not a traversal
 * parent; the action callback's obj is ignored (§27.33.3).
 * The setup's end-of-compilation callback removes its own registration
 * before these runtime sets are inspected.
 *
 * At time 0, the HDL's next queue is 2 ns. Its only callback is
 * cbNextSimTime; queues 3 and 5 hold the corresponding time callbacks.
 * Registration order is deliberately not used as a traversal oracle.
 * Removing callbacks through iterated handles leaves one on q and none on
 * r; removed handles are refused by vpi_get_cb_info, with live handles as
 * the legal neighbour. A foreign reference is refused by vpi_iterate.
 *
 * RUNTIME: q's surviving callback sees values 1 and 0 at times 2 and 4.
 * The next-time callback runs at 2 before q changes, so it sees 0; the
 * 3 ns callback sees 1 and the 5 ns callback sees 0. The final marker is
 * printed at end of simulation only after these deliveries and a final
 * callback traversal succeed. No invalid form is invented for §26.6.39's
 * positive graph relationship; invalid handle calls exercise §27.7/21.
 */
//! inherited IEEE 1364-2005 26.6.39
//! inherited IEEE 1364-2005 27.7
//! inherited-reject IEEE 1364-2005 27.7
//! inherited IEEE 1364-2005 27.21
//! inherited-reject IEEE 1364-2005 27.21
//! inherited IEEE 1364-2005 27.33.1
//! inherited IEEE 1364-2005 27.33.2
//! inherited IEEE 1364-2005 27.35
//! design callback_object_relations.v
//! stdout b26_callbacks: traversal and delivery ok

#include "b_check.h"
#include <stdint.h>

static vpiHandle q, r, q_cb, end_cb, compile_cb;
static int changes, next_fired, three_fired, five_fired;

static int int_value(vpiHandle h)
{
  s_vpi_value value;
  memset(&value, 0, sizeof value);
  value.format = vpiIntVal;
  vpi_get_value(h, &value);
  expect_no_error("read q");
  return value.value.integer;
}

static unsigned now(void)
{
  s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  vpi_get_time(NULL, &t);
  CHECK(t.high == 0, "fixture time fits in the low word");
  return t.low;
}

/* Compare identities as a set, not the unspecified iteration order. */
static void callbacks(vpiHandle ref, const vpiHandle *want, int n)
{
  vpiHandle it = vpi_iterate(vpiCallback, ref), h;
  unsigned seen = 0;
  int count = 0;
  expect_no_error("iterate callbacks");
  CHECK((it == NULL) == (n == 0), "empty callback sets return NULL");
  if (it == NULL) return;
  CHECK(vpi_get(vpiType, it) == vpiIterator, "callback iterator type");
  while ((h = vpi_scan(it)) != NULL) {
    int i;
    s_cb_data info;
    CHECK(vpi_get(vpiType, h) == vpiCallback, "iterated callback type");
    for (i = 0; i < n; i++) if (vpi_compare_objects(h, want[i])) break;
    CHECK(i < n && !(seen & (1u << i)), "each expected callback appears once");
    seen |= 1u << i;
    count++;
    memset(&info, 0, sizeof info);
    vpi_get_cb_info(h, &info);
    expect_no_error("information through an iterated callback");
    CHECK(info.cb_rtn != NULL, "callback information retains its routine");
  }
  expect_no_error("exhaust callback iterator");
  CHECK(count == n, "all expected callbacks were visited");
}

static void remove_iterated(vpiHandle ref, vpiHandle h)
{
  vpiHandle it = vpi_iterate(vpiCallback, ref), got;
  int found = 0;
  CHECK(it != NULL, "callback set before removal");
  while ((got = vpi_scan(it)) != NULL) {
    if (vpi_compare_objects(got, h)) {
      CHECK(vpi_remove_cb(got) == 1, "remove through iterated handle");
      found = 1;
    }
  }
  CHECK(found, "removed the requested callback");
}

static PLI_INT32 unexpected(p_cb_data cb)
{
  (void)cb;
  CHECK(0, "a removed callback must never run");
  return 0;
}

static PLI_INT32 changed(p_cb_data cb)
{
  CHECK(cb->reason == cbValueChange && vpi_compare_objects(cb->obj, q), "change belongs to q");
  CHECK(changes < 2 && now() == (changes == 0 ? 2u : 4u), "q change time");
  CHECK(cb->value != NULL && cb->value->value.integer == (changes == 0 ? 1 : 0), "q change value");
  changes++;
  return 0;
}

static PLI_INT32 timed(p_cb_data cb)
{
  if (strcmp((const char *)cb->user_data, "next") == 0) {
    CHECK(cb->reason == cbNextSimTime && now() == 2 && int_value(q) == 0, "next queue before q changes");
    next_fired++;
  } else if (strcmp((const char *)cb->user_data, "three") == 0) {
    vpiHandle it, queue;
    int found_four = 0;
    CHECK(cb->reason == cbAfterDelay && now() == 3 && int_value(q) == 1, "3 ns callback");
    it = vpi_iterate(vpiTimeQueue, NULL);
    CHECK(it != NULL, "pending queues at 3 ns");
    while ((queue = vpi_scan(it)) != NULL) {
      s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
      vpi_get_time(queue, &t);
      if (t.high == 0 && t.low == 4) {
        callbacks(queue, NULL, 0);
        found_four = 1;
      }
    }
    CHECK(found_four, "HDL queue at 4 ns has no pending callbacks");
    three_fired++;
  } else {
    CHECK(strcmp((const char *)cb->user_data, "five") == 0 && now() == 5 && int_value(q) == 0, "5 ns callback");
    five_fired++;
  }
  return 0;
}

static vpiHandle add(PLI_INT32 reason, vpiHandle obj, PLI_INT32 (*fn)(p_cb_data),
                     PLI_INT32 time_type, double delay, const char *data)
{
  s_vpi_time t = { time_type, 0, (PLI_UINT32)delay, delay };
  s_vpi_value v = { vpiIntVal, { 0 } };
  s_cb_data cb;
  vpiHandle h;
  memset(&cb, 0, sizeof cb);
  cb.reason = reason;
  cb.cb_rtn = fn;
  cb.obj = obj;
  cb.time = &t;
  cb.value = &v;
  cb.user_data = (PLI_BYTE8 *)data;
  h = vpi_register_cb(&cb);
  CHECK(h != NULL, "register reason %d", (int)reason);
  expect_no_error("register callback");
  return h;
}

static PLI_INT32 setup(p_cb_data ignored)
{
  vpiHandle q2, r1, force_q, force_all, three, five, next, it, queue;
  vpiHandle set[3];
  int queues = 0;
  s_cb_data info;
  (void)ignored;
  CHECK(now() == 0 && int_value(q) == 0, "setup after initialization");
  q_cb = add(cbValueChange, q, changed, vpiSimTime, 0, "q");
  q2 = add(cbValueChange, q, unexpected, vpiSuppressTime, 0, "q2");
  r1 = add(cbValueChange, r, unexpected, vpiSuppressTime, 0, "r");
  force_q = add(cbForce, q, unexpected, vpiSuppressTime, 0, "force q");
  force_all = add(cbForce, NULL, unexpected, vpiSuppressTime, 0, "force all");
  three = add(cbAfterDelay, q, timed, vpiScaledRealTime, 3, "three");
  five = add(cbAfterDelay, NULL, timed, vpiSimTime, 5, "five");
  next = add(cbNextSimTime, NULL, timed, vpiSimTime, 0, "next");
  set[0] = q_cb; set[1] = q2; set[2] = force_q;
  callbacks(q, set, 3);
  callbacks(r, &r1, 1);
  set[0] = end_cb; set[1] = force_all;
  callbacks(NULL, set, 2);
  it = vpi_iterate(vpiTimeQueue, NULL);
  CHECK(it != NULL, "pending time queues");
  while ((queue = vpi_scan(it)) != NULL) {
    s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
    vpi_get_time(queue, &t);
    CHECK(t.high == 0, "queue time fits in the low word");
    if (t.low == 2) callbacks(queue, &next, 1);
    else if (t.low == 3) callbacks(queue, &three, 1);
    else if (t.low == 5) callbacks(queue, &five, 1);
    else CHECK(0, "unexpected pending time %u", (unsigned)t.low);
    queues++;
  }
  CHECK(queues == 3, "three pending queues");
  remove_iterated(q, q2);
  remove_iterated(q, force_q);
  remove_iterated(r, r1);
  remove_iterated(NULL, force_all);
  callbacks(q, &q_cb, 1);
  callbacks(r, NULL, 0);
  callbacks(NULL, &end_cb, 1);
  memset(&info, 0, sizeof info);
  vpi_get_cb_info(q2, &info);
  expect_refusal_saying("removed callback information", "not a live callback");
  vpi_get_cb_info(q_cb, &info);
  expect_no_error("surviving callback information");
  CHECK(info.reason == cbValueChange && vpi_compare_objects(info.obj, q), "live callback info");
  CHECK(vpi_iterate(vpiCallback, (vpiHandle)(uintptr_t)1) == NULL, "foreign reference refused");
  expect_refusal_saying("foreign callback reference", "not a handle");
  return 0;
}

static PLI_INT32 finished(p_cb_data cb)
{
  CHECK(cb->reason == cbEndOfSimulation && now() == 8, "end of simulation");
  CHECK(changes == 2 && next_fired == 1 && three_fired == 1 && five_fired == 1, "all scheduled callbacks ran");
  callbacks(q, &q_cb, 1);
  callbacks(r, NULL, 0);
  callbacks(NULL, &end_cb, 1);
  CHECK(vpi_remove_cb(q_cb) == 1, "remove surviving q callback");
  callbacks(q, NULL, 0);
  puts("b26_callbacks: traversal and delivery ok");
  return 0;
}

static PLI_INT32 compiled(p_cb_data ignored)
{
  (void)ignored;
  q = p02_by_name("b26_callbacks.q");
  r = p02_by_name("b26_callbacks.r");
  end_cb = add(cbEndOfSimulation, q, finished, vpiSuppressTime, 0, "end");
  (void)add(cbReadOnlySynch, NULL, setup, vpiSimTime, 0, "setup");
  CHECK(vpi_remove_cb(compile_cb) == 1, "remove compile setup callback");
  return 0;
}

static void register_app(void)
{
  /* §26.2.4: startup registers; the design walk waits for compilation. */
  compile_cb = add(cbEndOfCompile, NULL, compiled, vpiSuppressTime, 0, "compiled");
}

void (*vlog_startup_routines[])(void) = { register_app, NULL };
