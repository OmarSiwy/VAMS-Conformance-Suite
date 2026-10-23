/* 05 — the five simulation-time-related callback reasons of LRM 12.31.2, what
 * each of them can see, vpi_get_time()'s two time formats, and 11.6.25's time
 * queue ordering.
 *
 * LRM 12.31.2:
 *   "cbAtStartOfSimTime  Callback shall occur before execution of events in a
 *                        specified time queue. A callback can be set for any
 *                        time, even if no event is present.
 *    cbReadWriteSynch    Callback shall occur after execution of events for a
 *                        specified time.
 *    cbReadOnlySynch     Same as cbReadWriteSynch, except writing values or
 *                        scheduling events before the next scheduled event is
 *                        not allowed.
 *    cbNextSimTime       Callback shall occur before execution of events in the
 *                        next event queue.
 *    cbAfterDelay        Callback shall occur after a specified amount of time,
 *                        before execution of events in a specified time queue.
 *                        A callback can be set for anytime, even if no event is
 *                        present."
 *
 * LRM 12.31.2: "When the cb_data_p->time->type is set to vpiScaledRealTime, the
 * cb_data_p->obj field shall be used as the object for determining the time
 * scaling." and "For reason cbNextSimTime, the time structure is ignored."
 *
 * LRM 12.15: "vpi_get_time() shall retrieve the current simulation time, using
 * the time scale of the object. If obj is NULL, the simulation time is
 * retrieved using the simulation time unit."
 *
 * LRM 11.6.25, NOTE 3: "The time queue objects shall be returned in increasing
 * order of simulation time." and its property list: "Time queue properties:
 * -> time — vpi_get_time()". Its data model: "Callback has one-to-one
 * relationships to expr, prim term, stmt, and time queue (tagged vpiParent)",
 * and NOTE 4: "vpi_iterate() shall return NULL if there is nothing left in the
 * simulation queue."
 *
 * LRM 12.31.4: "cbEndOfSimulation  End of simulation (e.g., $finish system task
 * executed)" — an action reason, and "actions shall occur in all VPI-compliant
 * products", which is why the census below hangs off it.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * BEFORE versus AFTER. p02_design.s is 0x01 from t=0 and becomes 0x42 in the
 * t=7 queue, and nothing else ever writes it. So the reading of `s` inside a
 * callback at t=7 IS the answer to "which side of the t=7 queue am I on":
 *
 *   cbAtStartOfSimTime(7)  before the queue  ->  s == 0x01
 *   cbAfterDelay(+7 from 0) before the queue ->  s == 0x01
 *   cbReadWriteSynch(7)    after  the queue  ->  s == 0x42
 *   cbReadOnlySynch(7)     after  the queue  ->  s == 0x42, and a write refused
 *
 * A sequence counter additionally pins the only ordering 12.31.2 actually
 * states: both "before" callbacks must run before both "after" callbacks. The
 * relative order WITHIN each pair is not stated by the LRM and is deliberately
 * not asserted here (see tests/fixtures/ch11_vpi/p02_SPEC.md at 8b1514d4).
 *
 * cbAfterDelay's absolute time. It is registered from cbStartOfSimulation,
 * which 12.31.4 defines as "Start of simulation (beginning of time 0 simulation
 * cycle)". A delay of 7 from t=0 is therefore t=7, and s must read 0x01 there,
 * exactly as for cbAtStartOfSimTime(7). If the implementation instead measured
 * the delay from the startup routine or from the first event, this check and
 * the `low == 7` check below would disagree with each other.
 *
 * cbNextSimTime. Registered at t=0, it fires "before execution of events in the
 * NEXT event queue". p02_design's six initial blocks all reach their first
 * delay during t=0, leaving pending design times {1, 5, 6, 7, 40}; this file
 * adds one more of its own at 33 (see TIME QUEUE) and none below 1. The next
 * queue is therefore t=1 either way, and s is still 0x01 there. Asserting the
 * time is what makes this a test — a callback that fired at t=7 would read the
 * same 0x01.
 *
 * TIME FORMATS. `timescale 1ns/1ns everywhere in the P02 set, so the global
 * simulation time unit is 1 ns and 12.15's "simulation time unit" reading of
 * t=7 ns is 7 ticks:
 *
 *   vpi_get_time(NULL, {vpiSimTime})            -> high = 0, low = 7
 *   vpi_get_time(p02_design, {vpiScaledRealTime}) -> real = 7.0
 *     because p02_design's own `timescale unit is also 1 ns: 7 ns / 1 ns = 7.0,
 *     exactly representable, so `== 7.0` is legal without a tolerance.
 *
 * TIME QUEUE. Iterating vpiTimeQueue is done from cbAtStartOfSimTime(2), i.e.
 * before the t=2 queue runs. The set of pending times strictly greater than 2
 * has two sources and BOTH are counted, because 11.6.25's data model puts a
 * callback in a time queue (tagged vpiParent) exactly as it puts an event
 * there, and NOTE 4 speaks of "the simulation queue" without partitioning it:
 *
 *   from the DESIGN   5  the g block's #5
 *                     6  the a block's #6
 *                     7  the s block's #7
 *                    40  the #40 backstop
 *   from THIS FILE   33  a cbAtStartOfSimTime this application registers at a
 *                        time p02_design never visits — legal because 12.31.2
 *                        says of that reason "A callback can be set for any
 *                        time, even if no event is present".
 *
 * so the assertion is: exactly {5, 6, 7, 33, 40}. An earlier revision of this
 * file asserted {5, 6, 7, 40} while registering a callback at t=30; that is a
 * queue this file had itself polluted, and the cheapest way to satisfy it would
 * have been to hide callback wake-ups from vpiTimeQueue — which 11.6.25's
 * vpiParent edge says are exactly what belongs there. The t=30 registration is
 * gone (the census moved to cbEndOfSimulation) and t=33 is now declared,
 * asserted to fire, and asserted to be visible in the walk. Getting rid of the
 * callback-only time altogether would have been the weaker repair: it would
 * leave the one thing 11.6.25 states about callbacks and queues untested.
 *
 * The t=3 step of the n block is NOT in the set: at cbAtStartOfSimTime(2) the
 * t=2 queue has not run, and t=3 is created only when the t=2 event executes.
 *
 * t=999 is asserted ABSENT. The cbNextSimTime registration below passes
 * time->low = 999, and 12.31.2 says "For reason cbNextSimTime, the time
 * structure is ignored" — so it must schedule nothing at 999. Since the walk
 * checks the whole subsequence above 2 for an exact match, a 999 entry fails
 * it, which is the only way this file can observe that the sentence was obeyed
 * rather than merely producing a callback that happened to land at t=1.
 *
 * THE CURRENT QUEUE. IEEE 1364-2005 26.6.40(c): "The current time queue shall
 * only be returned as part of the iteration if there are events that precede
 * read only sync." 11.6.25 NOTE 5: "If any events after read only sync remain
 * in the current queue, then it shall not be returned as part of the
 * iteration." The two differ when an event AND a read-only-sync callback are
 * both pending now; specification/Vague_Decisions.md VD-046 takes 26.6.40's reading
 * (NOTE 5 as "if only events after read only sync remain"). Two walks at t=7,
 * where this file has cbReadOnlySynch(7) pending throughout:
 *
 *   cbAtStartOfSimTime(7)  the s block's #7 event is still to run, and it
 *                          precedes read-only sync -> the first queue is t=7
 *   cbReadWriteSynch(7)    "after execution of events for a specified time":
 *                          the s event has run and nothing else is due at 7
 *                          (the n block finished at 4, g waits for 10). Only
 *                          cbReadOnlySynch(7) is left -> t=7 is absent, and
 *                          the first queue is the g block's t=10
 *
 * The first walk is the mixed case, so it separates 26.6.40 from NOTE 5 read
 * literally; the second is the case both readings omit. Neither has an
 * invalid form: what the iteration contains is not something a caller can
 * get wrong (the refusals of vpi_iterate(vpiTimeQueue, ...) are p04_04's and
 * ieee_pli/behaviour.c's).
 */

