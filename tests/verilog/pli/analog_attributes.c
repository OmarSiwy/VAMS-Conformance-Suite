/* AMS §2.9 plus inherited IEEE §26.6.42: attributes remain associated with
 * declarations and behavioral owners after analog hierarchy flattening.
 * Each child's R is 2 or 4: its port/process attrs equal R, variable attr
 * equals 2*R, and statement attr equals R+1. Instance attrs read BASE=10 in
 * the parent, hence 11/12. Only definition attributes have vpiDefAttribute.
 * The op analysis verifies the decorated device still sets bp=1.25 V and
 * bq=2.5 V. Those are exact binary64 values from the two voltage sources.
 * No invalid analog-specific attribute form exists beyond §2.9's source
 * restrictions; the digital companion tests the common VPI refusals.
 * Census: attr=7, only=2, by_name=2, child=51; main metadata=18, quantities
 * =10, registration=2, so 18+2*51+10+2=132.
 *! analysis op
 */
//! lrm 2.9
//! inherited IEEE 1364-2005 26.6.42
//! design analog_attributes.va
//! stdout p02: b_26_6_42_analog_attributes checks=132

#include "b_check.h"

static void attr(vpiHandle owner, const char *name, int wanted, int definition)
{
  vpiHandle it = vpi_iterate(vpiAttribute, owner), h, found = NULL;
  s_vpi_value v;
  CHECK(it != NULL, "owner has attribute %s", name);
  while ((h = vpi_scan(it)) != NULL) {
    const char *n = vpi_get_str(vpiName, h);
    if (n && strcmp(n, name) == 0) found = h;
  }
  CHECK(found != NULL, "attribute %s is present", name);
  CHECK(vpi_get(vpiType, found) == vpiAttribute, "attribute type");
  CHECK(vpi_get(vpiDefAttribute, found) == definition, "attribute provenance");
  CHECK(vpi_compare_objects(vpi_handle(vpiParent, found), owner), "attribute parent");
  v.format = vpiIntVal;
  vpi_get_value(found, &v);
  CHECK(v.value.integer == wanted, "%s: got %d want %d", name, v.value.integer, wanted);
  expect_no_error("analog attribute metadata");
}

static vpiHandle only(int type, vpiHandle owner)
{
  vpiHandle it = vpi_iterate(type, owner), h;
  CHECK(it != NULL, "relationship %d exists", type);
  h = vpi_scan(it);
  CHECK(h != NULL && vpi_scan(it) == NULL, "one object of type %d", type);
  return h;
}

static void child(const char *name, int r, int instance)
{
  char path[100];
  vpiHandle m, proc, body, it;
  snprintf(path, sizeof path, "b26_analog_attributes.%s", name);
  m = p02_by_name(path);
  attr(m, "child_attr", 7, 1);
  attr(m, "instance_attr", instance, 0);
  attr(only(vpiPort, m), "port_attr", r, 0);
  snprintf(path, sizeof path, "b26_analog_attributes.%s.saved", name);
  attr(p02_by_name(path), "variable_attr", 2*r, 0);
  proc = only(vpiProcess, m);
  attr(proc, "process_attr", r, 0);
  body = vpi_handle(vpiStmt, proc);
  it = vpi_iterate(vpiStmt, body);
  CHECK(it != NULL, "analog block has statements");
  attr(vpi_scan(it), "statement_attr", r+1, 0);
  (void)vpi_free_object(it);
}

static PLI_INT32 compiled(p_cb_data cb)
{
  (void)cb;
  attr(p02_by_name("b26_analog_attributes"), "module_attr", 3, 1);
  attr(p02_by_name("b26_analog_attributes.tagged"), "conversion_attr", 4, 0);
  child("a", 2, 11);
  child("b", 4, 12);
  return 0;
}

static PLI_INT32 done(p_cb_data cb)
{
  const char *paths[] = { "b26_analog_attributes.bp", "b26_analog_attributes.bq" };
  const double volts[] = { 1.25, 2.5 };
  unsigned i;
  (void)cb;
  for (i = 0; i < 2; ++i) {
    vpiHandle q = vpi_handle(vpiPotential, p02_by_name(paths[i]));
    s_vpi_analog_value v;
    CHECK(q != NULL, "branch potential exists");
    v.format = vpiRealVal;
    vpi_get_analog_value(q, &v);
    CHECK(v.real.real == volts[i] && v.imaginary.real == 0.0, "decorated device solved the source voltage");
    expect_no_error("solved branch value");
  }
  p02_done("b_26_6_42_analog_attributes");
  return 0;
}

static void setup(void)
{
  static s_cb_data a, b;
  a.reason = cbEndOfCompile; a.cb_rtn = compiled;
  b.reason = cbEndOfSimulation; b.cb_rtn = done;
  CHECK(vpi_register_cb(&a) != NULL, "compile callback");
  CHECK(vpi_register_cb(&b) != NULL, "end callback");
}
void (*vlog_startup_routines[])(void) = { setup, 0 };
