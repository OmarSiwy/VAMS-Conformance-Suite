/* IEEE 1364-2005 §26.6.13 (primitive, prim term), §26.6.14 (UDP) and
 * §26.6.22-§26.6.23 (net and reg drivers and loads), walked over
 * ch11_vpi/prims.v at t=5.
 *
 * §26.6.13, p. 399 Details: "a) vpiSize shall return the number of inputs.
 *   b) For primitives, vpi_put_value() shall only be used with sequential UDP
 *   primitives. c) vpiTermIndex can be used to determine the terminal order.
 *   The first terminal has a term index of zero. d) If a primitive is an
 *   element within a primitive array, the vpiIndex transition is used to
 *   access the index within the array. If a primitive is not part of a
 *   primitive array, this transition shall return NULL." The diagram gives
 *   prim term "-> value vpi_get_value()".
 * §26.6.14, p. 400: a circle ->> udp defn (so vpi_iterate(vpiUdpDefn,
 *   NULL)); udp defn -> definition name str: vpiDefName, number of
 *   inputs int: vpiSize, type int: vpiPrimType; udp defn ->> io decl, ->>
 *   table entry ("-> number of symbol entries int: vpiSize"), -> initial.
 *   Details: "a) Only string (decompilation) and vector (ASCII values) shall
 *   be obtained for table entry objects using vpi_get_value(). ... b)
 *   vpiPrimType returns vpiSeqPrim for sequential UDPs and vpiCombPrim for
 *   combinatorial UDPs."
 * §26.6.22, p. 405: nets ->> vpiDriver net drivers (ports, force, delay term,
 *   cont assign, cont assign bit, prim term); nets ->> vpiLoad net loads
 *   (delay term, assign stmt, force, cont assign, cont assign bit, prim term,
 *   ports).
 * §26.6.23, p. 406: regs ->> vpiDriver reg drivers (force, assign stmt);
 *   regs ->> vpiLoad reg loads (prim term, assign stmt, force, cont assign,
 *   cont assign bit).
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * prims.v: `and #(2,3) (y, a, b); not (ny, y); p04_latch lat (q, d,
 * en);` and a = b = d = en = 1 at t=0. So by t=5 (past the and's rise delay
 * of 2) y = 1, ny = 0, q = 1.
 *
 *   §26.6.13 module ->> primitive: and, not, lat (filed by type, not by
 *            iteration order). and is a vpiGate of
 *            vpiPrimType vpiAndPrim, vpiDefName "and", two inputs (vpiSize 2,
 *            Details a); its terminals are y, a, b with vpiTermIndex 0, 1, 2
 *            (Details c; filed by that index), y an output and a, b inputs, each term -> expr the
 *            net or reg it connects; terminal 0 reads y = 1. No gate is in an
 *            array: vpiIndex is NULL (Details d) and vpiArray FALSE. lat is a
 *            vpiUdp named "lat", vpiPrimType vpiSeqPrim, two inputs.
 *   §26.6.14 vpi_iterate(vpiUdpDefn, NULL) yields p04_latch: vpiDefName
 *            "p04_latch", vpiSize 2, vpiPrimType vpiSeqPrim (Details b: the
 *            table has a current-state column), io decls q, d, en, three
 *            table entries of 4 symbols (two inputs, state, output); one of
 *            them is the row `1 1 : ? : 1`, and its vpiStringVal
 *            decompilation, white space ignored, reads 11:?:1 (the form of
 *            §27.14's second sample output, p. 435, "10:?:1" for
 *            `1 0 :?:1;` - an example, not a normative string format, so
 *            neither spacing nor row order is asserted), and `initial q = 0`
 *            is its initial.
 *   §26.6.22 y is driven by the and's output terminal and loaded by the
 *            not's input terminal.
 *   §26.6.23 the reg a is loaded by the and's input terminal a.
 *
 * REFUSALS (NULL / vpiUndefined with vpi_chk_error() nonzero):
 *   §26.6.13 vpi_put_value(and gate): Details b, a gate is no sequential UDP.
 *   §26.6.14 vpi_get_value(table entry, vpiIntVal): Details a, only string
 *            and vector.
 *   §26.6.22 vpi_iterate(vpiDriver, module): drivers are a net's.
 *   §26.6.23 vpi_iterate(vpiLoad, udp defn): loads are a reg's or a net's.
 */

