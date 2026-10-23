/* b 27.33 callbacks — vpi_register_cb(), vpi_get_cb_info(), vpi_remove_cb(),
 * over digital/design.v (`timescale 1ns/1ns: one tick is 1 ns; its
 * header lists the timeline this file derives from).
 *
 * IEEE 1364-2005:
 *
 * §26.2.1, p. 375-376: "Dynamic software product interaction shall be
 * accomplished with a registered callback mechanism." "VPI callbacks shall be
 * registered by the application with the functions vpi_register_cb() and
 * vpi_register_systf(). These routines indicate the specific reason for the
 * callback, the application routines to be called, and what system and
 * user_data shall be passed to the callback application when the callback
 * occurs."
 *
 * §27.7, p. 422: "The VPI routine vpi_get_cb_info() shall return information
 * about a simulation-related callback in an s_cb_data structure. The memory
 * for this structure shall be allocated by the application."
 *
 * §27.33, p. 454: "For all callbacks, the reason field of the s_cb_data
 * structure shall be set to a predefined constant ... The cb_rtn field of the
 * s_cb_data structure shall be set to the application routine, which shall be
 * invoked when the simulator executes the callback." "The callback routine
 * shall be passed a pointer to an s_cb_data structure."
 *
 * §27.33.1, p. 454: "cbValueChange After value change on an expression or
 * terminal". p. 455: "cb_data_p->obj This field shall be assigned a handle to
 * an expression, terminal, or statement for which the callback shall occur."
 * p. 455: "When a simulation event callback occurs, the application shall be
 * passed a single argument, which is a pointer to an s_cb_data structure (this
 * is not a pointer to the same structure that was passed to
 * vpi_register_cb()). The time and value information shall be set as directed
 * by the time type and value format fields in the call to vpi_register_cb().
 * The user_data field shall be equivalent to the user_data field passed to
 * vpi_register_cb()." p. 456: "For a cbValueChange callback, if the obj has
 * the vpiArray property set to TRUE, the value in the s_cb_data structure
 * shall be the value of the array member that changed value. The index field
 * shall contain the index of the rightmost range of the array declaration."
 *
 * §27.33.1.1, p. 456: "When cbStmt is used in the reason field of the
 * s_cb_data structure ... cb_data_p->obj A handle to the statement on which to
 * place the callback (the allowable objects are listed in Table 27-6)".
 * §27.33.1.2, p. 457: "Every possible object within the stmt class qualifies
 * for having a cbStmt callback placed on it." Table 27-6: "vpiBegin ... One
 * callback will occur prior to any of the statements within the block
 * executing." §27.33.1.3, p. 458: "vpi_register_cb() allows a handle
 * to a module instance in the obj field of the s_cb_data structure. When this
 * is done, the effect will be to place a callback on every statement that can
 * have a callback placed on it."
 *
 * §27.33.2, p. 458-459: "cbAtStartOfSimTime Callback shall occur before
 * execution of events in a specified time queue. A callback can be set for any
 * time, even if no event is present." "cbReadWriteSynch Callback shall occur
 * after execution of events for a specified time." "cbNextSimTime Callback
 * shall occur before execution of events in the next event queue."
 * "cbAfterDelay Callback shall occur after a specified amount of time, before
 * execution of events in a specified time queue." "For reason cbNextSimTime,
 * the time field in the time structure is ignored." "vpiSuppressTime (or NULL
 * for the cb_data_p->time field) will result in an error." "The following
 * situations will generate an error, and no callback will be created: —
 * Attempting to place a cbAtStartOfSimTime callback with a delay of zero when
 * simulation has progressed into a time slice and the application is not
 * currently within a cbAtStartOfSimTime callback. — Attempting to place a
 * cbReadWriteSynch callback with a delay of zero at read-only synch time.
 * Placing a callback for cbAtStartOfSimTime and a delay of zero during a
 * callback for reason cbAtStartOfSimTime will result in another
 * cbAtStartOfSimTime callback occurring during the same time slice." "The
 * time structure shall contain the current simulation time."
 *
 * §27.33.3, p. 460: "Actions are differentiated from features in that actions
 * shall occur in all VPI-compliant products". "The following action-related
 * callbacks shall be defined: cbEndOfCompile ... cbStartOfSimulation ...
 * cbEndOfSimulation ... cbError Simulation run-time error occurred cbPLIError
 * Simulation run-time error occurred in a PLI function call". "The only fields
 * in the s_cb_data structure that shall need to be set up for simulation
 * action or feature callbacks are the reason, cb_rtn, and user_data (if
 * desired) fields."
 *
 * §27.35, p. 465: "The routine shall return a 1 (true) if successful and a 0
 * (false) on a failure. After vpi_remove_cb() is called with a handle to the
 * callback, the handle is no longer valid."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * STARTUP: cbEndOfCompile, cbStartOfSimulation, cbEndOfSimulation register
 * with only reason and cb_rtn set, and fire once each in that order. cbError
 * (Annex G 13) and cbPLIError (28) are actions every product shall define, so
 * they register. Only vpi_register_cb() is called there (§26.2.4); the
 * handles are checked at cbStartOfSimulation, where these are REFUSED too: a
 * NULL cb_data_p, reason 9999, and a NULL cb_rtn. The refused
 * vpi_remove_cb(module) there is "a PLI function call" with a "run-time
 * error": cbPLIError runs once for it, reads the error inside, and the
 * caller still reads it afterwards (§27.33.3 names no other effect).
 *
 * AT cbStartOfSimulation (t=0, before its events), each time vpiSimTime:
 *   cbAfterDelay 7        fires at 7 before the t=7 queue: s still 8'h01,
 *                         its time structure reads low 7.
 *   cbReadWriteSynch 7    fires at 7 after the queue: s = 8'h42.
 *   cbReadOnlySynch 7     fires at 7 after that.
 *   cbNextSimTime (999)   the 999 is ignored: fires at t=1.
 *   cbAtStartOfSimTime 11 an absolute time with no design event at all
 *                         (p02_design's are 0-7, 10, 20, 40): fires at 11.
 *   cbAfterDelay 12       removed at once: vpi_remove_cb 1, never fires.
 *                         vpi_remove_cb(module): no callback object, 0 and
 *                         an error.
 *   cbReadWriteSynch 0    the t=0 registrations below.
 * REFUSED: cbAfterDelay with a NULL time and with vpiSuppressTime.
 *
 * AT cbReadWriteSynch 0 (after t=0's events, so n = 0 and mem[2] = 0):
 *   cbValueChange on n, vpiIntVal, vpiSimTime, user_data "n": n goes 5 at
 *   t=1, 9 at t=2, is rewritten 9 at t=3 (no change), 2 at t=4 -> three
 *   callbacks (1,5) (2,9) (4,2), each handed a structure that is not the
 *   registered one and user_data "n". vpi_get_cb_info reads the reason,
 *   cb_rtn, obj and user_data back; for a module it is an error.
 *   cbValueChange on the array mem: mem[2] 0 -> 8'h7E at t=1, the only array
 *   change -> one callback, value 0x7E, index 2.
 *   cbStmt (Annex G 2) on the statement of the process whose statement is a
 *   begin block (Table 27-6's vpiBegin): that block ran at t=0 and runs no
 *   more, and the callback is removed at once (§27.35: 1).
 *   cbStmt on the assignment `s = 8'h42` (vpiAssignment: "The callback will
 *   occur before the statement executes"): once, at t=7, obj that
 *   assignment, s still 8'h01, value NULL and index 0 (§27.33.1.1).
 *   cbStmt on the module (§27.33.1.3, "a callback on every statement that
 *   can have a callback placed on it"), counted from here to the end. After
 *   t=0 these statements run, a delay control counting when it is reached
 *   (Table 27-6) and its statement when the delay ends:
 *     t=1  n = 5; mem[2] = 8'h7E; #1        3
 *     t=2  n = 9; #1                        2
 *     t=3  n = 9; #1                        2
 *     t=4  n = 2                            1
 *     t=5  g = 2; #5                        2
 *     t=6  a = 20                           1
 *     t=7  s = 8'h42                        1
 *     t=10 g = 3; #10                       2
 *     t=20 g = 4; $display                  2
 *     t=40 $finish(0)                       1
 *   17 callbacks, each with a statement in obj. The continuous assignment
 *   is no statement.
 * REFUSED: cbValueChange with a NULL obj; cbStmt on the reg s, which is no
 * statement.
 *
 * AT t=7: from cbReadWriteSynch, cbAtStartOfSimTime at time 7 (delay zero,
 * not inside a cbAtStartOfSimTime) is an error; from cbReadOnlySynch, a
 * cbReadWriteSynch of delay zero is an error. AT t=11: inside the
 * cbAtStartOfSimTime, another cbAtStartOfSimTime at time 11 (delay zero)
 * fires in the same slice: two callbacks at t=11.
 *
 * TIME FIELDS: §27.33.2 says only that they "shall contain the requested time
 * of the callback or the delay before the callback". This file reads
 * cbAtStartOfSimTime's as a time (it names "a specified time queue") and
 * cbAfterDelay's, cbReadWriteSynch's and cbReadOnlySynch's as a delay from
 * now; every registration at t=0 means the same under either reading, the
 * ones at t=7 and t=11 do not.
 */

