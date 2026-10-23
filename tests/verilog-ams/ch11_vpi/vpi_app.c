/* The acceptance test for plan item P01: a real C VPI application.
 *
 * LRM §12.33.2 — "A means of initializing system task/function callbacks and
 * performing any other desired task just after the simulator is invoked shall
 * be provided by placing routines in a NULL-terminated static array,
 * vlog_startup_routines." This file IS such an application: one translation
 * unit, compiled against src/vpi/vpi_user.h, linked against VerA's exported
 * routines, entered only through that array. Nothing in it is Zig-aware.
 * The array's routine only registers a cbEndOfCompile callback, where the
 * walk runs: IEEE 1364-2005 26.2.4 allows nothing but vpi_register_systf()
 * and vpi_register_cb() while the startup routines run, and "all
 * functionality is available" from cbEndOfCompile on (VD-044).
 *
 * WHY THIS AND NOT A ZIG UNIT TEST. Three things are only under test from here:
 *
 *   - the CONSTANT VALUES. Every `vpiModule`, `vpiInout`, `vpiUndefined` below
 *     comes from the header, and every assertion that compares one to a routine
 *     result is an assertion that the header and the implementation agree on
 *     the number. A Zig test uses the implementation's own copy on both sides
 *     of the comparison and cannot disagree with itself.
 *   - the ABI: the parameter and return types as C spells them, and the
 *     `char *` lifetime rule of §12.12 — which this file obeys deliberately
 *     (see `take`), because an application that does not is the bug that rule
 *     exists to prevent.
 *   - OBJECT LIFETIMES across real C control flow: an iterator abandoned by a
 *     `break`, an iterator scanned past its end, a handle kept across dozens of
 *     intervening calls.
 *
 * WHAT IT ASSERTS, in order: the top-level entry of §11.6.1 NOTE 1; a recursive
 * §11.6.1 `vpiInternalScope` descent over a three-deep design; the §11.6.4/
 * §11.6.8/§11.6.9/§11.6.12 iterations at every level; §11.2.2 instance
 * uniqueness; §12.21's two name forms and §6.7's upward search; §12.3 identity;
 * §12.4/§12.35 iterator lifetime; invalid requests and implementation-specific
 * handle robustness; and separately labelled required-positive checks, each
 * reporting `PASS <ID>:` on stderr for the evidence ledger (build.zig).
 *
 * Failure is `exit(1)` with a message naming the check; success prints one
 * census line, which is what proves the startup routine and its callback
 * ran at all.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vpi_user.h"

/* ------------------------------------------------------------------------- */

static int checks = 0;

