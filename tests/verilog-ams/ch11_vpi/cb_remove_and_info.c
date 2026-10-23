/* 07 — vpi_get_cb_info(), vpi_remove_cb(), and mutating the callback set from
 * inside a dispatch.
 *
 * LRM 12.6: "The VPI routine vpi_get_cb_info() shall return information about a
 * simulation-related callback in an s_cb_data structure. The memory for this
 * structure shall be allocated by the user."
 *
 * LRM 12.34: "The VPI routine vpi_remove_cb() shall remove callbacks which were
 * registered with vpi_register_cb(). The argument to this routine shall be a
 * handle to the callback object. The routine shall return a 1 (TRUE) if
 * successful, and a 0 (FALSE) on a failure. After vpi_remove_cb() is called
 * with a handle to the callback, the handle is no longer valid."
 *
 * LRM 12.33.2: "(Callbacks can also be registered or removed at any time during
 * an application routine, not just at startup time)." — which is the sentence
 * that makes the reentrancy below legal rather than undefined.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * Three callback lifetimes, each with a count that only comes out right if
 * removal and registration take effect at the exact moment they are performed.
 *
 * (A) SELF-REMOVAL DURING DISPATCH. `self` is a cbValueChange on p02_design.n,
 *     registered before time 0. n changes at t=0 (xxxx->0), 1 (->5), 2 (->9)
 *     and 4 (->2), and is rewritten without changing at t=3. `self` calls
 *     vpi_remove_cb on its OWN handle during its second invocation, i.e. while
 *     the t=1 dispatch is still on the stack. It must therefore be invoked
 *     exactly TWICE — at t=0 and t=1 — and not at t=2 or t=4. Three
 *     invocations would mean removal only took effect at the end of the current
 *     time step; four would mean it did nothing.
 *
 * (B) REGISTRATION DURING DISPATCH. From that same second invocation, `self`
 *     registers `heir`, another cbValueChange on n. The remaining changes on n
 *     are at t=2 and t=4, so `heir` must be invoked exactly TWICE, carrying 9
 *     and 2. Zero invocations would mean a registration made during a dispatch
 *     is lost; three would mean it somehow also saw the t=1 change it was
 *     created by.
 *
 * (C) REMOVAL BEFORE THE NEXT EVENT. `early` is a cbValueChange on
 *     p02_design.g, whose changes are at t=0 (xx->01), 5, 10 and 20. It is
 *     removed from an unrelated cbAtStartOfSimTime(2) callback, which is after
 *     the t=0 change and before the t=5 one. `early` must therefore be invoked
 *     exactly ONCE.
 *
 *     The removal call itself must return 1. A SECOND vpi_remove_cb with the
 *     same handle must return 0, because "after vpi_remove_cb() is called with
 *     a handle to the callback, the handle is no longer valid" — the only
 *     honest answer for an invalid handle is the documented failure value, and
 *     a routine that returns 1 twice is claiming to have removed the same
 *     callback twice.
 *
 * (D) ROUND TRIP. Before `early` is removed, vpi_get_cb_info() on its handle
 *     must report back every field the registration set: reason cbValueChange,
 *     cb_rtn the same function pointer, obj an object vpi_compare_objects()
 *     calls equal to g, user_data the same pointer, time->type vpiSimTime and
 *     value->format vpiIntVal. This is the only routine in P02 that can catch a
 *     registration that silently dropped a field.
 */

//! lrm 11.2.3
//! lrm 12.2
//! lrm 12.3
//! lrm 12.6
//! lrm 12.21
//! lrm 12.31.1
//! lrm 12.31.2
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 12.34
//! lrm-reject 12.34
//! lrm 12.6:2
//! lrm 12.34:1
//! lrm 12.34:3
//! lrm-reject 12.34:3
//! design ../digital/design.v
//! stdout p02: 07_cb_remove_and_info checks=38
//! stdout p02_design: t=20 reached

#include "p02_check.h"

static vpiHandle n, g;
static vpiHandle h_self, h_heir, h_early;

static int self_hits = 0, heir_hits = 0, early_hits = 0;
static PLI_INT32 heir_value[4];

static char early_tag[] = "early";

static int on_heir(p_cb_data cb_data)
{
  CHECK(heir_hits < 4, "heir fired more often than n changes");
  heir_value[heir_hits] = cb_data->value->value.integer;
  heir_hits++;
  return 0;
}

static int on_self(p_cb_data cb_data)
{
  self_hits++;
  if (self_hits == 1) {
    CHECK(cb_data->value->value.integer == 0, "first n change is xxxx -> 0");
    return 0;
  }

  CHECK(self_hits == 2, "on_self must not be reached a third time");
  CHECK(cb_data->value->value.integer == 5, "second n change is 0 -> 5");

  /* Remove this very callback while its own dispatch is on the stack. */
  CHECK(vpi_remove_cb(h_self) == 1, "vpi_remove_cb on the running callback");
  expect_no_error("vpi_remove_cb during dispatch");

  /* ...and register a replacement from the same place. */
  {
    static s_vpi_time  t = { vpiSimTime, 0, 0, 0.0 };
    static s_vpi_value v = { vpiIntVal, { 0 } };
    static s_cb_data   cb;
    cb.reason = cbValueChange; cb.cb_rtn = on_heir; cb.obj = n;
    cb.time = &t; cb.value = &v; cb.index = 0; cb.user_data = NULL;
    h_heir = vpi_register_cb(&cb);
    expect_no_error("vpi_register_cb during dispatch");
    CHECK(h_heir != NULL, "registering from inside a dispatch must succeed");
  }
  return 0;
}

