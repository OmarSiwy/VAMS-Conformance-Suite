/* 03 — vpi_put_value()'s six delay modes, its scheduled-event object, and the
 * exact set of events each mode removes.
 *
 * LRM 12.30: "The flags argument shall be used to direct the routine to use one
 * of the following delay modes:
 *
 *   vpiInertialDelay       All scheduled events on the object shall be removed
 *                          before this event is scheduled.
 *   vpiTransportDelay      All events on the object scheduled for times later
 *                          than this event shall be removed (modified transport
 *                          delay).
 *   vpiPureTransportDelay  No events on the object shall be removed (transport
 *                          delay).
 *   vpiNoDelay             The object shall be set to the passed value with no
 *                          delay. Argument time_p shall be ignored and can be
 *                          set to NULL."
 *
 * LRM 12.30: "If the flags argument also has the bit mask vpiReturnEvent,
 * vpi_put_value() shall return a handle of type vpiSchedEvent to the newly
 * scheduled event, provided there is some form of a delay and an event is
 * scheduled. If the bit mask is not used, or if no delay is used, or if an
 * event is not scheduled, the return value shall be NULL."
 *
 * LRM 12.30: "The scheduled event can be tested by calling vpi_get() with the
 * flag vpiScheduled." ... "It shall not be an error to cancel an event which
 * has already occurred." ... "Calling vpi_free_object() on the handle shall
 * free the handle but shall not effect the event."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * Three 8-bit regs, qi/qt/qp, are set to 0x00 by the design at t=0 and are
 * never touched by the design again, so every transition below is this
 * application's. From cbReadWriteSynch(t=0) — 12.31.2: "cbReadWriteSynch
 * Callback shall occur after execution of events for a specified time", which
 * is where the design's own initialisation has already landed and where
 * writing is still legal — each reg receives the SAME three puts in the SAME
 * order, differing only in the delay mode of the third:
 *
 *   1.  0xAA at +5    vpiPureTransportDelay
 *   2.  0xBB at +20   vpiPureTransportDelay
 *   3.  0xCC at +10   qi: vpiInertialDelay
 *                     qt: vpiTransportDelay
 *                     qp: vpiPureTransportDelay
 *
 * At the moment of put 3 the object's pending set is {0xAA@5, 0xBB@20}.
 *
 *   qp, pure transport: "No events on the object shall be removed" — both
 *       survive. Timeline 0x00, AA@5, CC@10, BB@20.
 *   qt, transport: "All events on the object scheduled for times LATER than
 *       this event shall be removed" — 20 > 10 so BB dies; 5 < 10 so AA lives.
 *       Timeline 0x00, AA@5, CC@10, and CC thereafter.
 *   qi, inertial: "ALL scheduled events on the object shall be removed" — both
 *       AA and BB die, including the one EARLIER than the new event, which is
 *       the only thing separating inertial from transport here.
 *       Timeline 0x00 all the way to CC@10, and CC thereafter.
 *
 * Sampled at t = 5, 10, 20, 27, 30 the hand-computed table is:
 *
 *          t=5    t=10   t=20   t=27   t=30
 *   qi     0x00   0xCC   0xCC   0xCC   (see vpiNoDelay below)
 *   qt     0xAA   0xCC   0xCC   0xCC   0xCC
 *   qp     0xAA   0xCC   0xBB   0xEE   0xEE
 *
 * qp additionally carries the scheduled-event object checks, which need events
 * that outlive their handles:
 *
 *   4.  0xDD at +30, vpiPureTransportDelay|vpiReturnEvent, handle kept and
 *       CANCELLED at t=20 -> DD never lands, so qp is not 0xDD at t=30.
 *   5.  0xEE at +25, vpiPureTransportDelay|vpiReturnEvent, handle FREED at t=0
 *       -> freeing the handle must not unschedule anything, so qp IS 0xEE from
 *       t=25 on. That is why the t=27 and t=30 columns read 0xEE and not 0xBB.
 *
 * Finally vpiNoDelay, applied to qi at t=27: the put takes effect before
 * vpi_get_value() can observe anything else, and — even with vpiReturnEvent
 * ORed in — returns NULL, because "if no delay is used ... the return value
 * shall be NULL". qi therefore reads 0x5A at t=27 after the put and at t=30.
 */