#define CHECK(cond, ...)                                                      \
  do {                                                                        \
    checks++;                                                                 \
    if (!(cond)) {                                                            \
      fprintf(stderr, "vpi_app: %s:%d: ", __FILE__, __LINE__);                \
      fprintf(stderr, __VA_ARGS__);                                           \
      fprintf(stderr, "\n  failed: %s\n", #cond);                             \
      report_error();                                                         \
      exit(1);                                                                \
    }                                                                         \
  } while (0)

static void report_error(void)
{
  s_vpi_error_info info;
  if (!vpi_chk_error(&info)) {
    fprintf(stderr, "  (vpi_chk_error reports no error)\n");
    return;
  }
  fprintf(stderr, "  vpi_chk_error: level=%d state=%d code=%s message=%s\n",
          info.level, info.state,
          info.code ? info.code : "(none)",
          info.message ? info.message : "(none)");
}

/* §12.12: "The string shall be placed in a temporary buffer which shall be used
 * by every call to this routine. If the string is to be used after a subsequent
 * call, the string needs to be copied to another location."
 *
 * So every name this file keeps is copied out immediately. Holding the returned
 * pointer across one more vpi_get_str() is the documented way to read the wrong
 * name, and an acceptance test that did it would pass by accident. */
static char *take(char *dst, size_t cap, PLI_INT32 prop, vpiHandle obj)
{
  char *s = vpi_get_str(prop, obj);
  CHECK(s != NULL, "vpi_get_str(%d) returned NULL", (int)prop);
  CHECK(strlen(s) < cap, "name `%s` does not fit the caller's buffer", s);
  strcpy(dst, s);
  return dst;
}

/* §12.2: "The error status shall be reset by any VPI routine call except
 * vpi_chk_error()." Asserted after every call that is expected to SUCCEED, so a
 * stale error cannot make a later negative check pass for the wrong reason. */
static void expect_no_error(const char *what)
{
  s_vpi_error_info info;
  PLI_INT32 level = vpi_chk_error(&info);
  checks++;
  if (level != 0) {
    fprintf(stderr, "vpi_app: %s unexpectedly set an error: code=%s message=%s\n",
            what, info.code ? info.code : "(none)",
            info.message ? info.message : "(none)");
    exit(1);
  }
}

/* The other half: a call that must fail, must report vpiError, and must report
 * it as §12.2's `vpiPLI` state with a code and a message an application can
 * show a user. */
static void expect_error(const char *what)
{
  s_vpi_error_info info;
  PLI_INT32 level = vpi_chk_error(&info);
  checks++;
  if (level != vpiError) {
    fprintf(stderr, "vpi_app: %s should have set vpiError, got %d\n", what, (int)level);
    exit(1);
  }
  CHECK(info.state == vpiPLI, "%s: error state should be vpiPLI", what);
  CHECK(info.code != NULL && info.code[0] != '\0', "%s: error carries no code", what);
  CHECK(info.message != NULL && info.message[0] != '\0', "%s: error carries no message", what);
  CHECK(info.product != NULL && strcmp(info.product, "VerA") == 0,
        "%s: error carries the wrong product name", what);
  /* "Calling vpi_chk_error() shall have no effect on the error status." */
  CHECK(vpi_chk_error(NULL) == vpiError, "%s: vpi_chk_error reset the status", what);
}

/* ------------------------------------------------------------------------- */

struct census {
  int scopes;
  int ports;
  int nets;
  int regs;
  int params;
};

/* Count one relationship, and check every object it yields belongs to the class
 * that was asked for and answers the §11.6 properties that class has. */
static int count(PLI_INT32 type, PLI_INT32 expect_type, vpiHandle scope)
{
  vpiHandle itr = vpi_iterate(type, scope);
  vpiHandle obj;
  int n = 0;
  char scope_name[256];
  char name[256];
  char full[512];

  take(scope_name, sizeof scope_name, vpiFullName, scope);
  if (itr == NULL) {
    /* §12.23: an empty set is NULL, and NOT an error. */
    expect_no_error("vpi_iterate over an empty set");
    return 0;
  }
  CHECK(vpi_get(vpiType, itr) == vpiIterator, "an iterator is not a vpiIterator");
  while ((obj = vpi_scan(itr)) != NULL) {
    CHECK(vpi_get(vpiType, obj) == expect_type,
          "vpi_iterate(%d) yielded an object of type %d", (int)type, (int)vpi_get(vpiType, obj));
    take(name, sizeof name, vpiName, obj);
    take(full, sizeof full, vpiFullName, obj);
    /* §11.6: the full name is the scope's full name, the separator, and the
     * local name. That is the whole of §6.7 for an elaborated design, and it is
     * the invariant a wrongly-bucketed declaration breaks. */
    CHECK(strlen(full) == strlen(scope_name) + 1 + strlen(name) &&
              strncmp(full, scope_name, strlen(scope_name)) == 0 &&
              full[strlen(scope_name)] == '.' &&
              strcmp(full + strlen(scope_name) + 1, name) == 0,
          "`%s` is not `%s` . `%s`", full, scope_name, name);
    /* §11.6.4/§11.6.8/§11.6.12's back edge, from both spellings. */
    CHECK(vpi_compare_objects(vpi_handle(vpiScope, obj), scope) == 1,
          "`%s` does not point back at `%s`", full, scope_name);
    CHECK(vpi_compare_objects(vpi_handle(vpiModule, obj), scope) == 1,
          "`%s`'s vpiModule edge is not its scope", full);
    /* §12.21 round trip: the name it reports is the name it answers to. */
    CHECK(vpi_compare_objects(vpi_handle_by_name(full, NULL), obj) == 1,
          "`%s` does not resolve back to itself", full);
    expect_no_error("the per-object property block");
    n++;
  }
  /* §12.35: the iterator was freed by the scan that returned NULL, so it is now
   * an invalid handle rather than a spent one. */
  CHECK(vpi_scan(itr) == NULL, "a scan past the end of an iterator returned an object");
  expect_error("vpi_scan on an exhausted iterator");
  return n;
}

/* §11.6.1's `vpiInternalScope`, recursively. */
static void walk(vpiHandle mod, int depth, struct census *c)
{
  char full[512];
  char def[256];
  vpiHandle itr, child;

  CHECK(vpi_get(vpiType, mod) == vpiModule, "a scope is not a vpiModule");
  take(full, sizeof full, vpiFullName, mod);
  take(def, sizeof def, vpiDefName, mod);
  CHECK(def[0] != '\0', "`%s` has an empty vpiDefName", full);
  /* §11.6.1: only the root of the instance tree is the top module. */
  CHECK(vpi_get(vpiTopModule, mod) == (depth == 0 ? 1 : 0),
        "`%s` answers vpiTopModule wrongly at depth %d", full, depth);
  expect_no_error("the per-scope property block");

  c->scopes++;
  c->ports += count(vpiPort, vpiPort, mod);
  c->nets += count(vpiNet, vpiNet, mod);
  c->regs += count(vpiReg, vpiReg, mod);
  c->params += count(vpiParameter, vpiParameter, mod);

  itr = vpi_iterate(vpiInternalScope, mod);
  if (itr == NULL) {
    expect_no_error("vpi_iterate(vpiInternalScope) over a leaf");
    return;
  }
  while ((child = vpi_scan(itr)) != NULL) {
    CHECK(vpi_compare_objects(vpi_handle(vpiScope, child), mod) == 1,
          "a child of `%s` does not point back at it", full);
    walk(child, depth + 1, c);
  }
}

/* ------------------------------------------------------------------------- */

/* §11.6.1 NOTE 1 — "Top-level modules shall be accessed using vpi_iterate()
 * with a NULL reference object." */
static vpiHandle find_top(void)
{
  vpiHandle itr = vpi_iterate(vpiModule, NULL);
  vpiHandle top, extra;
  CHECK(itr != NULL, "no top-level module is reachable from a NULL reference");
  top = vpi_scan(itr);
  CHECK(top != NULL, "the top-level iterator yielded nothing");
  extra = vpi_scan(itr);
  CHECK(extra == NULL, "a Verilog-AMS device has one elaborated root, not two");
  expect_no_error("the top-level iteration");
  return top;
}

/* §12.21's two name forms, and §6.7's upward search between them. */
static void check_names(vpiHandle top)
{
  vpiHandle leaf = vpi_handle_by_name("vpi_top.u1.v", NULL);
  vpiHandle deep, mid, same, sibling_net;

  CHECK(leaf != NULL, "an absolute hierarchical name did not resolve");
  expect_no_error("vpi_handle_by_name with a NULL scope");

  /* Declared in the scope itself. */
  deep = vpi_handle_by_name("deep", leaf);
  CHECK(deep != NULL, "a simple name did not resolve in its own scope");
  CHECK(vpi_compare_objects(deep, vpi_handle_by_name("vpi_top.u1.v.deep", NULL)) == 1,
        "the simple and absolute spellings named different objects");

  /* Declared TWO levels up: §12.21's "scope search rules defined by the
   * Verilog-AMS HDL", which §6.7 makes an upward walk. */
  mid = vpi_handle_by_name("mid", leaf);
  CHECK(mid != NULL, "the upward scope search did not reach the top's own net");
  CHECK(vpi_compare_objects(mid, vpi_handle_by_name("vpi_top.mid", NULL)) == 1,
        "the upward search found the wrong `mid`");

  /* §12.3: the same object, asked for twice, two different ways. */
  same = vpi_handle_by_name("vpi_top.u1.v.deep", NULL);
  CHECK(vpi_compare_objects(deep, same) == 1, "two handles to one object compared unequal");
  CHECK(vpi_compare_objects(deep, mid) == 0, "two different objects compared equal");

  /* §11.2.2: instance-unique access. `u1.v.deep` and `u2.v.deep` are the same
   * DECLARATION in the same module definition and two different objects. */
  sibling_net = vpi_handle_by_name("vpi_top.u2.v.deep", NULL);
  CHECK(sibling_net != NULL, "the second instance of the leaf has no `deep`");
  CHECK(vpi_compare_objects(deep, sibling_net) == 0,
        "two instances of one module share one net object");
  /* ... and they are instances of the same definition. */
  {
    char a[256], b[256];
    take(a, sizeof a, vpiDefName, vpi_handle_by_name("vpi_top.u1", NULL));
    take(b, sizeof b, vpiDefName, vpi_handle_by_name("vpi_top.u2", NULL));
    CHECK(strcmp(a, b) == 0, "two instances of one module report different definitions");
    CHECK(strcmp(a, "vpi_mid") == 0, "vpiDefName is `%s`, not the module definition's name", a);
  }

  /* The top module answers to its own name, with and without a scope. */
  CHECK(vpi_compare_objects(vpi_handle_by_name("vpi_top", NULL), top) == 1,
        "the top module does not answer to its own name");
  CHECK(vpi_handle(vpiScope, top) == NULL, "the top module has a containing scope");
  expect_no_error("vpi_handle(vpiScope) at the top of the hierarchy");
}

/* §11.6.4/§11.6.9/§11.6.12 properties, on objects whose declarations are known.
 * Each one is a property the class HAS; the failure surface is checked below. */
static void check_properties(void)
{
  vpiHandle p = vpi_handle_by_name("vpi_top.p", NULL);
  vpiHandle en = vpi_handle_by_name("vpi_top.en", NULL);
  vpiHandle y = vpi_handle_by_name("vpi_top.u1.v.y", NULL);
  vpiHandle bus = vpi_handle_by_name("vpi_top.bus", NULL);
  vpiHandle mid = vpi_handle_by_name("vpi_top.mid", NULL);
  vpiHandle state = vpi_handle_by_name("vpi_top.state", NULL);
  vpiHandle ready = vpi_handle_by_name("vpi_top.ready", NULL);
  vpiHandle gain = vpi_handle_by_name("vpi_top.gain", NULL);
  vpiHandle revision = vpi_handle_by_name("vpi_top.revision", NULL);
  vpiHandle taps = vpi_handle_by_name("vpi_top.u1.v.taps", NULL);
  vpiHandle trim = vpi_handle_by_name("vpi_top.u1.v.trim", NULL);
  vpiHandle scale = vpi_handle_by_name("vpi_top.u1.scale", NULL);

  /* §6.5.2.2 directions, three different ones, and §11.6.4's header position. */
  CHECK(vpi_get(vpiDirection, p) == vpiInout, "`p` is not inout");
  CHECK(vpi_get(vpiDirection, en) == vpiInput, "`en` is not input");
  CHECK(vpi_get(vpiDirection, y) == vpiOutput, "`y` is not output");
  CHECK(vpi_get(vpiPortIndex, p) == 0, "`p` is not the first port");
  CHECK(vpi_get(vpiPortIndex, en) == 2, "`en` is not the third port");

  /* §11.6.4 NOTE 3 / §11.6.8: scalar and vector are about the object's width. */
  CHECK(vpi_get(vpiSize, mid) == 1, "a scalar net is not 1 bit");
  CHECK(vpi_get(vpiScalar, mid) == 1 && vpi_get(vpiVector, mid) == 0, "`mid` is not scalar");
  CHECK(vpi_get(vpiSize, bus) == 4, "`electrical [0:3] bus` is not 4 bits");
  CHECK(vpi_get(vpiScalar, bus) == 0 && vpi_get(vpiVector, bus) == 1, "`bus` is not a vector");

  /* §11.6.9. */
  CHECK(vpi_get(vpiSize, state) == 4, "`reg [3:0] state` is not 4 bits");
  CHECK(vpi_get(vpiSize, ready) == 1, "a scalar reg is not 1 bit");
  CHECK(vpi_get(vpiSigned, state) != vpiUndefined, "a reg has no signedness");

  /* §11.6.12 over §3.4.1's types and §3.4.5's localparam. */
  CHECK(vpi_get(vpiConstType, gain) == vpiRealConst, "`gain` is not a real constant");
  CHECK(vpi_get(vpiConstType, revision) == vpiIntConst, "`revision` is not an integer constant");
  CHECK(vpi_get(vpiConstType, taps) == vpiIntConst, "`taps` is not an integer constant");
  CHECK(vpi_get(vpiLocalParam, gain) == 0, "`gain` is a parameter, not a localparam");
  CHECK(vpi_get(vpiLocalParam, revision) == 1, "`revision` is a localparam");
  CHECK(vpi_get(vpiLocalParam, trim) == 1, "a child's localparam is a localparam");
  /* The one the flatten could get wrong: elaboration rewrites a child's
   * `parameter` into a `localparam` carrying its override, and §11.6.12 is
   * about the declaration, not about the rewrite. */
  CHECK(vpi_get(vpiLocalParam, scale) == 0, "a child's `parameter` was reported as a localparam");
  expect_no_error("the property block");
}

/* The failure surface. Every call here must return its documented failure value
 * and set §12.2's status — and, since this is a C program holding pointers VerA
 * never issued, must not crash doing it. */
static void check_failures(vpiHandle top)
{
  /* A pointer VerA did not hand out. Static storage, so it is a valid address
   * an application could plausibly pass — a freed handle, a struct member, a
   * stack slot — and not a trap representation. */
  static PLI_UINT32 not_a_handle;
  vpiHandle bogus = &not_a_handle;
  vpiHandle net = vpi_handle_by_name("vpi_top.mid", NULL);
  vpiHandle itr;

  CHECK(vpi_get(vpiType, bogus) == vpiUndefined, "vpi_get accepted a foreign handle");
  expect_error("vpi_get on a foreign handle");
  CHECK(vpi_get_str(vpiName, bogus) == NULL, "vpi_get_str accepted a foreign handle");
  expect_error("vpi_get_str on a foreign handle");
  CHECK(vpi_handle(vpiScope, bogus) == NULL, "vpi_handle accepted a foreign handle");
  expect_error("vpi_handle on a foreign handle");
  CHECK(vpi_iterate(vpiNet, bogus) == NULL, "vpi_iterate accepted a foreign handle");
  expect_error("vpi_iterate on a foreign handle");
  CHECK(vpi_scan(bogus) == NULL, "vpi_scan accepted a foreign handle");
  expect_error("vpi_scan on a foreign handle");
  CHECK(vpi_handle_by_name("mid", bogus) == NULL, "vpi_handle_by_name accepted a foreign scope");
  expect_error("vpi_handle_by_name with a foreign scope");
  CHECK(vpi_handle_by_index(bogus, 0) == NULL, "vpi_handle_by_index accepted a foreign handle");
  expect_error("vpi_handle_by_index on a foreign handle");
  CHECK(vpi_free_object(bogus) == 0, "vpi_free_object accepted a foreign handle");
  expect_error("vpi_free_object on a foreign handle");
  CHECK(vpi_release_handle(bogus) == 0, "vpi_release_handle accepted a foreign handle");
  expect_error("vpi_release_handle on a foreign handle");
  CHECK(vpi_compare_objects(top, bogus) == 0, "vpi_compare_objects accepted a foreign handle");
  expect_error("vpi_compare_objects with a foreign handle");

  /* NULL is a handle an application passes by accident more often than any
   * other, and §12.5's NULL case (vpiTimeUnit) is not one VerA answers. */
  CHECK(vpi_get(vpiType, NULL) == vpiUndefined, "vpi_get accepted a NULL handle");
  expect_error("vpi_get on NULL");
  CHECK(vpi_get_str(vpiFullName, NULL) == NULL, "vpi_get_str accepted a NULL handle");
  expect_error("vpi_get_str on NULL");
  CHECK(vpi_handle_by_name(NULL, NULL) == NULL, "vpi_handle_by_name accepted a NULL name");
  expect_error("vpi_handle_by_name with a NULL name");

  /* Unsupported PROPERTY requests — §11.6.8 gives a net no direction, §11.6.1
   * gives a module no size, and a net has no definition to name. */
  CHECK(vpi_get(vpiDirection, net) == vpiUndefined, "a net answered vpiDirection");
  expect_error("vpi_get(vpiDirection) on a net");
  CHECK(vpi_get(vpiSize, top) == vpiUndefined, "a module answered vpiSize");
  expect_error("vpi_get(vpiSize) on a module");
  CHECK(vpi_get(vpiPortIndex, net) == vpiUndefined, "a net answered vpiPortIndex");
  expect_error("vpi_get(vpiPortIndex) on a net");
  CHECK(vpi_get(vpiLocalParam, net) == vpiUndefined, "a net answered vpiLocalParam");
  expect_error("vpi_get(vpiLocalParam) on a net");
  CHECK(vpi_get_str(vpiDefName, net) == NULL, "a net answered vpiDefName");
  expect_error("vpi_get_str(vpiDefName) on a net");

  /* Unsupported RELATIONSHIPS. §12.23 returns NULL for an empty set too, so the
   * error status is the only thing that tells the two apart — which is why it
   * is checked rather than the return value alone. */
  CHECK(vpi_iterate(vpiNet, NULL) == NULL, "vpiNet was iterable from a NULL reference");
  expect_error("vpi_iterate(vpiNet) from NULL");
  CHECK(vpi_handle(vpiPort, net) == NULL, "vpiPort was a one-to-one relationship from a net");
  expect_error("vpi_handle(vpiPort) from a net");


  /* §12.4: an iterator abandoned before it was exhausted. The `break` below is
   * the case the clause is written for — "which can happen if the code breaks
   * out of an iteration loop before it has scanned every object". */
  itr = vpi_iterate(vpiNet, top);
  CHECK(itr != NULL, "the top module has no nets to abandon an iterator over");
  CHECK(vpi_scan(itr) != NULL, "the abandoned iterator yielded nothing");
  CHECK(vpi_free_object(itr) == 1, "vpi_free_object refused a live iterator");
  expect_no_error("vpi_free_object on a live iterator");
  /* Freed, so it is now a foreign handle like any other. */
  CHECK(vpi_scan(itr) == NULL, "a freed iterator still scanned");
  expect_error("vpi_scan on a freed iterator");

  /* §12.4's other half: an OBJECT is owned by the design, and freeing a handle
   * to one is a no-op an application is entitled to perform. */
  CHECK(vpi_free_object(top) == 1, "vpi_free_object refused an object handle");
  expect_no_error("vpi_free_object on an object handle");
  CHECK(vpi_release_handle(net) == 1, "vpi_release_handle refused an object handle");
  expect_no_error("vpi_release_handle on an object handle");
  /* ... and the object is still there afterwards. */
  CHECK(vpi_get(vpiType, top) == vpiModule, "an object died when its handle was released");
}

/* Required-positive capabilities, each a named `// evidence: pass <ID>` check
 * that build.zig matches against a `PASS <ID>:` line on stderr. Once these
 * were `evidence: xfail` probes with XPASS guards; the guards went when the
 * behaviour arrived, and the positive oracle stayed.
 */
static void check_required_positive(void)
{
  vpiHandle u1 = vpi_handle_by_name("vpi_top.u1", NULL);
  PLI_INT32 line = vpi_get(vpiLineNo, u1);
  vpiHandle bus, bit, itr;
  char name[256];

  /* AMS §§11.6.1,12.5; IEEE Annex G: location is where the object
   * is USED, not its definition. vpi_design.va:38 instantiates u1;
   * the vpi_mid definition is line48. No `line directive changes either. */
  // evidence: pass VPI-LINE-INSTANCE
  CHECK(u1 != NULL && line == 39, "VPI-LINE-INSTANCE: expected source line 39, observed %d", (int)line);
  expect_no_error("vpi_get(vpiLineNo) on an instance");
  fprintf(stderr, "PASS VPI-LINE-INSTANCE: u1 is instantiated on line %d\n", (int)line);

  /* AMS §11.6.8 NOTE1 requires vector bits even without expansion;
   * §12.20 returns the indexed child. bus is [0:3], so zero is IN range,
   * and IEEE 1364-2005 §26.6.6 makes the child a one-bit vpiNetBit whose
   * vpiParent is the vector. */
  bus = vpi_handle_by_name("vpi_top.bus", NULL);
  bit = vpi_handle_by_index(bus, 0);
  // evidence: pass VPI-INDEX-VALID-BIT
  CHECK(bit != NULL, "VPI-INDEX-VALID-BIT: bus[0] has no handle");
  expect_no_error("vpi_handle_by_index(bus, 0)");
  CHECK(vpi_get(vpiSize, bit) == 1, "VPI-INDEX-VALID-BIT: bus[0] is %d bits wide", (int)vpi_get(vpiSize, bit));
  take(name, sizeof name, vpiName, bit);
  CHECK(strcmp(name, "bus[0]") == 0, "VPI-INDEX-VALID-BIT: the bit is named `%s`", name);
  CHECK(vpi_compare_objects(vpi_handle(vpiParent, bit), bus) == 1, "VPI-INDEX-VALID-BIT: bus[0]'s vpiParent is not bus");
  expect_no_error("the bit's property block");
  fprintf(stderr, "PASS VPI-INDEX-VALID-BIT: bus[0] is a one-bit net bit of bus\n");

  /* §11.6.8 includes vpiPort (low connection), distinct from vpiPortInst
   * (high connection). mid is internal to vpi_top, not one of its ports;
   * child connections do not make it a low connection of a parent port.
   * §12.23 therefore requires an EMPTY successful iteration, not an error. */
  itr = vpi_iterate(vpiPort, vpi_handle_by_name("vpi_top.mid", NULL));
  // evidence: pass VPI-PORT-EMPTY-RELATION
  CHECK(itr == NULL, "VPI-PORT-EMPTY-RELATION: an internal net yielded a port iterator");
  expect_no_error("vpi_iterate(vpiPort) over an internal net");
  fprintf(stderr, "PASS VPI-PORT-EMPTY-RELATION: an internal net's port set is empty, without an error\n");
}

/* ------------------------------------------------------------------------- */

static void vpi_app_main(void)
{
  struct census c;
  vpiHandle top;
  char def[256];

  memset(&c, 0, sizeof c);
  top = find_top();
  take(def, sizeof def, vpiDefName, top);
  CHECK(strcmp(def, "vpi_top") == 0, "the top module's definition is `%s`", def);

  walk(top, 0, &c);
  check_names(top);
  check_properties();
  check_failures(top);
  check_required_positive();

  printf("vpi: scopes=%d ports=%d nets=%d regs=%d params=%d checks=%d\n",
         c.scopes, c.ports, c.nets, c.regs, c.params, checks);
  fflush(stdout);
}

static PLI_INT32 at_end_of_compile(p_cb_data cb_data)
{
  (void)cb_data;
  vpi_app_main();
  return 0;
}

/* IEEE 1364-2005 26.2.4: the startup routine registers; the walk waits for
 * cbEndOfCompile. A failed registration is reported, not counted: the census
 * counts the walk's own checks. */
static void vpi_app_startup(void)
{
  static s_cb_data cb;
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = at_end_of_compile;
  if (vpi_register_cb(&cb) == NULL) {
    fprintf(stderr, "vpi: the cbEndOfCompile registration failed\n");
    exit(1);
  }
}

/* §12.33.2: "Entries in the array shall be added by the user ... 0 shall be
 * last entry in list." */
void (*vlog_startup_routines[])(void) = {
    vpi_app_startup,
    0,
};