//! lrm 12.31.1
//! lrm 12.31.1:5
//! lrm 12.31.2:1002
//! inherited IEEE 1364-2005 26.2.1
//! inherited IEEE 1364-2005 27.7
//! inherited-reject IEEE 1364-2005 27.7
//! inherited IEEE 1364-2005 27.33
//! inherited-reject IEEE 1364-2005 27.33
//! inherited IEEE 1364-2005 27.33.1
//! inherited-reject IEEE 1364-2005 27.33.1
//! inherited IEEE 1364-2005 27.33.1.1
//! inherited-reject IEEE 1364-2005 27.33.1.1
//! inherited IEEE 1364-2005 27.33.1.2
//! inherited IEEE 1364-2005 27.33.1.3
//! inherited IEEE 1364-2005 27.33.2
//! inherited-reject IEEE 1364-2005 27.33.2
//! inherited IEEE 1364-2005 27.33.3
//! inherited-reject IEEE 1364-2005 27.33.3
//! inherited IEEE 1364-2005 27.35
//! inherited-reject IEEE 1364-2005 27.35
//! design ../../verilog-ams/digital/design.v
//! stdout p02: b_27_33_callbacks checks=82
//! stdout p02_design: t=20 reached

#include "b_check.h"


static char ud_n[] = "n", ud_mem[] = "mem";
static vpiHandle s, n, mem, top;
static s_cb_data reg_n, reg_mem;
static int order = 0, at_eoc, at_sos;
static int n_pli = 0, pli_level = 0, n_s42 = 0, n_stmt = 0;
static vpiHandle s42;
static int n_after = 0, n_rw7 = 0, n_ro7 = 0, n_next = 0, n_ten = 0, n_change = 0, n_mem = 0;
static PLI_UINT32 change_t[3];
static PLI_INT32 change_v[3];

