/* Runtime review of wave23/vpi-prim against IEEE 1364-2005.
 *
 * §26.6.6(i,j), p. 392: only active force/assign statements are loads and
 * only active forces are net drivers. §26.6.23, p. 406, includes force and
 * assign statements among a reg's drivers and loads. §9.3.2 replaces an
 * earlier force of the same object; release ends the force. Therefore:
 *   0 ns: neither force nor assign is active.
 *   1 ns: force y=a drives y and loads a; y=1.
 *   2 ns: force y=b replaces it, drives y and loads b; y=0.
 *   3 ns: release y leaves neither source statement active; y=z.
 *   4 ns: assign r=a drives r and loads a; r=1.
 *   5 ns: deassign r ends that relationship, retaining r=1.
 * C then forces y at 5 ns and releases it at 6 ns: this must not revive
 * either inactive HDL force object. Handles are compared as sets, without
 * assuming any driver/load iteration order. Ordinary procedural writes do
 * not appear in the driver/load classes drawn in §26.6.23.
 *
 * §26.6.14(a), p. 400, permits string and vector values for UDP table
 * entries. §27.14, pp. 432–433, packs four two-byte ASCII symbols in each
 * s_vpi_vecval, first symbol in aval's high half, second in its low half,
 * third/fourth in bval. A one-character symbol has a zero second byte;
 * (01)/(10) use both bytes without parentheses. The three sequential rows
 * below each have five symbols (three inputs, state, output), requiring
 * two vecvals. The combinational rows have three symbols and require one.
 * Colons and spacing belong only to string decompilation, not the symbols.
 * vpiIntVal is the refused neighbour; both legal representations are read.
 *
 * §27.14, p. 431: reg strengths are strong. For bits=4'b10xz, the LSB-first
 * entries must have logic z,x,0,1, each with strong strengths. The caller
 * supplies four entries and a guard; reading must not overwrite the guard.
 * A NULL strength array is refused beside the successful read.
 *
 * All design access occurs after cbEndOfCompile (§26.2.4); startup only
 * registers that action callback. The final marker requires all seven
 * read-only checkpoints, UDP checks, and the final end callback.
 */
//! lrm 12.16
//! lrm 12.16:14
//! lrm 12.16:15
//! lrm 12.16:16
//! lrm 12.16:17
//! inherited IEEE 1364-2005 26.6.6
//! inherited IEEE 1364-2005 26.6.14
//! inherited-reject IEEE 1364-2005 26.6.14
//! inherited IEEE 1364-2005 26.6.22
//! inherited IEEE 1364-2005 26.6.23
//! inherited IEEE 1364-2005 27.14
//! inherited-reject IEEE 1364-2005 27.14
//! design prim_review.v
//! stdout b26_prim_review: active drivers, UDP symbols and strengths ok

#include "b_check.h"
#include <stdint.h>

static vpiHandle a, b, r, y, forces[2], assign_r;
static int visited;

static vpiHandle first(PLI_INT32 tag, vpiHandle ref)
{
  vpiHandle it = vpi_iterate(tag, ref), h;
  CHECK(it != NULL, "relationship %d has an iterator", (int)tag);
  h = vpi_scan(it);
  CHECK(h != NULL, "relationship %d has an object", (int)tag);
  vpi_free_object(it);
  return h;
}

static void only(PLI_INT32 tag, vpiHandle ref, vpiHandle want)
{
  vpiHandle it = vpi_iterate(tag, ref), h;
  expect_no_error("driver/load traversal");
  if (want == NULL) {
    CHECK(it == NULL, "no active object for relationship %d", (int)tag);
    return;
  }
  CHECK(it != NULL, "one active object for relationship %d", (int)tag);
  h = vpi_scan(it);
  CHECK(h != NULL && vpi_compare_objects(h, want), "relationship reaches the active statement");
  CHECK(vpi_scan(it) == NULL, "no inactive statement accompanies the active one");
}

static void no_hdl_force(void)
{
  vpiHandle it = vpi_iterate(vpiDriver, y), h;
  expect_no_error("drivers during a C force");
  if (it != NULL) while ((h = vpi_scan(it)) != NULL) {
    CHECK(!vpi_compare_objects(h, forces[0]) && !vpi_compare_objects(h, forces[1]),
          "a C force must not activate an HDL force statement");
  }
}

