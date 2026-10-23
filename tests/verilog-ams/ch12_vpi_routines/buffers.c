/* b7 buffers: the storage rules of VAMS-2023 12.4, 12.12 and 12.25, over
 * digital.v at t=1 (after time 0, so every reg holds its value).
 *
 * 12.4   "The iterator object shall automatically be freed when vpi_scan()
 *        returns NULL either because it has completed an object traversal or
 *        encountered an error condition. If neither of these conditions occur
 *        (which can happen if the code breaks out of an iteration loop before
 *        it has scanned every object), vpi_free_object() needs to be called to
 *        free any memory allocated for the iterator. ... The routine shall
 *        return TRUE on success and FALSE on failure."
 * 12.35  "Once vpi_scan() returns NULL, the iterator handle is no longer valid
 *        and can not be used again."
 * 12.12  "The string shall be placed in a temporary buffer which shall be used
 *        by every call to this routine. ... A different string buffer shall be
 *        used for string values returned through the s_vpi_value structure."
 * 12.16  "The buffer this routine uses for string values shall be different
 *        from the buffer which vpi_get_str() shall use."
 * 12.25  "This routine shall overwrite the returned value on subsequent
 *        calls."
 *
 * DERIVATION.
 *   12.4  b7_digital has three regs. An iterator scanned to its NULL is
 *         already freed, so freeing it again cannot succeed: FALSE (0). An
 *         iterator scanned once and abandoned still holds its memory, and
 *         vpi_free_object() frees it: TRUE (1), with no error.
 *   12.12 p = vpi_get_str(vpiName, alpha) reads "alpha". The next call,
 *         for beta, uses THE SAME buffer, so p, unchanged, now reads "beta".
 *         And the two buffers are two: alpha as vpiBinStrVal ("00000001",
 *         alpha = 8'h01) survives a vpi_get_str() call, and a vpi_get_str()
 *         result ("alpha") survives a vpi_get_value() call (beta as
 *         vpiBinStrVal, "00000010").
 *   12.16 One buffer holds the vpi_get_value() strings too: alpha's
 *         "00000001" reads "00000010" after beta's call.
 *   12.25 Two files opened; their names, copied, differ. p = vpi_mcd_name(a)
 *         reads a's name; after vpi_mcd_name(b), p reads b's. The names
 *         themselves are not pinned: the clause fixes the overwrite, not the
 *         spelling. Both channels close cleanly (0).
 */

//! lrm 12.4
//! lrm 12.12
//! lrm 12.16
//! lrm 12.25
//! lrm 12.4:3
//! lrm 12.4:4
//! lrm 12.12:2
//! lrm 12.12:3
//! lrm 12.16:1001
//! lrm 12.25:3
//! design digital.v
//! stdout p02: b7_buffers checks=38

#include "../ch11_vpi/p02_check.h"

static PLI_INT32 at1(p_cb_data cb)
{
  static char na[256], nb[256];
  vpiHandle top, alpha, beta, itr;
  s_vpi_value v;
  PLI_BYTE8 *p, *q, *s;
  PLI_UINT32 ma, mb;
  int n;
  (void)cb;

  top = p02_by_name("b7_digital");
  alpha = p02_by_name("b7_digital.alpha");
  beta = p02_by_name("b7_digital.beta");

  /* 12.4 */
  itr = vpi_iterate(vpiReg, top);
  CHECK(itr != NULL, "b7_digital has regs");
  n = 0;
  while (vpi_scan(itr) != NULL) n++;
  CHECK(n == 3, "b7_digital has three regs, got %d", n);
  CHECK(vpi_free_object(itr) == 0, "12.4: an iterator scanned to NULL was already freed, so freeing it again must fail");
  itr = vpi_iterate(vpiReg, top);
  CHECK(itr != NULL, "b7_digital has regs");
  CHECK(vpi_scan(itr) != NULL, "a first reg");
  CHECK(vpi_free_object(itr) == 1, "12.4: an abandoned iterator frees with TRUE");
  expect_no_error("vpi_free_object(abandoned iterator)");

  /* 12.12, one buffer for vpi_get_str() */
  p = vpi_get_str(vpiName, alpha);
  CHECK_STR(p, "alpha", "vpi_get_str(vpiName, alpha)");
  q = vpi_get_str(vpiName, beta);
  CHECK_STR(q, "beta", "vpi_get_str(vpiName, beta)");
  CHECK(strcmp(p, "beta") == 0, "12.12: every call uses one buffer, so the first result now reads `beta`, got `%s`", p);

  /* 12.12, a different one for s_vpi_value */
  v.format = vpiBinStrVal;
  vpi_get_value(alpha, &v);
  s = v.value.str;
  CHECK_STR(s, "00000001", "alpha as vpiBinStrVal");
  p = vpi_get_str(vpiName, beta);
  CHECK_STR(p, "beta", "vpi_get_str(vpiName, beta)");
  CHECK(strcmp(s, "00000001") == 0, "12.12: vpi_get_str() overwrote vpi_get_value()'s string, now `%s`", s);
  p = vpi_get_str(vpiName, alpha);
  CHECK_STR(p, "alpha", "vpi_get_str(vpiName, alpha)");
  v.format = vpiBinStrVal;
  vpi_get_value(beta, &v);
  CHECK_STR(v.value.str, "00000010", "beta as vpiBinStrVal");
  CHECK(strcmp(s, "00000010") == 0, "12.16: every vpi_get_value() string call uses one buffer, so the first result now reads `00000010`, got `%s`", s);
  CHECK(strcmp(p, "alpha") == 0, "12.12: vpi_get_value() overwrote vpi_get_str()'s string, now `%s`", p);

  /* 12.25 */
  ma = vpi_mcd_open((PLI_BYTE8 *)"b7_buffers_a.txt");
  mb = vpi_mcd_open((PLI_BYTE8 *)"b7_buffers_b.txt");
  CHECK(ma != 0 && mb != 0 && ma != mb, "two files open on two channels (0x%x, 0x%x)", (unsigned)ma, (unsigned)mb);
  p = vpi_mcd_name(ma);
  CHECK(p != NULL, "vpi_mcd_name(a)");
  snprintf(na, sizeof na, "%s", p);
  p = vpi_mcd_name(mb);
  CHECK(p != NULL, "vpi_mcd_name(b)");
  snprintf(nb, sizeof nb, "%s", p);
  CHECK(strcmp(na, nb) != 0, "two files, two names (`%s`, `%s`)", na, nb);
  p = vpi_mcd_name(ma);
  CHECK(p != NULL && strcmp(p, na) == 0, "vpi_mcd_name(a) again reads a's name");
  (void)vpi_mcd_name(mb);
  CHECK(strcmp(p, nb) == 0, "12.25: vpi_mcd_name(b) overwrote the value a's call returned, so it reads `%s`, got `%s`", nb, p);
  CHECK(vpi_mcd_close(ma | mb) == 0, "both channels close");

  p02_done("b7_buffers");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  (void)d;
  t.type = vpiSimTime;
  t.high = 0;
  t.low = 1;
  cb.reason = cbAfterDelay;
  cb.cb_rtn = at1;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbAfterDelay(1) registration failed");
  return 0;
}

static void setup(void)
{
  static s_cb_data cb;
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = eoc;
  CHECK(vpi_register_cb(&cb) != NULL, "cbEndOfCompile registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