static PLI_INT32 int_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  return v.value.integer;
}

static PLI_UINT32 now(void)
{
  s_vpi_time t;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  return t.low;
}

static vpiHandle reg(PLI_INT32 reason, PLI_INT32 (*fn)(p_cb_data), PLI_UINT32 low, vpiHandle obj)
{
  static s_vpi_time times[16];
  static s_cb_data cbs[16];
  static int used = 0;
  int i = used++;
  times[i].type = vpiSimTime;
  times[i].low = low;
  cbs[i].reason = reason;
  cbs[i].cb_rtn = fn;
  cbs[i].obj = obj;
  cbs[i].time = &times[i];
  return vpi_register_cb(&cbs[i]);
}

static vpiHandle err_h[2];

static PLI_INT32 never(p_cb_data d) { (void)d; CHECK(0, "a refused or removed callback ran at %u", (unsigned)now()); return 0; }
static PLI_INT32 stray(p_cb_data d) { (void)d; return 0; }
static PLI_INT32 on_pli(p_cb_data d) { (void)d; n_pli++; pli_level = vpi_chk_error(NULL); return 0; }

static PLI_INT32 on_s42(p_cb_data d)
{
  n_s42++;
  CHECK(d->reason == cbStmt && vpi_compare_objects(d->obj, s42), "27.33.1.1: obj is the statement");
  CHECK(now() == 7 && int_of(s) == 0x01, "27.33.1.1: at 7, before s = 8'h42 runs");
  CHECK(d->value == NULL && d->index == 0 && d->time != NULL && d->time->type == vpiSimTime,
        "27.33.1.1: no value, index 0, the time as registered");
  return 0;
}