static int scalar(vpiHandle h)
{
  s_vpi_value v;
  memset(&v, 0, sizeof v);
  v.format = vpiScalarVal;
  vpi_get_value(h, &v);
  expect_no_error("scalar value");
  return v.value.scalar;
}

static int squeezed_is(const char *s, const char *want)
{
  for (; *s; s++) {
    if (*s == ' ' || *s == '\t') continue;
    if (*s != *want) return 0;
    want++;
  }
  return *want == 0;
}

static unsigned symbol(const s_vpi_vecval *v, unsigned i)
{
  uint32_t word = (uint32_t)(i % 4 < 2 ? v[i / 4].aval : v[i / 4].bval);
  return (word >> (i % 2 == 0 ? 16 : 0)) & 0xffffu;
}

static void udp_tables(void)
{
  static const char *rows[6] = { "10?:?:1", "0(01)?:?:-", "(10)0?:0:1", "00:0", "01:1", "1?:x" };
  static const unsigned symbols[6][5] = {
    { 0x3100, 0x3000, 0x3f00, 0x3f00, 0x3100 },
    { 0x3000, 0x3031, 0x3f00, 0x3f00, 0x2d00 },
    { 0x3130, 0x3000, 0x3f00, 0x3000, 0x3100 },
    { 0x3000, 0x3000, 0x3000, 0, 0 },
    { 0x3000, 0x3100, 0x3100, 0, 0 },
    { 0x3100, 0x3f00, 0x7800, 0, 0 }
  };
  vpiHandle defs = vpi_iterate(vpiUdpDefn, NULL), def;
  unsigned seen = 0;
  CHECK(defs != NULL, "UDP definitions");
  while ((def = vpi_scan(defs)) != NULL) {
    vpiHandle entries = vpi_iterate(vpiTableEntry, def), entry;
    CHECK(entries != NULL, "UDP entries");
    while ((entry = vpi_scan(entries)) != NULL) {
      s_vpi_value v;
      unsigned k, i, size;
      memset(&v, 0, sizeof v);
      v.format = vpiStringVal;
      vpi_get_value(entry, &v);
      expect_no_error("table string");
      CHECK(v.value.str != NULL, "table decompilation");
      for (k = 0; k < 6; k++) if (squeezed_is(v.value.str, rows[k])) break;
      CHECK(k < 6 && !(seen & (1u << k)), "each table row appears exactly once");
      seen |= 1u << k;
      size = k < 3 ? 5u : 3u;
      CHECK((unsigned)vpi_get(vpiSize, entry) == size, "symbol count excludes punctuation");
      v.format = vpiVectorVal;
      vpi_get_value(entry, &v);
      expect_no_error("table ASCII vector");
      CHECK(v.value.vector != NULL, "table symbol storage");
      for (i = 0; i < size; i++) CHECK(symbol(v.value.vector, i) == symbols[k][i], "row %u symbol %u", k, i);
      v.format = vpiIntVal;
      vpi_get_value(entry, &v);
      expect_refusal("table integer format");
    }
  }
  CHECK(seen == 0x3f, "all six UDP rows checked");
}

static void strengths(void)
{
  static const int want[4] = { vpiZ, vpiX, vpi0, vpi1 };
  s_vpi_strengthval out[5];
  s_vpi_value v;
  vpiHandle bits = p02_by_name("b26_prim_review.bits");
  int i;
  memset(out, 0, sizeof out);
  out[4].logic = 123;
  out[4].s0 = 456;
  out[4].s1 = 789;
  memset(&v, 0, sizeof v);
  v.format = vpiStrengthVal;
  v.value.strength = out;
  vpi_get_value(bits, &v);
  expect_no_error("reg vector strength");
  for (i = 0; i < 4; i++) CHECK(out[i].logic == want[i] && out[i].s0 == vpiStrongDrive && out[i].s1 == vpiStrongDrive,
                               "reg bit %d has strong strength and the declared logic", i);
  CHECK(out[4].logic == 123 && out[4].s0 == 456 && out[4].s1 == 789, "strength buffer guard");
  v.value.strength = NULL;
  vpi_get_value(bits, &v);
  expect_refusal_saying("NULL strength buffer", "NULL strength array");
}