//! lrm 11.2.1
//! lrm 11.2.3
//! lrm 11.6.25
//! lrm 12.2
//! lrm 12.15
//! lrm 12.16
//! lrm 12.21
//! lrm 12.23
//! lrm 12.31
//! lrm 12.31.2
//! lrm-reject 12.31.2
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 12.35
//! inherited IEEE 1364-2005 26.6.40
//! lrm 11.2.1:3
//! lrm 12.15:1
//! lrm 12.31:2
//! lrm 12.31.2:1
//! lrm 12.31.2:2
//! lrm-reject 12.31.2:2
//! lrm 12.31.2:3
//! lrm 12.31.2:6
//! design ../digital/design.v
//! stdout p02: 05_cb_time_regions checks=82
//! stdout p02_design: t=20 reached

#include "p02_check.h"

static vpiHandle s, top;
static int order = 0;
static int seq_start = 0, seq_after = 0, seq_rw = 0, seq_ro = 0;
static int n_start = 0, n_after = 0, n_rw = 0, n_ro = 0, n_next = 0;
static int n_eventless = 0, n_walk = 0;

static PLI_INT32 byte_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  return v.value.integer;
}

static void check_time_is(PLI_UINT32 ticks, const char *what)
{
  s_vpi_time t;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  expect_no_error("vpi_get_time(NULL, vpiSimTime)");
  CHECK(t.high == 0 && t.low == ticks,
        "%s: vpi_get_time(NULL) should read %u ticks, got high=%u low=%u",
        what, (unsigned)ticks, (unsigned)t.high, (unsigned)t.low);
}