static PLI_INT32 on_any(p_cb_data d)
{
  PLI_INT32 t = vpi_get(vpiType, d->obj);
  n_stmt++;
  if (d->reason != cbStmt || t == vpiModule || t == vpiContAssign || t == vpiNullStmt || t == vpiUndefined) {
    CHECK(0, "27.33.1.3: callback %d holds no statement (type %d)", n_stmt, (int)t);
  }
  return 0;
}

/* The assignment `#7 s = 8'h42` delays: the statement of a delay control in
 * a begin block, whose left-hand side is s. */
static vpiHandle assignment_to_s(void)
{
  vpiHandle procs = vpi_iterate(vpiProcess, top), p, found = NULL;
  while ((p = vpi_scan(procs)) != NULL) {
    vpiHandle blk = vpi_handle(vpiStmt, p), stmts, st;
    if (vpi_get(vpiType, blk) != vpiBegin) continue;
    stmts = vpi_iterate(vpiStmt, blk);
    while (stmts != NULL && (st = vpi_scan(stmts)) != NULL) {
      vpiHandle inner;
      if (vpi_get(vpiType, st) != vpiDelayControl) continue;
      inner = vpi_handle(vpiStmt, st);
      if (found == NULL && vpi_compare_objects(vpi_handle(vpiLhs, inner), s)) found = inner;
    }
  }
  return found;
}

static PLI_INT32 on_change(p_cb_data d)
{
  CHECK(d != &reg_n, "27.33.1: not the registered structure");
  CHECK(d->reason == cbValueChange && d->user_data == ud_n, "27.33.1: reason and user_data");
  CHECK(d->time != NULL && d->time->type == vpiSimTime, "27.33.1: time as registered");
  CHECK(d->value != NULL && d->value->format == vpiIntVal, "27.33.1: value as registered");
  CHECK(n_change < 3, "27.33.1: a fourth change at t=%u", (unsigned)d->time->low);
  change_t[n_change] = d->time->low;
  change_v[n_change] = d->value->value.integer;
  n_change++;
  return 0;
}

static PLI_INT32 on_mem(p_cb_data d)
{
  n_mem++;
  CHECK(d->user_data == ud_mem, "27.33.1: user_data");
  XFAIL(d->index == 2 && d->value != NULL && d->value->value.integer == 0x7E, "27.33.1",
        "an array's value change does not report the member's value and index");
  return 0;
}

static PLI_INT32 on_after(p_cb_data d)
{
  n_after++;
  CHECK(d->reason == cbAfterDelay && d->time->low == 7, "27.33.2: at 7, and the time says so");
  CHECK(int_of(s) == 0x01, "27.33.2: before the t=7 events");
  return 0;
}

static PLI_INT32 on_ro7(p_cb_data d)
{
  vpiHandle h;
  (void)d;
  n_ro7++;
  h = reg(cbReadWriteSynch, stray, 0, NULL);
  CHECK(h == NULL && vpi_chk_error(NULL) != 0, "27.33.2: cbReadWriteSynch of delay zero at read-only synch is an error");
  if (h) vpi_remove_cb(h);
  fflush(stdout);
  return 0;
}

static PLI_INT32 on_rw7(p_cb_data d)
{
  vpiHandle h;
  (void)d;
  n_rw7++;
  CHECK(now() == 7 && int_of(s) == 0x42, "27.33.2: after the t=7 events");
  h = reg(cbAtStartOfSimTime, stray, 7, NULL);
  CHECK(h == NULL && vpi_chk_error(NULL) != 0, "27.33.2: cbAtStartOfSimTime of delay zero from a later region is an error");
  if (h) vpi_remove_cb(h);
  fflush(stdout);
  return 0;
}

