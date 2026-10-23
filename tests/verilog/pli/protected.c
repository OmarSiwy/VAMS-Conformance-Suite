/* b 26.3.5 — vpiIsProtected on every kind of object, over
 * ch11_vpi/objects.v.
 *
 * IEEE 1364-2005 §26.3.5, p. 381: "All objects have a vpiIsProtected
 * property" ... "The vpiIsProtected property shall be TRUE if the
 * object_handle represents code that is protected; otherwise, it shall be
 * FALSE." Annex G's vpi_user.h numbers no vpiIsProtected; its vpiProtected
 * (10) is §26.6.1's "source protected module". VerA's vpi_user.h defines
 * vpiIsProtected as vpiProtected (specification/Vague_Decisions.md VD-045), so the
 * module property and the all-objects property are one question.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * "Code that is protected" is code "contained in a decryption envelope"
 * (clause 28). VerA refuses every `pragma protect (E0146), so objects.v
 * holds no protected code and every object answers FALSE, 0. Asked at
 * cbEndOfCompile, where §26.2.4 makes "all functionality" available, of one
 * object of each kind the application can hold:
 *
 *   p04_objects       a module (the top)                    -> 0
 *   p04_objects.u     a module (an instance)                -> 0
 *   p04_objects.bus   a net                                 -> 0
 *   p04_objects.r     a reg                                 -> 0
 *   p04_objects.i     an integer variable                   -> 0
 *   p04_objects.W     a parameter                           -> 0
 *   u's first port    a port (vpi_iterate(vpiPort, u))      -> 0
 *   that iterator     an iterator (§27.18 vpiIterator)      -> 0
 *   a cbEndOfSimulation registration's handle, a callback   -> 0
 *   the $b26p registration's handle, a vpiUserSystf         -> 0
 *
 * Each is asserted with no error after it, so a 0 is FALSE and not
 * vpiUndefined's failure value.
 *
 * REFUSALS. The clause's own error ("access to relationships and properties
 * of a protected object shall be an error") needs a protected object, which
 * VerA cannot hold (E0146); CLAUSES.tsv says so. What the clause does bound
 * is its domain, "All objects": a handle that is not an object has no
 * vpiIsProtected. Two, each beside its legal neighbour above:
 *
 *   vpi_get(vpiIsProtected, NULL)    NULL names no object (vpiTimeUnit's
 *                                    NULL reading is §26.6.1's alone)
 *                                    -> vpiUndefined (-1), an error
 *   vpi_get(vpiIsProtected, itr)     after vpi_free_object(itr): no longer
 *                                    a handle -> vpiUndefined, an error
 */

//! inherited IEEE 1364-2005 26.3.5
//! inherited-reject IEEE 1364-2005 26.3.5
//! design ../../verilog-ams/ch11_vpi/objects.v
//! stdout p02: b_26_3_5_protected checks=43

#include "b_check.h"

static vpiHandle eos_cb, systf_h;

static PLI_INT32 b26p_calltf(PLI_BYTE8 *ud)
{
  (void)ud;
  return 0;
}

static void is_false(vpiHandle h, const char *what)
{
  CHECK(vpi_get(vpiIsProtected, h) == 0, "26.3.5: vpiIsProtected of %s is FALSE", what);
  expect_no_error(what);
}

static PLI_INT32 eoc(p_cb_data d)
{
  vpiHandle top, itr, port;
  (void)d;
  CHECK(vpiIsProtected == vpiProtected, "VD-045: vpiIsProtected is Annex G's vpiProtected");
  top = p02_by_name("p04_objects");
  is_false(top, "the top module");
  is_false(p02_by_name("p04_objects.u"), "a module instance");
  is_false(p02_by_name("p04_objects.bus"), "a net");
  is_false(p02_by_name("p04_objects.r"), "a reg");
  is_false(p02_by_name("p04_objects.i"), "an integer variable");
  is_false(p02_by_name("p04_objects.W"), "a parameter");
  itr = vpi_iterate(vpiPort, p02_by_name("p04_objects.u"));
  CHECK(itr != NULL, "u has two ports");
  is_false(itr, "an iterator");
  port = vpi_scan(itr);
  CHECK(port != NULL, "u's first port");
  is_false(port, "a port");
  is_false(eos_cb, "a callback");
  is_false(systf_h, "a vpiUserSystf");

  CHECK(vpi_get(vpiIsProtected, NULL) == vpiUndefined, "26.3.5: NULL is not an object");
  expect_refusal("vpi_get(vpiIsProtected, NULL)");
  CHECK(vpi_free_object(itr) == 1, "the iterator is freed");
  CHECK(vpi_get(vpiIsProtected, itr) == vpiUndefined, "26.3.5: a freed iterator is not an object");
  expect_refusal("vpi_get(vpiIsProtected, freed iterator)");
  p02_done("b_26_3_5_protected");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  return 0;
}

static void startup(void)
{
  static s_cb_data c, e;
  static s_vpi_systf_data t;
  t.type = vpiSysTask;
  t.tfname = "$b26p";
  t.calltf = b26p_calltf;
  systf_h = vpi_register_systf(&t);
  c.reason = cbEndOfCompile;
  c.cb_rtn = eoc;
  e.reason = cbEndOfSimulation;
  e.cb_rtn = eos;
  eos_cb = vpi_register_cb(&e);
  CHECK(systf_h != NULL && eos_cb != NULL && vpi_register_cb(&c) != NULL, "startup registers");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
