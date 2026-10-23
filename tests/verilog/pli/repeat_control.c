/* IEEE 1364-2005 §26.6.31 (repeat control), over
 * repeat_control.v.
 *
 * §26.6.31, p. 411: repeat control -> expr, -> event control; §26.6.28,
 *   p. 410: assignment -> repeat control.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * The first initial's third statement `c = repeat (2) @(posedge clk) b;` is
 * an assignment whose repeat control counts the constant 2 and whose event
 * control's condition is a vpiPosedgeOp over clk.
 *
 * REFUSAL: vpi_handle(vpiStmt, repeat control) - the diagram draws only the
 * expression and the event control - NULL with vpi_chk_error() nonzero.
 *
 * checks=13: setup's and start's registrations (2), p02_by_name's lookup and
 * no-error (2), and walk's nine.
 */

//! inherited IEEE 1364-2005 26.6.31
//! inherited-reject IEEE 1364-2005 26.6.31
//! design repeat_control.v
//! stdout p02: b_26_6_31_repeat_control checks=13

#include "b_check.h"

/* Annex G numbers that src/vpi/vpi_user.h does not define. */
#ifndef vpiRepeatControl
#define vpiRepeatControl 52
#endif

static PLI_INT32 walk(p_cb_data cb_data)
{
  vpiHandle top = p02_by_name("b26_repeat_control");
  vpiHandle itr = vpi_iterate(vpiProcess, top), p, blk, it2, st = NULL, rc, ec;
  s_vpi_value v;

  (void)cb_data;
  CHECK(itr != NULL, "the processes");
  /* the process whose third statement is an assignment: no clause fixes
   * the order of module ->> process */
  while ((p = vpi_scan(itr)) != NULL) {
    vpiHandle third = NULL;
    blk = vpi_handle(vpiStmt, p);
    it2 = vpi_iterate(vpiStmt, blk);
    if (it2 != NULL && vpi_scan(it2) != NULL && vpi_scan(it2) != NULL && (third = vpi_scan(it2)) != NULL)
      vpi_free_object(it2);
    if (third != NULL && vpi_get(vpiType, third) == vpiAssignment) st = third;
  }
  CHECK(st != NULL, "26.6.31: the first initial's third statement");
  CHECK(vpi_get(vpiType, st) == vpiAssignment, "26.6.31: the third statement");
  rc = vpi_handle(vpiRepeatControl, st);
  CHECK(rc != NULL && vpi_get(vpiType, rc) == vpiRepeatControl, "26.6.31: assignment -> repeat control");
  v.format = vpiIntVal;
  vpi_get_value(vpi_handle(vpiExpr, rc), &v);
  CHECK(v.value.integer == 2, "26.6.31: repeat (2)");
  ec = vpi_handle(vpiEventControl, rc);
  CHECK(ec != NULL && vpi_get(vpiOpType, vpi_handle(vpiCondition, ec)) == vpiPosedgeOp,
        "26.6.31: @(posedge clk)");
  expect_no_error("the repeat control walk");
  CHECK(vpi_handle(vpiStmt, rc) == NULL, "26.6.31: a repeat control draws no statement");
  expect_refusal("vpi_handle(vpiStmt, repeat control)");
  p02_done("b_26_6_31_repeat_control");
  return 0;
}

static PLI_INT32 start(p_cb_data cb_data)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data cb;
  (void)cb_data;
  cb.reason = cbReadWriteSynch;
  cb.cb_rtn = walk;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadWriteSynch(0) registration failed");
  return 0;
}

/* §26.2.4: from the startup routine only the action callbacks may be
 * registered, so the time callback is registered once simulation starts. */
static void setup(void)
{
  static s_cb_data ss;
  ss.reason = cbStartOfSimulation;
  ss.cb_rtn = start;
  CHECK(vpi_register_cb(&ss) != NULL, "cbStartOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
