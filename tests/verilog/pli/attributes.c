/* IEEE 1364-2005 §§3.8, 26.6.42, 27.14/16/21 over the paired HDL.
 *
 * §3.8 / AMS §2.9 give an omitted value 1 and let the last duplicate win.
 * Their Example 5 attaches a declaration prefix to each declared name,
 * without propagating it to an undecorated neighbor. §26.6.42 supplies
 * attribute iteration, names, values, parents and definition provenance.
 *
 * DERIVATION: duplicate is 9; w/w2 share "on"; the wide value retains all
 * 80 bits including x/z; 1.25 is exactly representable. Child a has W=3,
 * b has W=5, and c/d retain W=2: each localw and constant-function attribute
 * is twice W. Instantiation/connection attributes read the parent's BASE=10.
 * Generated gw attributes read their own g=0/1 localparams, giving 5/6.
 * f's declaration prefix sees outer BASE=10; its formals/locals see BASE=20.
 * §10.4.5: evaluating twice(W) for metadata leaves the static formal and
 * result at their initial x values when simulation starts.
 * Only module-definition attributes have vpiDefAttribute=TRUE. Process,
 * statement, operator and call prefixes/suffixes have distinct owners.
 * Execution ends this time slot at marked=f(8)=9, r=w=w2=1.
 *
 * REFUSALS: §26.6.42 defines neither vpiSize on an attribute nor nested
 * attribute iteration. §27.32's writable classes exclude attributes; a
 * refused put must preserve the value. An undecorated net is the legal
 * empty-iteration neighbor (§27.21: NULL, no error). Source nesting and
 * nonconstant values retain E0357 tests in ch02_lexical.
 *
 * Census: attrs(nonempty) uses 4+8*N checks, plus one per string; attrs(empty)
 * uses 2. Each p02_by_name uses 2. Remaining traversal, runtime, registration
 * and refusal checks are explicit below: 16 setup/start + 183 declarations
 * + 272 children + 28 generated nets + 27 assigns + 16 process/block
 * + 74 statements/expressions + 10 runtime + 4 refusals = 630.
 */
//! lrm 2.9
//! inherited IEEE 1364-2005 3.8
//! inherited IEEE 1364-2005 10.4.5
//! inherited IEEE 1364-2005 26.6.42
//! inherited-reject IEEE 1364-2005 26.6.42
//! inherited IEEE 1364-2005 27.14
//! inherited IEEE 1364-2005 27.16
//! inherited IEEE 1364-2005 27.21
//! inherited-reject IEEE 1364-2005 27.32
//! design attributes.v
//! stdout p02: b_26_6_42_attributes checks=630

#include "b_check.h"

typedef struct { const char *name; int definition, format, integer; double real; const char *str; } Attr;
#define AI(n, d, i) { n, d, vpiIntVal, i, 0.0, NULL }
#define AS(n, s) { n, 0, vpiStringVal, 0, 0.0, s }
#define AH(n, s) { n, 0, vpiHexStrVal, 0, 0.0, s }
#define AR(n, r) { n, 0, vpiRealVal, 0, r, NULL }

static vpiHandle attrs(vpiHandle owner, const Attr *want, unsigned count)
{
  vpiHandle it = vpi_iterate(vpiAttribute, owner), h, first = NULL;
  unsigned n = 0, seen = 0;
  if (!count) {
    CHECK(it == NULL, "undecorated owner has no attributes");
    expect_no_error("empty attribute iteration");
    return NULL;
  }
  CHECK(it != NULL, "owner has attributes");
  CHECK(vpi_get(vpiType, it) == vpiIterator, "attribute iterator type");
  CHECK(vpi_compare_objects(vpi_handle(vpiUse, it), owner), "iterator -> use owner");
  while ((h = vpi_scan(it)) != NULL) {
    const char *name = vpi_get_str(vpiName, h);
    unsigned j;
    s_vpi_value v;
    if (!first) first = h;
    CHECK(vpi_get(vpiType, h) == vpiAttribute, "attribute object type");
    CHECK(name != NULL, "attribute has a name");
    for (j = 0; j < count; ++j) if (strcmp(name, want[j].name) == 0) break;
    CHECK(j != count, "unexpected attribute %s", name);
    CHECK(!(seen & (1u << j)), "duplicate attribute object %s", name);
    seen |= 1u << j;
    CHECK(vpi_get(vpiDefAttribute, h) == want[j].definition, "attribute provenance %s", name);
    CHECK(vpi_compare_objects(vpi_handle(vpiParent, h), owner), "attribute parent %s", name);
    v.format = want[j].format;
    vpi_get_value(h, &v);
    if (v.format == vpiIntVal) CHECK(v.value.integer == want[j].integer, "%s value: got %d want %d", name, v.value.integer, want[j].integer);
    else if (v.format == vpiRealVal) CHECK(v.value.real == want[j].real, "%s real value", name);
    else CHECK_STR(v.value.str, want[j].str, "attribute string/bits");
    expect_no_error("attribute properties and value");
    ++n;
  }
  CHECK(n == count, "owner has %u attributes, expected %u", n, count);
  return first;
}