static int on_early(p_cb_data cb_data)
{
  early_hits++;
  CHECK(cb_data->value->value.integer == 0x01,
        "the only g change `early` may see is xx -> 0x01 at t=0");
  return 0;
}

static int at2(p_cb_data cb_data)
{
  s_cb_data   info;
  s_vpi_time  itime;
  s_vpi_value ivalue;
  (void)cb_data;

  /* (D) the round trip, taken before the handle is invalidated. 12.6 puts the
   * structure's memory on the user, so the two sub-structures are the user's
   * too and are poisoned first to prove they get written. */
  memset(&info, 0, sizeof info);
  itime.type    = vpiSuppressTime;
  ivalue.format = vpiSuppressVal;
  info.time  = &itime;
  info.value = &ivalue;
  vpi_get_cb_info(h_early, &info);
  expect_no_error("vpi_get_cb_info");
  CHECK(info.reason == cbValueChange, "reason should round trip, got %d",
        (int)info.reason);
  CHECK(info.cb_rtn == on_early, "cb_rtn should round trip");
  CHECK(vpi_compare_objects(info.obj, g) == 1, "obj should round trip to g");
  CHECK(info.user_data == early_tag, "user_data should round trip by pointer");
  CHECK(info.time->type == vpiSimTime, "time->type should round trip");
  CHECK(info.value->format == vpiIntVal, "value->format should round trip");

  /* (C) the removal, and the second removal that must fail. */
  CHECK(early_hits == 1, "by t=2, `early` has seen exactly the t=0 change");
  CHECK(vpi_remove_cb(h_early) == 1, "removing a live callback must return 1");
  expect_no_error("vpi_remove_cb");
  CHECK(vpi_remove_cb(h_early) == 0,
        "the handle is no longer valid, so a second removal must return 0");
  expect_error("vpi_remove_cb on an already-removed handle");
  return 0;
}

static int census(p_cb_data cb_data)
{
  (void)cb_data;
  CHECK(self_hits == 2,
        "self-removal during the t=1 dispatch leaves exactly 2 invocations, got %d",
        self_hits);
  CHECK(heir_hits == 2,
        "a callback registered during the t=1 dispatch sees the t=2 and t=4 "
        "changes: want 2 invocations, got %d", heir_hits);
  CHECK(heir_value[0] == 9, "heir's first value should be 9, got %d", (int)heir_value[0]);
  CHECK(heir_value[1] == 2, "heir's second value should be 2, got %d", (int)heir_value[1]);
  CHECK(early_hits == 1,
        "`early` was removed at t=2, before g's t=5 change: want 1, got %d",
        early_hits);
  p02_done("07_cb_remove_and_info");
  return 0;
}

static int on_start_of_simulation(p_cb_data cb_data)
{
  static s_vpi_time  st = { vpiSimTime, 0, 0, 0.0 };
  static s_vpi_value sv = { vpiIntVal, { 0 } };
  static s_vpi_time  et = { vpiSimTime, 0, 0, 0.0 };
  static s_vpi_value ev = { vpiIntVal, { 0 } };
  static s_vpi_time  t2 = { vpiSimTime, 0, 2, 0.0 };
  static s_vpi_time  tz = { vpiSimTime, 0, 30, 0.0 };
  static s_cb_data   scb, ecb, acb, ccb;
  (void)cb_data;

  n = p02_by_name("p02_design.n");
  g = p02_by_name("p02_design.g");

  scb.reason = cbValueChange; scb.cb_rtn = on_self; scb.obj = n;
  scb.time = &st; scb.value = &sv; scb.index = 0; scb.user_data = NULL;
  h_self = vpi_register_cb(&scb);
  CHECK(h_self != NULL, "`self` failed to register");

  ecb.reason = cbValueChange; ecb.cb_rtn = on_early; ecb.obj = g;
  ecb.time = &et; ecb.value = &ev; ecb.index = 0; ecb.user_data = early_tag;
  h_early = vpi_register_cb(&ecb);
  CHECK(h_early != NULL, "`early` failed to register");

  acb.reason = cbAtStartOfSimTime; acb.cb_rtn = at2; acb.obj = NULL;
  acb.time = &t2; acb.value = NULL; acb.index = 0; acb.user_data = NULL;
  CHECK(vpi_register_cb(&acb) != NULL, "the t=2 callback failed to register");

  ccb.reason = cbReadOnlySynch; ccb.cb_rtn = census; ccb.obj = NULL;
  ccb.time = &tz; ccb.value = NULL; ccb.index = 0; ccb.user_data = NULL;
  CHECK(vpi_register_cb(&ccb) != NULL, "the census callback failed to register");
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
