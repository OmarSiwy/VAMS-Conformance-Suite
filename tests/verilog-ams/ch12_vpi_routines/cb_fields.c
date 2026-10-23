/* b7 callback fields: what a simulation-event callback is handed, VAMS-2023
 * 12.16 and 12.31.1, over digital.v.
 *
 * 12.16    "When a value change callback occurs for a value type of
 *          vpiVectorVal, the system shall create the associated memory (an
 *          array of s_vpi_vecval structures) and free the memory upon the
 *          return of the callback." "For vectors, the p_vpi_vecval field
 *          shall point to an array of s_vpi_vecval structures. The size of
 *          this array shall be determined by the size of the vector, where
 *          array_size = ((vector_size-1)/32 + 1). The lsb of the vector shall
 *          be represented by the lsb of the 0-indexed element". Figure 12-10:
 *          "ab: 00=0, 10=1, 11=X, 01=Z".
 * 12.31.1  "cb_data_p->value->format ... For cbStmt callbacks, value
 *          information is not passed to the callback routine, so this field
 *          shall be ignored."
 *
 * DERIVATION.
 *   cbValueChange on the 40-bit w40, registered at t=1 with format
 *   vpiVectorVal and NO array of its own (value.vector is NULL: the memory
 *   is the system's to create). (40-1)/32 + 1 = 2 elements. After t=1 w40
 *   changes twice:
 *     t=2  40'h12_3456_789A: [0] aval 0x3456789A bval 0;
 *          [1] low byte aval 0x12, bval 0
 *     t=4  40'hA5_zzzz_xxxx: bits 31..16 z (a 0, b 1), bits 15..0 x (a 1,
 *          b 1): [0] aval 0x0000FFFF, bval 0xFFFFFFFF;
 *          [1] low byte aval 0xA5, bval 0
 *   Only the low byte of element 1 holds vector bits; the rest is not
 *   asserted. So two callbacks, each with a non-NULL array holding those
 *   words.
 *   cbStmt on `alpha = 8'h01`, the first statement of the named block `seq`,
 *   registered with value->format vpiIntVal: the format is ignored, so the
 *   registration succeeds with no error; the statement runs once (t=0), so
 *   one callback, and it carries no value (value NULL, or a structure that
 *   says vpiSuppressVal: either way no value information is passed).
 *   A second cbValueChange on w40, registered with value->format
 *   vpiSuppressVal, says the value is not needed: it fires for both changes
 *   too, and each callback is handed no value.
 */

//! lrm 12.16
//! lrm 12.31.1
//! lrm 12.16:12
//! lrm 12.31.1:4
//! lrm 12.31.1:1001
//! design digital.v
//! stdout p02: b7_cb_fields checks=35

#include "../ch11_vpi/p02_check.h"

static vpiHandle first_stmt;
static int stmt_hits, vec_hits, supp_hits;

static PLI_UINT32 now(void)
{
  s_vpi_time t;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  return t.low;
}

static PLI_INT32 on_stmt(p_cb_data d)
{
  stmt_hits++;
  CHECK(d->reason == cbStmt && vpi_compare_objects(d->obj, first_stmt), "a cbStmt on alpha = 8'h01");
  CHECK(d->value == NULL || d->value->format == vpiSuppressVal,
        "12.31.1: a cbStmt callback is passed no value information, got format %d", d->value ? (int)d->value->format : 0);
  CHECK(now() == 0, "alpha = 8'h01 runs at t=0, got %u", (unsigned)now());
  return 0;
}

