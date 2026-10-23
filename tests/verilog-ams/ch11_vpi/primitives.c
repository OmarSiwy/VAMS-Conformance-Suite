/* p04 10 — 11.6.13 (primitive, prim term) and 11.6.14 (UDP), walked over
 * prims.v, with 12.11's rule for a primitive's delays.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * module ->> primitive yields the module's three primitives in source order:
 * `and #(2,3) (y, a, b)`, `not (ny, y)`, `p04_latch lat (q, d, en)`.
 *
 *   and: vpiGate, vpiPrimType vpiAndPrim, vpiDefName "and" (the gate's
 *     keyword). NOTE 1: "vpiSize shall return the number of inputs" — 2.
 *     primitive <->> prim term: y, a, b; the output first (vpiTermIndex 0,
 *     vpiDirection vpiOutput), then the inputs (1 and 2, vpiInput); each
 *     prim term -> expr is the net or reg it connects, and leads back to the
 *     gate. vpiDelay: IEEE 1364-2005 §26.3.4 "an operation if there are more
 *     than one delay specified ... the operation's vpiOpType shall be
 *     vpiListOp", so #(2,3) is a vpiListOp whose operands read 2 and 3.
 *   12.11 over it: "For primitive objects, the no_of_delays value shall be 2
 *     or 3." Two give rise 2 and fall 3; three add the turn-off, which a
 *     two-delay primitive derives as the smaller of the two (IEEE 1364
 *     §7.14): 2. One is not a legal count — refused.
 *   not: vpiNotPrim, one input (vpiSize 1), no delay written: vpiDelay NULL
 *     with no error, and vpi_get_delays refused — there are none to get.
 *   lat: vpiUdp, named "lat" (vpiFullName "p04_prims.lat"), vpiDefName
 *     "p04_latch", vpiPrimType vpiSeqPrim (its table has a current-state
 *     column), two inputs; udp -> udp defn is 11.6.14's definition.
 *
 *   11.6.14: the circled arrow vpi_iterate(vpiUdpDefn, NULL) yields the one
 *     definition: vpiDefName "p04_latch", vpiSize 2 ("number of inputs"),
 *     vpiPrimType vpiSeqPrim; udp defn ->> io decl is q (output), d, en
 *     (inputs); ->> table entry is its three rows, each of "number of symbol
 *     entries" 4 — two input fields, the current state, the output.
 *
 * VALUES at t=5 (after the rise delay of 2): a = b = 1, so y = 1 and ny = 0;
 * d = en = 1, so the latch passes d: q = 1.
 *
 * REFUSALS: 11.6.13 NOTE 2 "For primitives, vpi_put_value() shall only be
 * used with sequential UDP primitives" — a put to the and gate is refused;
 * a gate draws no udp defn arrow (only a udp does); a UDP definition has no
 * vpiDirection (its io decls do).
 */

//! lrm 11.6.13
//! lrm-reject 11.6.13
//! lrm 11.6.14
//! lrm-reject 11.6.14
//! lrm 12.11
//! lrm-reject 12.11
//! lrm-reject 12.30
//! lrm 12.11:8
//! design prims.v
//! stdout p02: p04_10_primitives checks=96

#include "p02_check.h"

static int scan_all(vpiHandle itr, vpiHandle *out, int max)
{
  int n = 0;
  vpiHandle h;
  if (itr == NULL) return 0;
  while ((h = vpi_scan(itr)) != NULL) {
    if (n < max) out[n] = h;
    n++;
  }
  return n;
}

static void term(vpiHandle t, int index, PLI_INT32 dir, const char *conn, vpiHandle prim)
{
  CHECK(vpi_get(vpiType, t) == vpiPrimTerm, "a prim term");
  CHECK(vpi_get(vpiTermIndex, t) == index, "term %d's index", index);
  CHECK(vpi_get(vpiDirection, t) == dir, "term %d's direction", index);
  CHECK(vpi_compare_objects(vpi_handle(vpiExpr, t), p02_by_name(conn)), "term %d connects %s", index, conn);
  CHECK(vpi_compare_objects(vpi_handle(vpiPrimitive, t), prim), "term %d leads back to its primitive", index);
}

static int scalar(const char *name)
{
  s_vpi_value v;
  v.format = vpiScalarVal;
  vpi_get_value(p02_by_name(name), &v);
  return (int)v.value.scalar;
}

