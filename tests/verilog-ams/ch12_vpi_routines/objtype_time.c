/* b7 vpiObjTypeVal: VAMS-2023 12.16, the format vpi_get_value() picks for
 * each kind of object, over ../ieee_pli/values.v at t=0.
 *
 * 12.16  "When the format field is vpiObjTypeVal, the routine shall fill in
 *        the value and change the format field based on the object type, as
 *        follows: For an integer, vpiIntVal For a real, vpiRealVal For a
 *        scalar, either vpiScalar or vpiStrength For a time variable,
 *        vpiTimeVal with vpiSimTime For a vector, vpiVectorVal".
 *
 * DERIVATION (values.v's initial block, read from cbReadOnlySynch at
 * t=0, after it ran):
 *   k     integer -7            -> vpiIntVal, -7
 *   rp    real 2.5              -> vpiRealVal, 2.5
 *   one   reg 1'b1              -> vpiScalarVal or vpiStrengthVal (either
 *                                  is the clause's)
 *   known reg [11:0] 12'ha71    -> vpiVectorVal, element 0 aval 0xa71, bval 0
 *   tv    time 64'd5000000000   -> vpiTimeVal, value.time->type vpiSimTime,
 *                                  5000000000 = 1 * 2^32 + 705032704, so
 *                                  high 1, low 705032704
 */

//! lrm 12.16:4
//! design ../../verilog/pli/values.v
//! stdout p02: b7_objtype_time checks=18

#include "../ch11_vpi/p02_check.h"

static PLI_INT32 ro0(p_cb_data d)
{
  s_vpi_value v;
  (void)d;

  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.k"), &v);
  CHECK(v.format == vpiIntVal && v.value.integer == -7, "12.16: an integer -> vpiIntVal -7, got format %d", (int)v.format);
  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.rp"), &v);
  CHECK(v.format == vpiRealVal && v.value.real == 2.5, "12.16: a real -> vpiRealVal 2.5, got format %d", (int)v.format);
  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.one"), &v);
  CHECK(v.format == vpiScalarVal || v.format == vpiStrengthVal, "12.16: a scalar -> vpiScalarVal or vpiStrengthVal, got format %d", (int)v.format);
  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.known"), &v);
  CHECK(v.format == vpiVectorVal && v.value.vector != NULL && v.value.vector[0].aval == 0xa71 && v.value.vector[0].bval == 0,
        "12.16: a vector -> vpiVectorVal 0xa71, got format %d", (int)v.format);
  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.tv"), &v);
  CHECK(v.format == vpiTimeVal, "12.16: a time variable as vpiObjTypeVal is not vpiTimeVal (format %d)", (int)v.format);
  CHECK(v.value.time != NULL && v.value.time->type == vpiSimTime && v.value.time->high == 1 && v.value.time->low == 705032704u,
        "12.16: tv is vpiSimTime 5000000000, high 1 low 705032704");

  p02_done("b7_objtype_time");
  return 0;
}

static PLI_INT32 eoc(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  (void)d;
  t.type = vpiSimTime;
  cb.reason = cbReadOnlySynch;
  cb.cb_rtn = ro0;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadOnlySynch(0) registration failed");
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