static PLI_INT32 on_vec(p_cb_data d)
{
  static const PLI_UINT32 when[2] = { 2, 4 };
  static const PLI_UINT32 a0[2] = { 0x3456789Au, 0x0000FFFFu };
  static const PLI_UINT32 b0[2] = { 0x00000000u, 0xFFFFFFFFu };
  static const PLI_UINT32 a1[2] = { 0x12u, 0xA5u };
  s_vpi_vecval *vec;
  int i = vec_hits++;
  CHECK(i < 2, "w40 changes twice after t=1, a callback #%d at t=%u", i + 1, (unsigned)now());
  CHECK(d->value != NULL && d->value->format == vpiVectorVal, "the value as registered, vpiVectorVal");
  vec = d->value->value.vector;
  CHECK(vec != NULL, "12.16: the system creates the s_vpi_vecval array for a vpiVectorVal value change callback");
  CHECK(d->time != NULL && d->time->type == vpiSimTime && d->time->low == when[i],
        "change %d is at t=%u", i + 1, (unsigned)when[i]);
  CHECK((PLI_UINT32)vec[0].aval == a0[i] && (PLI_UINT32)vec[0].bval == b0[i],
        "12.16: change %d, element 0 is aval 0x%08x bval 0x%08x, want 0x%08x 0x%08x", i + 1,
        (unsigned)vec[0].aval, (unsigned)vec[0].bval, (unsigned)a0[i], (unsigned)b0[i]);
  CHECK(((PLI_UINT32)vec[1].aval & 0xFFu) == a1[i] && ((PLI_UINT32)vec[1].bval & 0xFFu) == 0,
        "12.16: change %d, element 1 holds bits 39..32: aval 0x%02x bval 0x%02x, want 0x%02x 0", i + 1,
        (unsigned)vec[1].aval & 0xFFu, (unsigned)vec[1].bval & 0xFFu, (unsigned)a1[i]);
  return 0;
}

static PLI_INT32 on_supp(p_cb_data d)
{
  supp_hits++;
  CHECK(d->reason == cbValueChange && d->value == NULL,
        "12.31.1: with value->format vpiSuppressVal no value information is passed, got %s",
        d->value ? "a value" : "none");
  return 0;
}

static PLI_INT32 at1(p_cb_data d)
{
  static s_vpi_time t;
  static s_vpi_value v, none;
  static s_cb_data cb, supp;
  (void)d;
  t.type = vpiSimTime;
  v.format = vpiVectorVal;
  v.value.vector = NULL;
  cb.reason = cbValueChange;
  cb.cb_rtn = on_vec;
  cb.obj = p02_by_name("b7_digital.w40");
  cb.time = &t;
  cb.value = &v;
  CHECK(vpi_register_cb(&cb) != NULL, "cbValueChange on w40 registration failed");
  expect_no_error("vpi_register_cb(cbValueChange, vpiVectorVal)");

  none.format = vpiSuppressVal;
  supp.reason = cbValueChange;
  supp.cb_rtn = on_supp;
  supp.obj = cb.obj;
  supp.time = &t;
  supp.value = &none;
  CHECK(vpi_register_cb(&supp) != NULL, "12.31.1: cbValueChange with value->format vpiSuppressVal registration failed");
  expect_no_error("vpi_register_cb(cbValueChange, vpiSuppressVal)");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_vpi_time ts, t1;
  static s_vpi_value sv;
  static s_cb_data stmt_cb, delay_cb;
  vpiHandle itr;
  (void)d;

  itr = vpi_iterate(vpiStmt, p02_by_name("b7_digital.seq"));
  CHECK(itr != NULL && (first_stmt = vpi_scan(itr)) != NULL, "seq has statements");
  vpi_free_object(itr);
  CHECK(vpi_get(vpiType, first_stmt) == vpiAssignment &&
        strcmp(vpi_get_str(vpiName, vpi_handle(vpiLhs, first_stmt)), "alpha") == 0,
        "seq's first statement is alpha = 8'h01");

  ts.type = vpiSimTime;
  sv.format = vpiIntVal;
  stmt_cb.reason = cbStmt;
  stmt_cb.cb_rtn = on_stmt;
  stmt_cb.obj = first_stmt;
  stmt_cb.time = &ts;
  stmt_cb.value = &sv;
  CHECK(vpi_register_cb(&stmt_cb) != NULL, "12.31.1: a cbStmt whose value->format is vpiIntVal was refused; the field is ignored");
  expect_no_error("vpi_register_cb(cbStmt, value->format vpiIntVal)");

  t1.type = vpiSimTime;
  t1.low = 1;
  delay_cb.reason = cbAfterDelay;
  delay_cb.cb_rtn = at1;
  delay_cb.time = &t1;
  CHECK(vpi_register_cb(&delay_cb) != NULL, "cbAfterDelay(1) registration failed");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(stmt_hits == 1, "alpha = 8'h01 runs once, %d cbStmt callbacks", stmt_hits);
  CHECK(vec_hits == 2, "w40 changes twice after t=1, %d callbacks", vec_hits);
  CHECK(supp_hits == 2, "the vpiSuppressVal cbValueChange also fires twice, %d callbacks", supp_hits);
  p02_done("b7_cb_fields");
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