//! lrm 11.3.2
//! lrm 12.2
//! lrm 12.4
//! lrm 12.5
//! lrm 12.16
//! lrm 12.21
//! lrm 12.30
//! lrm 12.31.2
//! lrm 12.33.2
//! lrm 11.3.2:1000
//! lrm 12.4:1
//! lrm 12.4:4
//! lrm 12.30:1
//! lrm 12.30:4
//! lrm 12.30:5
//! lrm 12.30:8
//! lrm 12.30:10
//! lrm 12.30:11
//! lrm 12.30:12
//! lrm 12.30:13
//! lrm 12.30:15
//! lrm 12.31.2:7
//! design ../digital/design.v
//! stdout p02: 03_put_value_delays checks=64
//! stdout p02_design: t=20 reached

#include "p02_check.h"

static vpiHandle qi, qt, qp;
static vpiHandle ev_cc_qp, ev_dd, ev_ee;

static PLI_INT32 byte_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  expect_no_error("vpi_get_value(vpiIntVal)");
  return v.value.integer;
}

static vpiHandle put_byte(vpiHandle h, int byte, int delay, PLI_INT32 flags)
{
  s_vpi_value v;
  s_vpi_time  t;
  v.format    = vpiIntVal;
  v.value.integer = byte;
  t.type      = vpiSimTime;
  t.high      = 0;
  t.low       = (PLI_UINT32)delay;
  t.real      = 0.0;
  return vpi_put_value(h, &v, &t, flags);
}

static int schedule_everything(p_cb_data cb_data)
{
  vpiHandle unused;
  (void)cb_data;

  qi = p02_by_name("p02_design.qi");
  qt = p02_by_name("p02_design.qt");
  qp = p02_by_name("p02_design.qp");

  CHECK(byte_of(qi) == 0x00, "qi should still be 0x00 after the time-0 queue");
  CHECK(byte_of(qt) == 0x00, "qt should still be 0x00 after the time-0 queue");
  CHECK(byte_of(qp) == 0x00, "qp should still be 0x00 after the time-0 queue");

  put_byte(qi, 0xAA, 5,  vpiPureTransportDelay);
  put_byte(qi, 0xBB, 20, vpiPureTransportDelay);
  put_byte(qi, 0xCC, 10, vpiInertialDelay);

  put_byte(qt, 0xAA, 5,  vpiPureTransportDelay);
  put_byte(qt, 0xBB, 20, vpiPureTransportDelay);
  put_byte(qt, 0xCC, 10, vpiTransportDelay);

  put_byte(qp, 0xAA, 5,  vpiPureTransportDelay);
  put_byte(qp, 0xBB, 20, vpiPureTransportDelay);
  ev_cc_qp = put_byte(qp, 0xCC, 10, vpiPureTransportDelay | vpiReturnEvent);
  expect_no_error("vpi_put_value(vpiReturnEvent)");
  CHECK(ev_cc_qp != NULL, "vpiReturnEvent with a delay must return a handle");
  CHECK(vpi_get(vpiType, ev_cc_qp) == vpiSchedEvent,
        "the returned handle must be a vpiSchedEvent, got %d",
        (int)vpi_get(vpiType, ev_cc_qp));
  CHECK(vpi_get(vpiScheduled, ev_cc_qp) == 1,
        "an event that has not fired yet must read vpiScheduled == 1");

  /* Without vpiReturnEvent the same call returns NULL and is not an error. */
  unused = put_byte(qp, 0xBB, 20, vpiPureTransportDelay);
  expect_no_error("vpi_put_value without vpiReturnEvent");
  CHECK(unused == NULL, "no vpiReturnEvent mask means a NULL return");

  ev_dd = put_byte(qp, 0xDD, 30, vpiPureTransportDelay | vpiReturnEvent);
  CHECK(ev_dd != NULL, "the 0xDD event handle is needed to cancel it later");

  ev_ee = put_byte(qp, 0xEE, 25, vpiPureTransportDelay | vpiReturnEvent);
  CHECK(ev_ee != NULL, "the 0xEE event handle is needed to free it");
  /* "Calling vpi_free_object() on the handle shall free the handle but shall
   * not effect the event." Freed here, at t=0, twenty-five ticks before the
   * event it names is due. The t=27 sample is what proves it still fired. */
  CHECK(vpi_free_object(ev_ee) == 1, "vpi_free_object on a vpiSchedEvent");
  expect_no_error("vpi_free_object(vpiSchedEvent)");
  ev_ee = NULL;

  return 0;
}

