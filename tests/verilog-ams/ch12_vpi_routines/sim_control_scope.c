/* b7 vpiSetInteractiveScope: VAMS-2023 12.36, over digital.v.
 *
 * 12.36  "vpiSetInteractiveScope — cause interactive scope to be immediately
 *        changed to new scope. This operation shall be passed one argument
 *        that is a vpiHandle object with type vpiScope." Returns "1 (true)
 *        if successful; 0 (false) on a failure".
 * vpiSetInteractiveScope is IEEE 1364-2005 Annex G's 69; src/vpi/vpi_user.h
 * does not define it, so this file does.
 *
 * DERIVATION. At t=1, from a cbAfterDelay routine, the named block `seq` is
 * a scope (11.6.3's scope class, which IEEE 1364-2005 §26.6.3 draws as
 * module, task, function, named begin and named fork).
 * vpi_sim_control(vpiSetInteractiveScope, seq) is a listed operation with
 * its one argument, so it succeeds: 1, and no error.
 */

//! lrm 12.36:6
//! lrm 12.36:7
//! design digital.v
//! stdout p02: b7_sim_control_scope checks=8

#include "../ch11_vpi/p02_check.h"

#ifndef vpiSetInteractiveScope
#define vpiSetInteractiveScope 69
#endif

static int calls;

static PLI_INT32 at1(p_cb_data d)
{
  vpiHandle seq;
  (void)d;
  calls++;
  seq = p02_by_name("b7_digital.seq");
  CHECK(vpi_sim_control(vpiSetInteractiveScope, seq) == 1, "12.36: vpi_sim_control(vpiSetInteractiveScope, seq) failed");
  expect_no_error("vpi_sim_control(vpiSetInteractiveScope, seq)");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  (void)d;
  t.type = vpiSimTime;
  t.low = 1;
  cb.reason = cbAfterDelay;
  cb.cb_rtn = at1;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbAfterDelay(1) registration failed");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(calls == 1, "the operation was requested once, got %d", calls);
  p02_done("b7_sim_control_scope");
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
