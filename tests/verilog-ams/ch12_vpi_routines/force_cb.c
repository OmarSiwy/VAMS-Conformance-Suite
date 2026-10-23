/* b7 cbForce on a design force statement: VAMS-2023 12.31.1, over
 * ../ch11_vpi/behaviour.v.
 *
 * 12.31.1  "cbForce/cbRelease After a force or release has occurred".
 *          "cb_data_p->obj ... For force and release callbacks, if this is
 *          set to NULL, every force and release shall generate a callback."
 *          "For cbForce, cbRelease, cbAssign, and cbDeassign callbacks, the
 *          object returned in the obj field shall be a handle to the force,
 *          release, assign or deassign statement."
 *
 * DERIVATION (behaviour.v's header): the named block `main` runs
 * statement 10, `force w = 4'd0;`, once, at t=3, and nothing else forces
 * anything. A cbForce registered with obj NULL therefore fires exactly once,
 * and its obj is that force statement: vpi_compare_objects() with the
 * vpiForce statement of `main` is 1.
 */

//! lrm 12.31.1:10
//! design ../ch11_vpi/behaviour.v
//! stdout p02: b7_force_cb checks=10
//! stdout p04_behaviour: d=12

#include "../ch11_vpi/p02_check.h"

static vpiHandle force_stmt;
static int hits;

static PLI_INT32 on_force(p_cb_data d)
{
  hits++;
  CHECK(d->reason == cbForce, "the reason field is cbForce");
  CHECK(vpi_compare_objects(d->obj, force_stmt), "12.31.1: cbForce's obj is the force statement");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_cb_data cb;
  vpiHandle itr, s;
  (void)d;
  itr = vpi_iterate(vpiStmt, p02_by_name("p04_behaviour.main"));
  while (itr != NULL && (s = vpi_scan(itr)) != NULL)
    if (force_stmt == NULL && vpi_get(vpiType, s) == vpiForce) force_stmt = s;
  CHECK(force_stmt != NULL, "main holds a force statement");
  cb.reason = cbForce;
  cb.cb_rtn = on_force;
  cb.obj = NULL;
  CHECK(vpi_register_cb(&cb) != NULL, "cbForce with obj NULL registration failed");
  expect_no_error("vpi_register_cb(cbForce, NULL)");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(hits == 1, "12.31.1: the design statement `force w = 4'd0` delivered %d cbForce callbacks, want 1", hits);
  p02_done("b7_force_cb");
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