/* The time of the first vpiTimeQueue entry, or 0 for an empty iteration. */
static PLI_UINT32 first_queue_time(void)
{
  s_vpi_time t;
  vpiHandle  itr = vpi_iterate(vpiTimeQueue, NULL), q;
  expect_no_error("vpi_iterate(vpiTimeQueue, NULL)");
  if (itr == NULL) return 0;
  q = vpi_scan(itr);
  CHECK(q != NULL, "a non-NULL iterator holds a queue");
  t.type = vpiSimTime;
  vpi_get_time(q, &t);
  vpi_free_object(itr);
  return t.low;
}

static int on_start_of_sim_time(p_cb_data cb_data)
{
  n_start++;
  seq_start = ++order;
  CHECK(cb_data->reason == cbAtStartOfSimTime, "reason must be echoed back");
  /* Registered with vpiScaledRealTime and obj = p02_design, whose `timescale
   * unit is 1 ns: 7 ns scaled by 1 ns is 7.0. */
  CHECK(cb_data->time->type == vpiScaledRealTime,
        "the callback's time must arrive in the registered type");
  CHECK(cb_data->time->real == 7.0,
        "cbAtStartOfSimTime(7) scaled to 1 ns should be 7.0, got %f",
        cb_data->time->real);
  check_time_is(7, "cbAtStartOfSimTime(7)");
  CHECK(byte_of(s) == 0x01, "before the t=7 queue, s must still be 0x01");
  CHECK(first_queue_time() == 7,
        "26.6.40(c): the s event precedes read-only sync, so the current t=7 "
        "queue is returned although cbReadOnlySynch(7) is pending too");
  return 0;
}

static int on_after_delay(p_cb_data cb_data)
{
  n_after++;
  seq_after = ++order;
  CHECK(cb_data->reason == cbAfterDelay, "reason must be echoed back");
  CHECK(cb_data->time->type == vpiSimTime, "registered with vpiSimTime");
  CHECK(cb_data->time->low == 7 && cb_data->time->high == 0,
        "a delay of 7 from t=0 lands at t=7, got low=%u", (unsigned)cb_data->time->low);
  CHECK(byte_of(s) == 0x01, "cbAfterDelay runs before the t=7 queue, so s is 0x01");
  return 0;
}

static int on_read_write(p_cb_data cb_data)
{
  n_rw++;
  seq_rw = ++order;
  (void)cb_data;
  check_time_is(7, "cbReadWriteSynch(7)");
  CHECK(byte_of(s) == 0x42, "after the t=7 queue, s must be 0x42");
  CHECK(first_queue_time() == 10,
        "26.6.40(c): only cbReadOnlySynch(7) is left at t=7, so the current "
        "queue is not returned and the first is t=10");
  return 0;
}