static void one(vpiHandle owner, const char *name)
{
  const Attr want[] = { AI(name, 0, 1) };
  (void)attrs(owner, want, 1);
}

static vpiHandle only(int type, vpiHandle owner)
{
  vpiHandle it = vpi_iterate(type, owner), h;
  CHECK(it != NULL, "relationship %d has an object", type);
  h = vpi_scan(it);
  CHECK(h != NULL && vpi_scan(it) == NULL, "relationship %d has exactly one object", type);
  return h;
}

static void child(const char *name, int width, const char *instance_attr, int instance_value, int connection)
{
  char path[100];
  vpiHandle m, port;
  const Attr module[] = { AI("child_attr", 1, 7), AI(instance_attr, 0, instance_value) };
  const Attr net[] = { AI("internal_attr", 0, width * 2) };
  const Attr fn[] = { AI("constant_call", 0, width * 2) };
  const Attr ports[] = { AI("port_attr", 0, width), AI("conn_attr", 0, connection) };
  snprintf(path, sizeof path, "b26_attributes.%s", name);
  m = p02_by_name(path);
  (void)attrs(m, module, 2);
  port = only(vpiPort, m);
  (void)attrs(port, ports, connection ? 2 : 1);
  snprintf(path, sizeof path, "b26_attributes.%s.localw", name);
  (void)attrs(p02_by_name(path), net, 1);
  snprintf(path, sizeof path, "b26_attributes.%s.tagged", name);
  (void)attrs(p02_by_name(path), fn, 1);
}