//! inherited IEEE 1364-2005 26.6.13
//! inherited-reject IEEE 1364-2005 26.6.13
//! inherited IEEE 1364-2005 26.6.14
//! inherited-reject IEEE 1364-2005 26.6.14
//! inherited IEEE 1364-2005 26.6.22
//! inherited-reject IEEE 1364-2005 26.6.22
//! inherited IEEE 1364-2005 26.6.23
//! inherited-reject IEEE 1364-2005 26.6.23
//! design ../../verilog-ams/ch11_vpi/prims.v
//! stdout p02: b_26_6_primitives checks=65

#include "b_check.h"

/* Does `s`, white space removed, spell `want`? §27.14 shows the layout of a
 * decompiled entry only in an example, so spacing is not asserted. */
static int squeezed_is(const char *s, const char *want)
{
  for (; *s != '\0'; s++) {
    if (*s == ' ' || *s == '\t') continue;
    if (*s != *want) return 0;
    want++;
  }
  return *want == '\0';
}

/* Does vpi_iterate(type, ref) yield a vpiPrimTerm of `prim`'s type with
 * vpiTermIndex `index`? */
static int yields_term(PLI_INT32 type, vpiHandle ref, PLI_INT32 prim_type, int index)
{
  vpiHandle itr = vpi_iterate(type, ref), h;
  int found = 0;
  if (itr == NULL) return 0;
  while ((h = vpi_scan(itr)) != NULL)
    if (vpi_get(vpiType, h) == vpiPrimTerm && vpi_get(vpiTermIndex, h) == index &&
        vpi_get(vpiPrimType, vpi_handle(vpiPrimitive, h)) == prim_type)
      found = 1;
  return found;
}