static int sample(p_cb_data cb_data)
{
  long when = (long)(size_t)cb_data->user_data;

  switch (when) {
  case 5:
    CHECK(byte_of(qi) == 0x00, "t=5: inertial removed the 0xAA event, qi must be 0x00");
    CHECK(byte_of(qt) == 0xAA, "t=5: transport keeps the EARLIER event, qt must be 0xAA");
    CHECK(byte_of(qp) == 0xAA, "t=5: pure transport keeps everything, qp must be 0xAA");
    break;
  case 10:
    CHECK(byte_of(qi) == 0xCC, "t=10: qi must be 0xCC");
    CHECK(byte_of(qt) == 0xCC, "t=10: qt must be 0xCC");
    CHECK(byte_of(qp) == 0xCC, "t=10: qp must be 0xCC");
    CHECK(vpi_get(vpiScheduled, ev_cc_qp) == 0,
          "an event that has fired must read vpiScheduled == 0");
    break;
  case 20:
    CHECK(byte_of(qi) == 0xCC, "t=20: inertial removed the 0xBB event, qi must still be 0xCC");
    CHECK(byte_of(qt) == 0xCC, "t=20: transport removed the LATER event, qt must still be 0xCC");
    CHECK(byte_of(qp) == 0xBB, "t=20: pure transport kept 0xBB@20, qp must be 0xBB");
    /* "It shall not be an error to cancel an event which has already
     * occurred." ev_cc_qp fired ten ticks ago. */
    vpi_put_value(ev_cc_qp, NULL, NULL, vpiCancelEvent);
    expect_no_error("vpiCancelEvent on an event that already occurred");
    /* This one has NOT occurred, and must not: qp is asserted to be 0xEE, not
     * 0xDD, at t=30. */
    vpi_put_value(ev_dd, NULL, NULL, vpiCancelEvent);
    expect_no_error("vpiCancelEvent on a pending event");
    CHECK(vpi_get(vpiScheduled, ev_dd) == 0,
          "a cancelled event must read vpiScheduled == 0");
    break;
  case 27: {
    s_vpi_value v;
    vpiHandle   r;
    CHECK(byte_of(qp) == 0xEE,
          "t=27: freeing the handle must not unschedule the event, qp must be 0xEE");
    CHECK(byte_of(qi) == 0xCC, "t=27: qi is still 0xCC before the vpiNoDelay put");
    v.format = vpiIntVal;
    v.value.integer = 0x5A;
    r = vpi_put_value(qi, &v, NULL, vpiNoDelay | vpiReturnEvent);
    expect_no_error("vpi_put_value(vpiNoDelay)");
    CHECK(r == NULL, "vpiNoDelay schedules no event, so the return must be NULL");
    CHECK(byte_of(qi) == 0x5A, "vpiNoDelay takes effect immediately, qi must be 0x5A");
    break;
  }
  case 30:
    CHECK(byte_of(qi) == 0x5A, "t=30: qi keeps the vpiNoDelay value");
    CHECK(byte_of(qt) == 0xCC, "t=30: qt keeps 0xCC");
    CHECK(byte_of(qp) == 0xEE, "t=30: the cancelled 0xDD event must not have landed");
    p02_done("03_put_value_delays");
    break;
  }
  return 0;
}

static void at(PLI_INT32 reason, PLI_INT32 (*fn)(p_cb_data), PLI_UINT32 when)
{
  static s_vpi_time times[8];
  static s_cb_data  cbs[8];
  static int        used = 0;
  int i = used++;

  times[i].type = vpiSimTime;
  times[i].high = 0;
  times[i].low  = when;
  times[i].real = 0.0;

  cbs[i].reason    = reason;
  cbs[i].cb_rtn    = fn;
  cbs[i].obj       = NULL;
  cbs[i].time      = &times[i];
  cbs[i].value     = NULL;
  cbs[i].index     = 0;
  cbs[i].user_data = (PLI_BYTE8 *)(size_t)when;

  CHECK(vpi_register_cb(&cbs[i]) != NULL, "registration at t=%u failed", when);
}

static void setup_after_compile(void)
{
  at(cbReadWriteSynch, schedule_everything, 0);
  at(cbReadOnlySynch,  sample,  5);
  at(cbReadOnlySynch,  sample, 10);
  at(cbReadWriteSynch, sample, 20);   /* cancels, so it must be read/WRITE */
  at(cbReadWriteSynch, sample, 27);   /* puts with vpiNoDelay */
  at(cbReadOnlySynch,  sample, 30);
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
