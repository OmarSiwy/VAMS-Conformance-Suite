/* p04 11 — each instance is its own scope, past a task and a loop generate,
 * over scopes.v.
 *
 *   11.2.2  "An instantiated design is one where each instance of an object
 *            is uniquely accessible. For instance, if a module m contains wire
 *            w and is instantiated twice as m1 and m2, then m1.w and m2.w are
 *            two distinct objects".
 *   12.21   vpi_handle_by_name "shall return a handle to an object with a
 *            specific name".
 *   12.16   vpi_get_value "shall retrieve the simulation value of VPI
 *            objects".
 *   12.3    vpi_compare_objects "shall return TRUE if the two handles refer
 *            to the same object".
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * p04_leaf_s is m, instantiated three times; each instance's `initial r = V`
 * leaves its own parameter in its own r by the end of time 0 (IEEE 1364
 * §12.2: a parameter value is per instance):
 *
 *   p04_scopes.c.r         V = 8'h11   -> 17
 *   p04_scopes.g[0].u.r    V = 0 + 1   ->  1     (IEEE 1364 §12.4.1: one
 *   p04_scopes.g[1].u.r    V = 1 + 1   ->  2      iteration is `g[i]`)
 *
 * Three distinct objects, so no two compare equal, and `p04_scopes` has three
 * child modules (a generate iteration is a component of the name, not a
 * module). The task `t` and the two iterations precede `c` in the source; a
 * model that numbered only instances would bind `c.r` to the task's scope and
 * find nothing, or another instance's reg.
 */

//! lrm 11.2.2
//! lrm 12.3
//! lrm 12.16
//! lrm 12.21
//! lrm 11.2.2:1000
//! lrm 12.21:1
//! design scopes.v
//! stdout p02: p04_11_instance_scopes checks=23

#include "p02_check.h"

static int value_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  expect_no_error("vpi_get_value");
  return v.value.integer;
}

static PLI_INT32 walk(p_cb_data cb_data)
{
  vpiHandle top = p02_by_name("p04_scopes");
  vpiHandle c  = p02_by_name("p04_scopes.c.r");
  vpiHandle g0 = p02_by_name("p04_scopes.g[0].u.r");
  vpiHandle g1 = p02_by_name("p04_scopes.g[1].u.r");
  vpiHandle itr;
  int children = 0;

  (void)cb_data;

  CHECK(value_of(c) == 17, "11.2.2: c.r holds c's V = 8'h11");
  CHECK(value_of(g0) == 1, "11.2.2: g[0].u.r holds g[0].u's V = 1");
  CHECK(value_of(g1) == 2, "11.2.2: g[1].u.r holds g[1].u's V = 2");
  CHECK(vpi_compare_objects(c, g0) == 0, "12.3: c.r and g[0].u.r are distinct objects");
  CHECK(vpi_compare_objects(g0, g1) == 0, "12.3: g[0].u.r and g[1].u.r are distinct objects");
  CHECK_STR(vpi_get_str(vpiDefName, p02_by_name("p04_scopes.g[1].u")), "p04_leaf_s", "g[1].u's definition");

  itr = vpi_iterate(vpiModule, top);
  CHECK(itr != NULL, "p04_scopes has child modules");
  while (vpi_scan(itr) != NULL) children++;
  CHECK(children == 3, "three instances under p04_scopes, got %d", children);

  p02_done("p04_11_instance_scopes");
  return 0;
}

static void setup_after_compile(void)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data cb;
  cb.reason = cbReadWriteSynch;
  cb.cb_rtn = walk;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadWriteSynch(0) registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