static PLI_INT32 inspect(p_cb_data cb)
{
  s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  vpiHandle force, assign;
  (void)cb;
  vpi_get_time(NULL, &t);
  CHECK(visited < 7 && t.high == 0 && t.low == (unsigned)visited, "checkpoint sequence");
  force = visited == 1 ? forces[0] : visited == 2 ? forces[1] : NULL;
  assign = visited == 4 ? assign_r : NULL;
  if (visited == 5) no_hdl_force(); else only(vpiDriver, y, force);
  only(vpiLoad, a, visited == 1 ? force : assign);
  only(vpiLoad, b, visited == 2 ? force : NULL);
  only(vpiDriver, r, assign);
  CHECK(scalar(y) == (visited == 1 || visited == 5 ? vpi1 : visited == 2 ? vpi0 : vpiZ), "resolved/forced y value");
  CHECK(scalar(r) == (visited >= 4 ? vpi1 : vpi0), "procedural assign value and deassign retention");
  if (visited == 0) strengths();
  visited++;
  return 0;
}

static PLI_INT32 c_force(p_cb_data cb)
{
  s_vpi_value v;
  memset(&v, 0, sizeof v);
  v.format = vpiScalarVal;
  v.value.scalar = vpi1;
  vpi_put_value(y, &v, NULL, cb->index == 5 ? vpiForceFlag : vpiReleaseFlag);
  expect_no_error("C force/release");
  return 0;
}

static PLI_INT32 finished(p_cb_data cb)
{
  (void)cb;
  CHECK(visited == 7, "all primitive checkpoints ran");
  puts("b26_prim_review: active drivers, UDP symbols and strengths ok");
  return 0;
}

static PLI_INT32 compiled(p_cb_data ignored)
{
  vpiHandle top = p02_by_name("b26_prim_review"), body, it, stmt;
  s_cb_data cb;
  unsigned i, n = 0;
  (void)ignored;
  a = p02_by_name("b26_prim_review.a");
  b = p02_by_name("b26_prim_review.b");
  r = p02_by_name("b26_prim_review.r");
  y = p02_by_name("b26_prim_review.y");
  body = vpi_handle(vpiStmt, first(vpiProcess, top));
  it = vpi_iterate(vpiStmt, body);
  CHECK(it != NULL, "initial block statements");
  while ((stmt = vpi_scan(it)) != NULL) {
    if (vpi_get(vpiType, stmt) == vpiDelayControl) stmt = vpi_handle(vpiStmt, stmt);
    if (vpi_get(vpiType, stmt) == vpiForce) {
      CHECK(n < 2, "two source force statements");
      forces[n++] = stmt;
    } else if (vpi_get(vpiType, stmt) == vpiAssignStmt) assign_r = stmt;
  }
  CHECK(n == 2 && assign_r != NULL, "all procedural driver statements found");
  udp_tables();
  for (i = 0; i <= 6; i++) {
    s_vpi_time t = { vpiSimTime, 0, i, 0.0 };
    memset(&cb, 0, sizeof cb);
    cb.reason = cbReadOnlySynch;
    cb.cb_rtn = inspect;
    cb.time = &t;
    CHECK(vpi_register_cb(&cb) != NULL, "register checkpoint");
    if (i >= 5) {
      cb.reason = cbReadWriteSynch;
      cb.cb_rtn = c_force;
      cb.index = (PLI_INT32)i;
      CHECK(vpi_register_cb(&cb) != NULL, "register C force/release");
    }
  }
  memset(&cb, 0, sizeof cb);
  cb.reason = cbEndOfSimulation;
  cb.cb_rtn = finished;
  CHECK(vpi_register_cb(&cb) != NULL, "register completion");
  return 0;
}

static void setup(void)
{
  s_cb_data cb;
  memset(&cb, 0, sizeof cb);
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = compiled;
  CHECK(vpi_register_cb(&cb) != NULL, "register compile callback");
}

void (*vlog_startup_routines[])(void) = { setup, NULL };