static PLI_INT32 walk(p_cb_data cb)
{
  const Attr module[] = { AI("mod_attr", 1, 1), AI("defaulted", 1, 1), AI("duplicate", 1, 9) };
  const Attr net[] = { AS("net_attr", "on") };
  const Attr marked[] = { AI("kind_attr", 0, 3), AH("wide_attr", "123456789abcdef0xz12"), AR("real_attr", 1.25) };
  const Attr operation[] = { AS("operation_attr", "sum") };
  vpiHandle top = p02_by_name("b26_attributes"), ma, proc, body, it, h;
  unsigned n;
  s_vpi_value v;
  (void)cb;
  ma = attrs(top, module, 3);
  (void)attrs(p02_by_name("b26_attributes.w"), net, 1);
  (void)attrs(p02_by_name("b26_attributes.w2"), net, 1);
  (void)attrs(p02_by_name("b26_attributes.plain"), NULL, 0);
  (void)attrs(p02_by_name("b26_attributes.r"), NULL, 0);
  (void)attrs(p02_by_name("b26_attributes.marked"), marked, 3);
  one(p02_by_name("b26_attributes.tagged"), "reg_attr");
  one(p02_by_name("b26_attributes.e"), "event_attr");
  one(p02_by_name("b26_attributes.e2"), "event_attr");
  {
    const Attr fn[] = { AI("function_attr", 0, 10) }, formal[] = { AI("formal_attr", 0, 20) }, local[] = { AI("local_attr", 0, 20) };
    (void)attrs(p02_by_name("b26_attributes.f"), fn, 1);
    (void)attrs(p02_by_name("b26_attributes.f.x"), formal, 1);
    (void)attrs(p02_by_name("b26_attributes.f.tmp"), local, 1);
  }
  child("a", 3, "instance_attr", 11, 10);
  child("b", 5, "instance_attr", 12, 11);
  child("c", 2, "pair_attr", 10, 0);
  child("d", 2, "pair_attr", 10, 0);
  {
    const Attr first[] = { AI("index_attr", 0, 5) }, second[] = { AI("index_attr", 0, 6) };
    (void)attrs(p02_by_name("b26_attributes.generated[0].gw"), first, 1);
    (void)attrs(p02_by_name("b26_attributes.generated[1].gw"), second, 1);
  }

  it = vpi_iterate(vpiContAssign, top);
  n = 0;
  while ((h = vpi_scan(it)) != NULL) {
    if (n < 2) one(h, "assign_attr"); else (void)attrs(h, NULL, 0);
    ++n;
  }
  CHECK(n == 3, "three continuous assignments");
  proc = only(vpiProcess, top);
  one(proc, "process_attr");
  body = vpi_handle(vpiStmt, proc);
  (void)attrs(body, NULL, 0);
  it = vpi_iterate(vpiStmt, body);
  n = 0;
  while ((h = vpi_scan(it)) != NULL) {
    if (n == 1) {
      one(h, "statement_attr");
      (void)attrs(vpi_handle(vpiRhs, h), operation, 1);
    } else {
      (void)attrs(h, NULL, 0);
      if (n == 2) one(vpi_handle(vpiRhs, h), "unary_attr");
      if (n == 3) one(vpi_handle(vpiRhs, h), "conditional_attr");
      if (n == 4) one(vpi_handle(vpiRhs, h), "call_attr");
    }
    ++n;
  }
  CHECK(n == 7, "seven statements in the initial block");
  v.format = vpiIntVal;
  vpi_get_value(p02_by_name("b26_attributes.marked"), &v);
  CHECK(v.value.integer == 9, "decorated HDL executed: f(8)=9");
  vpi_get_value(p02_by_name("b26_attributes.w"), &v);
  CHECK(v.value.integer == 1, "decorated continuous assignment w executed");
  vpi_get_value(p02_by_name("b26_attributes.w2"), &v);
  CHECK(v.value.integer == 1, "second decorated continuous assignment executed");
  expect_no_error("runtime values");
  CHECK(vpi_get(vpiSize, ma) == vpiUndefined, "attribute has no size property");
  expect_refusal("attribute size");
  CHECK(vpi_iterate(vpiAttribute, ma) == NULL, "attribute cannot own attributes");
  expect_refusal_saying("attribute iteration", "no relationship 105");
  p02_done("b_26_6_42_attributes");
  return 0;
}

static PLI_INT32 start(p_cb_data cb_data)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data cb;
  vpiHandle top = p02_by_name("b26_attributes"), it = vpi_iterate(vpiAttribute, top), h = vpi_scan(it);
  s_vpi_value value;
  (void)cb_data;
  {
    vpiHandle formal = p02_by_name("b26_attributes.a.twice.n");
    vpiHandle result = p02_by_name("b26_attributes.a.twice.twice");
    value.format = vpiVectorVal;
    vpi_get_value(formal, &value);
    CHECK(value.value.vector[0].bval == (PLI_INT32)-1, "constant attribute call preserved formal's initial x");
    expect_no_error("constant formal value");
    vpi_get_value(result, &value);
    CHECK(value.value.vector[0].bval == (PLI_INT32)-1, "constant attribute call preserved result's initial x");
    expect_no_error("constant result value");
  }
  CHECK(h != NULL, "module attribute for refused put");
  (void)vpi_free_object(it);
  value.format = vpiIntVal;
  value.value.integer = 99;
  CHECK(vpi_put_value(h, &value, NULL, vpiNoDelay) == NULL, "attribute put is refused");
  expect_refusal_saying("attribute put", "an attribute is a constant");
  vpi_get_value(h, &value);
  CHECK(value.value.integer == 1, "refused put preserved mod_attr");
  cb.reason = cbReadOnlySynch;
  cb.cb_rtn = walk;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadOnlySynch registration");
  return 0;
}

/* §26.2.4: startup only registers; design access waits for simulation. */
static void setup(void)
{
  static s_cb_data cb;
  cb.reason = cbStartOfSimulation;
  cb.cb_rtn = start;
  CHECK(vpi_register_cb(&cb) != NULL, "cbStartOfSimulation registration");
}
void (*vlog_startup_routines[])(void) = { setup, 0 };
