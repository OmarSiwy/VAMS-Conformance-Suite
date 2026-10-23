/* b7 timing-check violation: VAMS-2023 12.31.4's cbTchkViolation, an ACTION
 * callback.
 *
 * 12.31.4  "Actions are differentiated from features in that actions shall
 *          occur in all VPI-compliant products". "The following
 *          action-related callbacks shall be defined: ... cbTchkViolation
 *          Timing check error occurred". "The only fields in the s_cb_data
 *          structure which need to be setup for simulation action/feature
 *          callbacks are the reason, cb_rtn, and user_data". "For
 *          cbTchkViolation callbacks, the obj field shall be a handle to the
 *          timing check."
 * cbTchkViolation is IEEE 1364-2005 Annex G's 14, as src/vpi/vpi_user.h
 * defines it; the guard below keeps the file building against a header
 * without it.
 *
 * DERIVATION (specify.v's header): u1's $setup(d, posedge clk, 5, notif)
 * sees its data events at 0 (x -> 0) and 3 (0 -> 1) and its reference event
 * at 5 (clk 0 -> 1; clk's x -> 0 at 0 is a negedge, IEEE 1364-2005 15.4).
 * 15.2.1: a violation when "(timecheck time) - limit < (timestamp time) <
 * (timecheck time)", the timestamp the last data event before the
 * timecheck: 5 - 5 = 0 < 3 < 5 is one violation, at t=5, in u1 only (u2's
 * clk2 never rises). So exactly one cbTchkViolation, at t=5, with obj u1's
 * $setup.
 *
 * CENSUS: setup 2, eoc 6 (p02_by_name is a CHECK and an expect_no_error),
 * on_violation 3 at its one call, eos 1: checks=12.
 */

//! lrm 12.31.4
//! lrm 12.31.4:1
//! lrm 12.31.4:2
//! lrm 12.31.4:5
//! inherited IEEE 1364-2005 15.2.1
//! design specify.v
//! stdout p02: b7_tchk_violation checks=12

#include "../ch11_vpi/p02_check.h"

#ifndef cbTchkViolation
#define cbTchkViolation 14
#endif

static vpiHandle setup_u1;
static int hits;

static PLI_UINT32 now(void)
{
  s_vpi_time t;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  return t.low;
}

static PLI_INT32 on_violation(p_cb_data d)
{
  hits++;
  CHECK(d->reason == cbTchkViolation, "12.31.4: the reason field is cbTchkViolation");
  CHECK(vpi_compare_objects(d->obj, setup_u1), "12.31.4: obj is u1's $setup");
  CHECK(now() == 5, "the violation is at t=5, got %u", (unsigned)now());
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_cb_data cb;
  vpiHandle itr;
  (void)d;
  itr = vpi_iterate(vpiTchk, p02_by_name("b7_specify.u1"));
  CHECK(itr != NULL && (setup_u1 = vpi_scan(itr)) != NULL, "u1 has a timing check");
  vpi_free_object(itr);
  CHECK(vpi_get(vpiTchkType, setup_u1) == vpiSetup, "it is the $setup");
  cb.reason = cbTchkViolation;
  cb.cb_rtn = on_violation;
  CHECK(vpi_register_cb(&cb) != NULL, "12.31.4: registering the action callback cbTchkViolation was refused");
  expect_no_error("vpi_register_cb(cbTchkViolation)");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(hits == 1, "12.31.4: one $setup violation, %d cbTchkViolation callbacks", hits);
  p02_done("b7_tchk_violation");
  return 0;
}

static void setup(void)
{
  static s_cb_data c, e;
  c.reason = cbEndOfCompile;
  c.cb_rtn = eoc;
  CHECK(vpi_register_cb(&c) != NULL, "cbEndOfCompile registration failed");
  e.reason = cbEndOfSimulation;
  e.cb_rtn = eos;
  CHECK(vpi_register_cb(&e) != NULL, "cbEndOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
