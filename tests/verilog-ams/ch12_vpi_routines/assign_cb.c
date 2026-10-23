/* b7 cbAssign, cbDeassign, cbDisable: the three simulation-event reasons of
 * VAMS-2023 12.31.1 no running fixture delivers, over
 * ../ch11_vpi/behaviour.v.
 *
 * 12.31.1  "When the cb_data_p->reason field is set to one of the following,
 *          the callback shall occur as described below: ... cbAssign/
 *          cbDeassign After a procedural assign or deassign statement has
 *          been executed cbDisable After a named block or task containing a
 *          system task or function has been disabled". "cb_data_p->obj This
 *          field shall be assigned a handle to an expression, terminal, or
 *          statement for which the callback shall occur." "For cbForce,
 *          cbRelease, cbAssign, and cbDeassign callbacks, the object returned
 *          in the obj field shall be a handle to the ... assign or deassign
 *          statement."
 * cbAssign, cbDeassign and cbDisable are IEEE 1364-2005 Annex G's 25, 26 and
 * 27; src/vpi/vpi_user.h does not define them, so this file does.
 *
 * DERIVATION (behaviour.v's header): `main` runs, once each and in this
 * order at t=3, statement 12 `assign e = 4'd5;`, statement 13 `deassign e;`
 * and statement 18 `disable main;`, and `main` contains the system task
 * $display (statement 17). So, registered on the reg e (assign, deassign)
 * and on the named block main (disable): one cbAssign with obj the assign
 * statement, one cbDeassign with obj the deassign statement, one cbDisable.
 */

//! lrm 12.31.1:1
//! design ../ch11_vpi/behaviour.v
//! stdout p02: b7_assign_cb checks=19
//! stdout p04_behaviour: d=12

#include "../ch11_vpi/p02_check.h"

#ifndef cbAssign
#define cbAssign 25
#endif
#ifndef cbDeassign
#define cbDeassign 26
#endif
#ifndef cbDisable
#define cbDisable 27
#endif

static vpiHandle assign_stmt, deassign_stmt;
static int n_assign, n_deassign, n_disable;

static PLI_INT32 on_assign(p_cb_data d)
{
  n_assign++;
  CHECK(d->reason == cbAssign && vpi_compare_objects(d->obj, assign_stmt), "12.31.1: cbAssign's obj is the assign statement");
  return 0;
}

static PLI_INT32 on_deassign(p_cb_data d)
{
  n_deassign++;
  CHECK(d->reason == cbDeassign && vpi_compare_objects(d->obj, deassign_stmt), "12.31.1: cbDeassign's obj is the deassign statement");
  return 0;
}

static PLI_INT32 on_disable(p_cb_data d)
{
  n_disable++;
  CHECK(d->reason == cbDisable, "the reason field is cbDisable");
  return 0;
}

static void arm(s_cb_data *cb, PLI_INT32 reason, PLI_INT32 (*fn)(p_cb_data), vpiHandle obj, const char *what)
{
  cb->reason = reason;
  cb->cb_rtn = fn;
  cb->obj = obj;
  CHECK(vpi_register_cb(cb) != NULL, "12.31.1: registering %s was refused", what);
  expect_no_error(what);
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_cb_data ca, cd, cx;
  vpiHandle main_blk, itr, s;
  (void)d;
  main_blk = p02_by_name("p04_behaviour.main");
  itr = vpi_iterate(vpiStmt, main_blk);
  while (itr != NULL && (s = vpi_scan(itr)) != NULL) {
    if (assign_stmt == NULL && vpi_get(vpiType, s) == vpiAssignStmt) assign_stmt = s;
    if (deassign_stmt == NULL && vpi_get(vpiType, s) == vpiDeassign) deassign_stmt = s;
  }
  CHECK(assign_stmt != NULL && deassign_stmt != NULL, "main holds an assign and a deassign statement");
  arm(&ca, cbAssign, on_assign, p02_by_name("p04_behaviour.e"), "cbAssign on e");
  arm(&cd, cbDeassign, on_deassign, p02_by_name("p04_behaviour.e"), "cbDeassign on e");
  arm(&cx, cbDisable, on_disable, main_blk, "cbDisable on main");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(n_assign == 1 && n_deassign == 1 && n_disable == 1, "12.31.1: one each, got assign %d deassign %d disable %d",
        n_assign, n_deassign, n_disable);
  p02_done("b7_assign_cb");
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