static int on_read_only(p_cb_data cb_data)
{
  s_vpi_value v;
  vpiHandle   r;
  n_ro++;
  seq_ro = ++order;
  (void)cb_data;

  CHECK(byte_of(s) == 0x42, "cbReadOnlySynch also runs after the t=7 queue");

  /* "except writing values or scheduling events ... is not allowed" — a put
   * here is a refusal, reported the documented way rather than by crashing or
   * by silently corrupting the queue. */
  v.format = vpiIntVal;
  v.value.integer = 0x99;
  r = vpi_put_value(s, &v, NULL, vpiNoDelay);
  CHECK(r == NULL, "a write from cbReadOnlySynch must not succeed");
  expect_error("vpi_put_value from cbReadOnlySynch");
  CHECK(byte_of(s) == 0x42, "and must not have changed the object");
  return 0;
}

static int on_next_sim_time(p_cb_data cb_data)
{
  n_next++;
  (void)cb_data;
  /* Registered at t=0; the next queue after t=0 is t=1. */
  check_time_is(1, "cbNextSimTime registered at t=0");
  CHECK(byte_of(s) == 0x01, "s does not move until t=7");
  return 0;
}

/* 12.31.2: "A callback can be set for any time, even if no event is present."
 * p02_design has no event at t=33 and this is the only thing scheduled there,
 * so firing at all is the assertion; s has been 0x42 since t=7. */
static int on_eventless_time(p_cb_data cb_data)
{
  n_eventless++;
  CHECK(cb_data->reason == cbAtStartOfSimTime, "reason must be echoed back");
  CHECK(cb_data->time->low == 33 && cb_data->time->high == 0,
        "a callback set for an eventless t=33 must be delivered at 33, got %u",
        (unsigned)cb_data->time->low);
  check_time_is(33, "cbAtStartOfSimTime(33), a time with no design event");
  CHECK(byte_of(s) == 0x42, "s has read 0x42 since t=7");
  return 0;
}

static int walk_time_queue(p_cb_data cb_data)
{
  vpiHandle itr, q;
  /* 5, 6, 7 and 40 are p02_design's; 33 is this application's own eventless
   * cbAtStartOfSimTime. See the TIME QUEUE derivation in the header. */
  PLI_UINT32 expect[5] = { 5, 6, 7, 33, 40 };
  int matched = 0;
  PLI_UINT32 previous = 0;
  int first = 1;
  (void)cb_data;

  n_walk++;
  itr = vpi_iterate(vpiTimeQueue, NULL);
  expect_no_error("vpi_iterate(vpiTimeQueue, NULL)");
  CHECK(itr != NULL, "the queue is not empty at t=2, so the iterator must exist");

  while ((q = vpi_scan(itr)) != NULL) {
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(q, &t);
    CHECK(t.high == 0, "no P02 time needs the high word, got high=%u",
          (unsigned)t.high);
    CHECK(first || t.low > previous,
          "11.6.25 NOTE 3: queue times must strictly increase, %u followed %u",
          (unsigned)t.low, (unsigned)previous);
    first = 0;
    previous = t.low;
    if (t.low > 2) {
      CHECK(matched < 5,
            "more pending times above 2 than {5,6,7,33,40}: extra at t=%u "
            "(t=999 here would mean cbNextSimTime's time was not ignored)",
            (unsigned)t.low);
      CHECK(t.low == expect[matched],
            "pending time %d above 2 should be t=%u, got t=%u",
            matched, (unsigned)expect[matched], (unsigned)t.low);
      matched++;
    }
  }
  CHECK(matched == 5,
        "at t=2 the pending times above 2 are exactly {5,6,7,33,40} — four from "
        "p02_design and one from this file's eventless callback; found %d",
        matched);
  return 0;
}