static PLI_INT32 walk(p_cb_data cb_data)
{
  vpiHandle top = p02_by_name("p04_prims");
  vpiHandle y = p02_by_name("p04_prims.y");
  vpiHandle a = p02_by_name("p04_prims.a");
  vpiHandle prim[3], term[3], rows[3], defn, row, itr, h;
  const char *expr_names[3] = { "p04_prims.y", "p04_prims.a", "p04_prims.b" };
  s_vpi_value v;
  int n = 0, k;

  (void)cb_data;

  /* §26.6.13 */
  prim[0] = prim[1] = prim[2] = NULL;
  itr = vpi_iterate(vpiPrimitive, top);
  CHECK(itr != NULL, "26.6.13: module ->> primitive");
  while ((h = vpi_scan(itr)) != NULL) {
    /* no clause fixes the order: each is filed by what it is */
    k = vpi_get(vpiType, h) == vpiUdp ? 2 : vpi_get(vpiPrimType, h) == vpiAndPrim ? 0 : 1;
    CHECK(prim[k] == NULL, "26.6.13: one and, one not, one UDP");
    prim[k] = h;
    n++;
  }
  CHECK(n == 3, "26.6.13: three primitives, got %d", n);
  CHECK(vpi_get(vpiType, prim[0]) == vpiGate && vpi_get(vpiPrimType, prim[0]) == vpiAndPrim, "26.6.13: and");
  CHECK_STR(vpi_get_str(vpiDefName, prim[0]), "and", "26.6.13 definition name");
  CHECK(vpi_get(vpiSize, prim[0]) == 2, "26.6.13 a: and has two inputs");
  CHECK(vpi_get(vpiPrimType, prim[1]) == vpiNotPrim && vpi_get(vpiSize, prim[1]) == 1, "26.6.13 a: not has one");
  CHECK(vpi_get(vpiType, prim[2]) == vpiUdp && vpi_get(vpiPrimType, prim[2]) == vpiSeqPrim &&
        vpi_get(vpiSize, prim[2]) == 2, "26.6.13: lat, a sequential UDP of two inputs");
  CHECK_STR(vpi_get_str(vpiFullName, prim[2]), "p04_prims.lat", "26.6.13 full name");
  n = 0;
  term[0] = term[1] = term[2] = NULL;
  itr = vpi_iterate(vpiPrimTerm, prim[0]);
  while ((h = vpi_scan(itr)) != NULL) {
    k = vpi_get(vpiTermIndex, h);
    CHECK(k >= 0 && k < 3 && term[k] == NULL, "26.6.13 c: term index %d", k);
    term[k] = h;
    n++;
  }
  CHECK(n == 3, "26.6.13: and has three terminals, got %d", n);
  for (k = 0; k < 3; k++) {
    CHECK(vpi_get(vpiDirection, term[k]) == (k == 0 ? vpiOutput : vpiInput), "26.6.13: terminal %d direction", k);
    CHECK_STR(vpi_get_str(vpiFullName, vpi_handle(vpiExpr, term[k])), expr_names[k], "26.6.13: prim term -> expr");
    CHECK(vpi_compare_objects(vpi_handle(vpiPrimitive, term[k]), prim[0]), "26.6.13: prim term -> primitive");
  }
  CHECK(vpi_handle(vpiIndex, prim[0]) == NULL, "26.6.13 d: not in an array, so NULL");
  v.format = vpiScalarVal;
  vpi_get_value(y, &v);
  CHECK(v.value.scalar == vpi1, "26.6.13: y = a & b = 1");
  expect_no_error("the primitive walk");
  vpi_get_value(term[0], &v);
  CHECK(vpi_chk_error(NULL) == 0 && v.value.scalar == vpi1, "26.6.13: prim term -> value, y = 1");
  CHECK(vpi_get(vpiArray, prim[0]) == 0, "26.6.13: a gate outside an array is no array member");
  v.format = vpiScalarVal;
  v.value.scalar = vpi0;
  vpi_put_value(prim[0], &v, NULL, vpiNoDelay);
  expect_refusal("26.6.13 b: vpi_put_value(gate)");

  /* §26.6.14 */
  itr = vpi_iterate(vpiUdpDefn, NULL);
  CHECK(itr != NULL, "26.6.14: the UDP definitions");
  defn = vpi_scan(itr);
  CHECK(defn != NULL && vpi_scan(itr) == NULL, "26.6.14: exactly one");
  CHECK_STR(vpi_get_str(vpiDefName, defn), "p04_latch", "26.6.14 definition name");
  CHECK(vpi_get(vpiSize, defn) == 2, "26.6.14: two inputs");
  CHECK(vpi_get(vpiPrimType, defn) == vpiSeqPrim, "26.6.14 b: sequential");
  n = 0;
  itr = vpi_iterate(vpiIODecl, defn);
  while ((h = vpi_scan(itr)) != NULL) n++;
  CHECK(n == 3, "26.6.14: io decls q, d, en");
  n = 0;
  itr = vpi_iterate(vpiTableEntry, defn);
  row = vpi_scan(itr);
  for (h = row; h != NULL; h = vpi_scan(itr)) {
    CHECK(vpi_get(vpiSize, h) == 4, "26.6.14: four symbols per entry");
    rows[n < 3 ? n : 2] = h;
    n++;
  }
  CHECK(n == 3, "26.6.14: three table entries");
  expect_no_error("the UDP walk");
  {
    int decompiled = 0;
    for (k = 0; k < 3; k++) {
      v.format = vpiStringVal;
      vpi_get_value(rows[k], &v);
      if (vpi_chk_error(NULL) == 0 && v.value.str != NULL && squeezed_is(v.value.str, "11:?:1")) decompiled = 1;
    }
    CHECK(decompiled, "26.6.14 a: a table entry decompiles (vpiStringVal) as 1 1 : ? : 1");
  }
  CHECK(vpi_handle(vpiInitial, defn) != NULL, "26.6.14: udp defn -> initial");
  v.format = vpiIntVal;
  vpi_get_value(row, &v);
  expect_refusal("26.6.14 a: vpi_get_value(table entry, vpiIntVal)");

  /* §26.6.22 / §26.6.23 */
  CHECK(yields_term(vpiDriver, y, vpiAndPrim, 0), "26.6.22: y is driven by the and's output");
  CHECK(yields_term(vpiLoad, y, vpiNotPrim, 1), "26.6.22: y is loaded by the not's input");
  CHECK(vpi_iterate(vpiDriver, top) == NULL, "26.6.22: a module has no drivers");
  expect_refusal("vpi_iterate(vpiDriver, module)");
  CHECK(yields_term(vpiLoad, a, vpiAndPrim, 1), "26.6.23: reg a is loaded by the and's input");
  CHECK(vpi_iterate(vpiLoad, defn) == NULL, "26.6.23: a UDP definition has no loads");
  expect_refusal("vpi_iterate(vpiLoad, udp defn)");

  p02_done("b_26_6_primitives");
  return 0;
}

static PLI_INT32 start(p_cb_data cb_data)
{
  static s_vpi_time t = { vpiSimTime, 0, 5, 0.0 };
  static s_cb_data cb;
  (void)cb_data;
  cb.reason = cbAfterDelay;
  cb.cb_rtn = walk;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbAfterDelay(5) registration failed");
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
