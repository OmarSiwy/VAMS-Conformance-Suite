/* b7 sequential UDP put: VAMS-2023 12.30, over udp.v.
 *
 * 12.30  "The routine can be applied to nets, regs, variables, memory words,
 *        system function calls, sequential UDPs, and schedule events."
 *        "vpiNoDelay The object shall be set to the passed value with no
 *        delay. Argument time_p shall be ignored and can be set to NULL."
 *        "Sequential UDPs shall be set to the indicated value with no delay
 *        regardless of any delay on the primitive instance."
 *
 * DERIVATION (udp.v's header): the latch instance `lat`, declared #5, has
 * output q = 0 from t=5 on and nothing in the design moves it (en is 0, the
 * `? 0 : ? : -` row holds). At t=10 the application puts vpi1 on `lat` with
 * vpiNoDelay. "No delay regardless of any delay on the primitive instance":
 * the output is 1 at t=10, so the net q reads vpi1 in t=10's cbReadOnlySynch.
 * Had the instance's #5 applied, q would read 0 until t=15.
 */

//! lrm 12.30:16
//! design udp.v
//! stdout p02: b7_seq_udp checks=11

#include "../ch11_vpi/p02_check.h"

static vpiHandle lat, q;

static PLI_INT32 ro10(p_cb_data d)
{
  s_vpi_value v;
  (void)d;
  v.format = vpiScalarVal;
  vpi_get_value(q, &v);
  CHECK(v.value.scalar == vpi1, "12.30: a sequential UDP put with vpiNoDelay sets its output at t=10 regardless of its #5, got q = %d",
        (int)v.value.scalar);
  p02_done("b7_seq_udp");
  return 0;
}

static PLI_INT32 at10(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  s_vpi_value v;
  (void)d;
  v.format = vpiScalarVal;
  v.value.scalar = vpi1;
  vpi_put_value(lat, &v, NULL, vpiNoDelay);
  expect_no_error("vpi_put_value(sequential UDP, vpiNoDelay)");
  t.type = vpiSimTime;
  cb.reason = cbReadOnlySynch;
  cb.cb_rtn = ro10;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadOnlySynch(0) at t=10 registration failed");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  vpiHandle itr;
  (void)d;
  itr = vpi_iterate(vpiPrimitive, p02_by_name("b7_udp"));
  CHECK(itr != NULL && (lat = vpi_scan(itr)) != NULL, "b7_udp has a primitive");
  vpi_free_object(itr);
  CHECK(vpi_get(vpiType, lat) == vpiUdp && vpi_get(vpiPrimType, lat) == vpiSeqPrim, "lat is a sequential UDP instance");
  q = p02_by_name("b7_udp.q");
  t.type = vpiSimTime;
  t.low = 10;
  cb.reason = cbAfterDelay;
  cb.cb_rtn = at10;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbAfterDelay(10) registration failed");
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