static PLI_INT32 on_next(p_cb_data d) { (void)d; n_next++; CHECK(now() == 1, "27.33.2: the next queue is t=1"); return 0; }

static PLI_INT32 on_ten(p_cb_data d)
{
  (void)d;
  n_ten++;
  CHECK(now() == 11, "27.33.2: at 11, with no event there");
  if (n_ten == 1)
    CHECK(reg(cbAtStartOfSimTime, on_ten, 11, NULL) != NULL, "27.33.2: delay zero inside cbAtStartOfSimTime");
  return 0;
}

static PLI_INT32 rw0(p_cb_data d)
{
  s_cb_data info;
  vpiHandle h, itr, stmt;
  static s_vpi_time tt;
  static s_vpi_value tv;
  (void)d;

  tt.type = vpiSimTime;
  tv.format = vpiIntVal;
  reg_n.reason = cbValueChange;
  reg_n.cb_rtn = on_change;
  reg_n.obj = n;
  reg_n.time = &tt;
  reg_n.value = &tv;
  reg_n.user_data = ud_n;
  h = vpi_register_cb(&reg_n);
  CHECK(h != NULL, "cbValueChange on n");
  reg_mem = reg_n;
  reg_mem.cb_rtn = on_mem;
  reg_mem.obj = mem;
  reg_mem.user_data = ud_mem;
  CHECK(vpi_register_cb(&reg_mem) != NULL, "cbValueChange on mem");

  memset(&info, 0, sizeof info);
  vpi_get_cb_info(h, &info);
  expect_no_error("vpi_get_cb_info");
  CHECK(info.reason == cbValueChange && info.cb_rtn == on_change && info.user_data == ud_n &&
        vpi_compare_objects(info.obj, n) == 1, "27.7: the callback reads back");
  vpi_get_cb_info(top, &info);
  expect_refusal("vpi_get_cb_info(module)");

  reg_mem.obj = NULL;
  reg_mem.cb_rtn = never;
  CHECK(vpi_register_cb(&reg_mem) == NULL, "27.33.1: obj shall be a handle");
  expect_refusal("cbValueChange with NULL obj");

  stmt = NULL;
  itr = vpi_iterate(vpiProcess, top);
  while ((h = vpi_scan(itr)) != NULL)
    if (stmt == NULL && vpi_get(vpiType, vpi_handle(vpiStmt, h)) == vpiBegin) stmt = vpi_handle(vpiStmt, h);
  CHECK(stmt != NULL, "a process whose statement is a begin block");
  h = reg(cbStmt, never, 0, stmt);
  CHECK(h != NULL, "27.33.1.1: cbStmt on a begin block");
  CHECK(vpi_remove_cb(h) == 1, "27.35: removed");
  s42 = assignment_to_s();
  CHECK(s42 != NULL && vpi_get(vpiType, s42) == vpiAssignment, "the assignment s = 8'h42");
  CHECK(reg(cbStmt, on_s42, 0, s42) != NULL, "27.33.1.1: cbStmt on s = 8'h42");
  CHECK(reg(cbStmt, on_any, 0, top) != NULL, "27.33.1.3: cbStmt on the module");
  CHECK(reg(cbStmt, never, 0, s) == NULL, "27.33.1.1: a reg is no statement");
  expect_refusal("cbStmt on a reg");
  return 0;
}

