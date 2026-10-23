/* b 20.4 timing checks — a timing check name cannot be overridden, over
 * ch11_vpi/specify.v (p06_cell holds `$setup(d, posedge clk, 5, notif);`
 * and `$width(posedge clk, 10);` in its specify block; u is its instance).
 *
 * IEEE 1364-2005 §20.4, p. 367: "If a user-provided PLI application is
 * associated with the same name as a built-in system task/function (using
 * the PLI mechanism), the user-provided C application shall override the
 * built-in system task/function, replacing its functionality with that of
 * the user-provided C application." ... "Verilog timing checks, such as
 * $setup, are not system tasks and cannot be overridden."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * The application registers user system tasks named $setup and $width, each
 * with a compiletf and a calltf that count. Whether the product accepts the
 * two registrations or refuses them, neither name in the specify block is a
 * system task call, so:
 *   - no compiletf runs at the build (read at cbEndOfCompile): 0;
 *   - no calltf runs in the whole simulation (read at cbEndOfSimulation): 0;
 *   - u still holds its two timing checks: u ->> tchk yields two, of
 *     vpiTchkType vpiSetup and vpiWidth.
 */

//! inherited-reject IEEE 1364-2005 20.4
//! design ../../verilog-ams/ch11_vpi/specify.v
//! stdout p02: b_20_4_timing_checks checks=7

#include "b_check.h"

static int compiles = 0, calls = 0;

static PLI_INT32 ct(PLI_BYTE8 *u) { (void)u; compiles++; return 0; }
static PLI_INT32 cl(PLI_BYTE8 *u) { (void)u; calls++; return 0; }

static PLI_INT32 eoc(p_cb_data d)
{
  vpiHandle itr, t;
  int setup = 0, width = 0, n = 0;
  (void)d;
  CHECK(compiles == 0, "20.4: no compiletf for a timing check, got %d", compiles);
  itr = vpi_iterate(vpiTchk, p02_by_name("p06_top.u"));
  CHECK(itr != NULL, "u holds timing checks");
  while ((t = vpi_scan(itr)) != NULL) {
    n++;
    if (vpi_get(vpiTchkType, t) == vpiSetup) setup++;
    if (vpi_get(vpiTchkType, t) == vpiWidth) width++;
  }
  CHECK(n == 2 && setup == 1 && width == 1, "20.4: $setup and $width are still timing checks");
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  CHECK(calls == 0, "20.4: no calltf for a timing check, got %d", calls);
  p02_done("b_20_4_timing_checks");
  return 0;
}

static void startup(void)
{
  static s_vpi_systf_data s = { vpiSysTask, 0, "$setup", cl, ct, NULL, NULL };
  static s_vpi_systf_data w = { vpiSysTask, 0, "$width", cl, ct, NULL, NULL };
  static s_cb_data a, b;
  (void)vpi_register_systf(&s);
  (void)vpi_register_systf(&w);
  a.reason = cbEndOfCompile;
  a.cb_rtn = eoc;
  b.reason = cbEndOfSimulation;
  b.cb_rtn = eos;
  CHECK(vpi_register_cb(&a) != NULL && vpi_register_cb(&b) != NULL, "two action callbacks");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