static int census(p_cb_data cb_data)
{
  (void)cb_data;
  CHECK(n_start == 1, "cbAtStartOfSimTime must fire exactly once, fired %d", n_start);
  CHECK(n_after == 1, "cbAfterDelay must fire exactly once, fired %d", n_after);
  CHECK(n_rw    == 1, "cbReadWriteSynch must fire exactly once, fired %d", n_rw);
  CHECK(n_ro    == 1, "cbReadOnlySynch must fire exactly once, fired %d", n_ro);
  CHECK(n_next  == 1, "cbNextSimTime must fire exactly once, fired %d", n_next);
  CHECK(n_walk  == 1, "the t=2 queue walk must happen exactly once, ran %d", n_walk);
  CHECK(n_eventless == 1,
        "12.31.2's \"even if no event is present\": the t=33 callback must fire "
        "exactly once, fired %d", n_eventless);

  /* The only ordering 12.31.2 states, asserted as a partial order. */
  CHECK(seq_start < seq_rw && seq_start < seq_ro,
        "cbAtStartOfSimTime must precede both synch callbacks");
  CHECK(seq_after < seq_rw && seq_after < seq_ro,
        "cbAfterDelay must precede both synch callbacks");

  p02_done("05_cb_time_regions");
  return 0;
}

static void reg(PLI_INT32 reason, PLI_INT32 (*fn)(p_cb_data), PLI_INT32 ttype,
                PLI_UINT32 low, double real, vpiHandle obj)
{
  static s_vpi_time times[8];
  static s_cb_data  cbs[8];
  static int        used = 0;
  int i = used++;

  times[i].type = ttype;
  times[i].high = 0;
  times[i].low  = low;
  times[i].real = real;

  cbs[i].reason    = reason;
  cbs[i].cb_rtn    = fn;
  cbs[i].obj       = obj;
  cbs[i].time      = &times[i];
  cbs[i].value     = NULL;
  cbs[i].index     = 0;
  cbs[i].user_data = NULL;

  CHECK(vpi_register_cb(&cbs[i]) != NULL, "registration for reason %d failed",
        (int)reason);
}

static int on_start_of_simulation(p_cb_data cb_data)
{
  (void)cb_data;
  s   = p02_by_name("p02_design.s");
  top = p02_by_name("p02_design");

  check_time_is(0, "cbStartOfSimulation");

  reg(cbAtStartOfSimTime, on_start_of_sim_time, vpiScaledRealTime, 0, 7.0, top);
  reg(cbAfterDelay,       on_after_delay,       vpiSimTime,        7, 0.0, NULL);
  reg(cbReadWriteSynch,   on_read_write,        vpiSimTime,        7, 0.0, NULL);
  reg(cbReadOnlySynch,    on_read_only,         vpiSimTime,        7, 0.0, NULL);
  /* "For reason cbNextSimTime, the time structure is ignored" — a deliberately
   * absurd 999 is passed to prove it. */
  reg(cbNextSimTime,      on_next_sim_time,     vpiSimTime,      999, 0.0, NULL);
  reg(cbAtStartOfSimTime, walk_time_queue,      vpiSimTime,        2, 0.0, NULL);
  /* 12.31.2: "A callback can be set for any time, even if no event is present."
   * t=33 is such a time, and it is the ONE time in this file's registrations
   * that p02_design does not already visit — every other registered time (1 via
   * cbNextSimTime, 2, 7) coincides with a design event, so the walk's expected
   * set is {design times} + {33} and nothing is counted twice. */
  reg(cbAtStartOfSimTime, on_eventless_time,    vpiSimTime,       33, 0.0, NULL);

  /* The census is an ACTION callback, not a time callback: hanging it off a
   * cbReadOnlySynch at some invented time would put that time into the very
   * vpiTimeQueue walk_time_queue measures. 12.31.4's cbEndOfSimulation is
   * guaranteed to occur (p02_design's #40 $finish(0) is the backstop) and adds
   * no time queue at all. Per 12.31.4 only reason and cb_rtn are set. */
  {
    static s_cb_data end_cb;
    end_cb.reason = cbEndOfSimulation;
    end_cb.cb_rtn = census;
    end_cb.obj = NULL; end_cb.time = NULL; end_cb.value = NULL;
    end_cb.index = 0; end_cb.user_data = NULL;
    CHECK(vpi_register_cb(&end_cb) != NULL,
          "cbEndOfSimulation registration for the census failed");
  }
  return 0;
}

static void setup(void)
{
  static s_cb_data start;
  start.reason = cbStartOfSimulation;
  start.cb_rtn = on_start_of_simulation;
  start.obj = NULL; start.time = NULL; start.value = NULL;
  start.index = 0; start.user_data = NULL;
  CHECK(vpi_register_cb(&start) != NULL, "cbStartOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