static PLI_INT32 sos(p_cb_data d)
{
  vpiHandle gone;
  s_cb_data bad;
  s_vpi_time t;
  (void)d;
  at_sos = ++order;
  s = p02_by_name("p02_design.s");
  n = p02_by_name("p02_design.n");
  mem = p02_by_name("p02_design.mem");
  top = p02_by_name("p02_design");

  CHECK(reg(cbAfterDelay, on_after, 7, NULL) != NULL, "cbAfterDelay 7");
  CHECK(reg(cbReadWriteSynch, on_rw7, 7, NULL) != NULL, "cbReadWriteSynch 7");
  CHECK(reg(cbReadOnlySynch, on_ro7, 7, NULL) != NULL, "cbReadOnlySynch 7");
  CHECK(reg(cbNextSimTime, on_next, 999, NULL) != NULL, "cbNextSimTime");
  CHECK(reg(cbAtStartOfSimTime, on_ten, 11, NULL) != NULL, "cbAtStartOfSimTime 11");
  CHECK(reg(cbReadWriteSynch, rw0, 0, NULL) != NULL, "cbReadWriteSynch 0");

  gone = reg(cbAfterDelay, never, 12, NULL);
  CHECK(gone != NULL, "cbAfterDelay 12");
  CHECK(vpi_remove_cb(gone) == 1, "27.35: removed");
  n_pli = 0;
  CHECK(vpi_remove_cb(top) == 0, "27.35: a module is no callback object");
  expect_refusal("vpi_remove_cb(module)");
  CHECK(n_pli == 1 && pli_level == vpiError, "27.33.3: one cbPLIError, the error readable inside, got %d", n_pli);

  /* 27.33: registrations refused. Here, not at startup, which allows only the
   * two registration routines (26.2.4). */
  CHECK(vpi_register_cb(NULL) == NULL, "27.33: cb_data_p shall point to a structure");
  expect_refusal("vpi_register_cb(NULL)");
  memset(&bad, 0, sizeof bad);
  bad.reason = 9999;
  bad.cb_rtn = never;
  CHECK(vpi_register_cb(&bad) == NULL, "27.33: 9999 is no predefined reason");
  expect_refusal("reason 9999");
  bad.reason = cbEndOfSimulation;
  bad.cb_rtn = NULL;
  CHECK(vpi_register_cb(&bad) == NULL, "27.33.3: cb_rtn is one of the fields an action needs");
  expect_refusal("cbEndOfSimulation, NULL cb_rtn");
  CHECK(err_h[0] != NULL && err_h[1] != NULL, "27.33.3: cbError and cbPLIError register");
  fflush(stdout);

  memset(&bad, 0, sizeof bad);
  bad.reason = cbAfterDelay;
  bad.cb_rtn = never;
  CHECK(vpi_register_cb(&bad) == NULL, "27.33.2: a NULL time is an error");
  expect_refusal("cbAfterDelay, NULL time");
  t.type = vpiSuppressTime;
  bad.time = &t;
  CHECK(vpi_register_cb(&bad) == NULL, "27.33.2: vpiSuppressTime is an error");
  expect_refusal("cbAfterDelay, vpiSuppressTime");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d) { (void)d; at_eoc = ++order; return 0; }

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(at_eoc == 1 && at_sos == 2 && ++order == 3, "27.33.3: compile, start, end in order");
  CHECK(n_after == 1 && n_rw7 == 1 && n_ro7 == 1 && n_next == 1, "27.33.2: each time callback once");
  CHECK(n_ten == 2, "27.33.2: two cbAtStartOfSimTime at t=11, got %d", n_ten);
  CHECK(n_change == 3, "27.33.1: three value changes, got %d", n_change);
  CHECK(change_t[0] == 1 && change_v[0] == 5 && change_t[1] == 2 && change_v[1] == 9 &&
        change_t[2] == 4 && change_v[2] == 2, "27.33.1: (1,5) (2,9) (4,2)");
  CHECK(n_mem == 1, "27.33.1: one array change, got %d", n_mem);
  CHECK(n_s42 == 1, "27.33.1.1: s = 8'h42 ran once, got %d", n_s42);
  CHECK(n_stmt == 17, "27.33.1.3: 17 statements after t=0, got %d", n_stmt);
  p02_done("b_27_33_callbacks");
  return 0;
}

static void startup(void)
{
  static s_cb_data a, b, c, e, f;
  a.reason = cbEndOfCompile;      a.cb_rtn = eoc;
  b.reason = cbStartOfSimulation; b.cb_rtn = sos;
  c.reason = cbEndOfSimulation;   c.cb_rtn = eos;
  e.reason = cbError;             e.cb_rtn = stray;
  f.reason = cbPLIError;          f.cb_rtn = on_pli;
  (void)vpi_register_cb(&a);
  (void)vpi_register_cb(&b);
  (void)vpi_register_cb(&c);
  err_h[0] = vpi_register_cb(&e);
  err_h[1] = vpi_register_cb(&f);
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