static PLI_INT32 walk(p_cb_data cb_data)
{
  vpiHandle top = p02_by_name("p04_prims");
  vpiHandle prims[4], terms[4], defns[2], rows[4], ios[4];
  vpiHandle g_and, g_not, lat, defn;
  s_vpi_delay dl;
  s_vpi_time da[3];
  s_vpi_value v;
  int k;
  (void)cb_data;

  CHECK(scan_all(vpi_iterate(vpiPrimitive, top), prims, 4) == 3, "three primitives");
  g_and = prims[0]; g_not = prims[1]; lat = prims[2];

  /* and */
  CHECK(vpi_get(vpiType, g_and) == vpiGate && vpi_get(vpiPrimType, g_and) == vpiAndPrim, "an and gate");
  CHECK(strcmp(vpi_get_str(vpiDefName, g_and), "and") == 0, "whose definition name is its keyword");
  CHECK(vpi_get(vpiSize, g_and) == 2, "NOTE 1: two inputs");
  CHECK(scan_all(vpi_iterate(vpiPrimTerm, g_and), terms, 4) == 3, "three terminals");
  term(terms[0], 0, vpiOutput, "p04_prims.y", g_and);
  term(terms[1], 1, vpiInput, "p04_prims.a", g_and);
  term(terms[2], 2, vpiInput, "p04_prims.b", g_and);
  {
    vpiHandle dly = vpi_handle(vpiDelay, g_and), itr, x;
    PLI_INT32 want = 2;
    CHECK(vpi_get(vpiType, dly) == vpiOperation && vpi_get(vpiOpType, dly) == vpiListOp,
          "IEEE 1364-2005 §26.3.4: vpiDelay of #(2,3) is a vpiListOp operation");
    itr = vpi_iterate(vpiOperand, dly);
    while ((x = vpi_scan(itr)) != NULL) {
      v.format = vpiIntVal;
      vpi_get_value(x, &v);
      CHECK(v.value.integer == want, "delay operand %d", (int)want);
      want++;
    }
    CHECK(want == 4, "two delays, 2 and 3");
  }
  expect_no_error("the and gate");

  memset(&dl, 0, sizeof dl);
  dl.da = da;
  dl.time_type = vpiScaledRealTime;
  dl.no_of_delays = 2;
  vpi_get_delays(g_and, &dl);
  expect_no_error("vpi_get_delays(gate, 2)");
  CHECK(da[0].real == 2.0 && da[1].real == 3.0, "rise 2, fall 3");
  dl.no_of_delays = 3;
  vpi_get_delays(g_and, &dl);
  CHECK(da[2].real == 2.0, "the derived turn-off is the smaller, 2");
  dl.no_of_delays = 1;
  vpi_get_delays(g_and, &dl);
  expect_error("vpi_get_delays(gate, 1): a primitive takes 2 or 3");

  v.format = vpiScalarVal;
  v.value.scalar = vpi0;
  CHECK(vpi_put_value(g_and, &v, NULL, vpiNoDelay) == NULL, "NOTE 2: no put to a gate");
  expect_error("vpi_put_value(gate)");
  CHECK(vpi_handle(vpiUdpDefn, g_and) == NULL, "a gate has no udp defn");
  expect_error("vpi_handle(vpiUdpDefn, gate)");

  /* not */
  CHECK(vpi_get(vpiPrimType, g_not) == vpiNotPrim && vpi_get(vpiSize, g_not) == 1, "a not gate of one input");
  CHECK(vpi_handle(vpiDelay, g_not) == NULL, "with no delay");
  expect_no_error("vpi_handle(vpiDelay, undelayed gate)");
  dl.no_of_delays = 2;
  vpi_get_delays(g_not, &dl);
  expect_error("vpi_get_delays(undelayed gate)");

  /* the UDP instance */
  CHECK(vpi_get(vpiType, lat) == vpiUdp, "a UDP instance");
  CHECK(strcmp(vpi_get_str(vpiName, lat), "lat") == 0 && strcmp(vpi_get_str(vpiFullName, lat), "p04_prims.lat") == 0, "named lat");
  CHECK(strcmp(vpi_get_str(vpiDefName, lat), "p04_latch") == 0, "of p04_latch");
  CHECK(vpi_get(vpiPrimType, lat) == vpiSeqPrim && vpi_get(vpiSize, lat) == 2, "sequential, two inputs");
  CHECK(scan_all(vpi_iterate(vpiPrimTerm, lat), terms, 4) == 3, "three terminals");
  term(terms[0], 0, vpiOutput, "p04_prims.q", lat);
  term(terms[2], 2, vpiInput, "p04_prims.en", lat);

  /* 11.6.14 */
  CHECK(scan_all(vpi_iterate(vpiUdpDefn, NULL), defns, 2) == 1, "one UDP definition");
  defn = defns[0];
  CHECK(vpi_compare_objects(vpi_handle(vpiUdpDefn, lat), defn), "udp -> udp defn");
  CHECK(vpi_get(vpiType, defn) == vpiUdpDefn && strcmp(vpi_get_str(vpiDefName, defn), "p04_latch") == 0, "p04_latch");
  CHECK(vpi_get(vpiSize, defn) == 2 && vpi_get(vpiPrimType, defn) == vpiSeqPrim, "two inputs, sequential");
  CHECK(scan_all(vpi_iterate(vpiIODecl, defn), ios, 4) == 3, "three io decls");
  CHECK(strcmp(vpi_get_str(vpiName, ios[0]), "q") == 0 && vpi_get(vpiDirection, ios[0]) == vpiOutput, "q is the output");
  CHECK(strcmp(vpi_get_str(vpiName, ios[1]), "d") == 0 && vpi_get(vpiDirection, ios[1]) == vpiInput, "d an input");
  CHECK(strcmp(vpi_get_str(vpiName, ios[2]), "en") == 0 && vpi_get(vpiDirection, ios[2]) == vpiInput, "en an input");
  CHECK(scan_all(vpi_iterate(vpiTableEntry, defn), rows, 4) == 3, "three table entries");
  for (k = 0; k < 3; k++) CHECK(vpi_get(vpiSize, rows[k]) == 4, "entry %d holds 4 symbols", k);
  CHECK(vpi_get(vpiDirection, defn) == vpiUndefined, "11.6.14: a definition has no vpiDirection");
  expect_error("vpi_get(vpiDirection, udp defn)");

  /* values */
  CHECK(scalar("p04_prims.y") == vpi1 && scalar("p04_prims.ny") == vpi0 && scalar("p04_prims.q") == vpi1, "y = 1, ny = 0, q = 1");

  p02_done("p04_10_primitives");
  return 0;
}

static void setup_after_compile(void)
{
  static s_vpi_time t = { vpiSimTime, 0, 5, 0.0 };
  static s_cb_data cb;
  cb.reason = cbReadWriteSynch;
  cb.cb_rtn = walk;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadWriteSynch registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
