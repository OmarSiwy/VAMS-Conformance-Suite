/* b7 sysfunctype: VAMS-2023 12.32.1, the type of value an analog system
 * function returns is the one it was registered with.
 *
 * 12.32.1 "The sysfunctype field of the s_vpi_analog_systf_data structure
 *         shall define the type of value which a system function shall
 *         return. The sysfunctype field shall be an integer constant of
 *         vpiIntFunc of vpiRealFunc."
 * 12.30   a put on "system function calls" sets the value the call returns;
 *         vpiIntVal and vpiRealVal are Table 12-4 formats.
 * 4.2.4   "Integer division truncates any fractional part toward zero"; a
 *         real operand makes the division real.
 *
 * DERIVATION. functype.va calls $b7_ifn (registered vpiIntFunc, calltf
 * puts vpiIntVal 3) and $b7_rfn (vpiRealFunc, calltf puts vpiRealVal 2.5),
 * each from one site, each divided by the integer literal 2:
 *     V(a) = $b7_ifn($abstime) / 2 = 3 / 2, integer / integer = 1
 *     V(b) = $b7_rfn($abstime) / 2 = 2.5 / 2, real / integer  = 1.25
 * The division is what tells the return TYPE from the return VALUE: an
 * integer 3 and a real 3.0 differ only under integer arithmetic (1 against
 * 1.5). The sources are ideal, so each node holds its value to the solver's
 * last bits: 1e-12 absolute (at most 1e-12 relative). The analysis is this
 * banner's `tran 0 1m 1e-4`; values are read at acbFinalStep through 12.10.
 * The branches are matched to wants by their node, vpiPosNode's name, so
 * the branch order does not matter.
 *
 *! design   functype.va
 *! analysis tran 0 1m 1e-4
 */

//! lrm 12.32.1:3
//! design functype.va
//! stdout b7-functype: a=1 b=1.25

#include <string.h>
#include "p03_vpi_analog.h"

static int calls_i, calls_r;

static PLI_INT32 ifn_calltf(p_cb_data cb)
{
  s_vpi_value v;
  (void)cb;
  calls_i++;
  v.format = vpiIntVal;
  v.value.integer = 3;
  vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
  if (vpi_chk_error(NULL) != 0) P03_FAIL("12.32.1: a vpiIntVal put onto the vpiIntFunc call $b7_ifn was refused");
  return 0;
}

static PLI_INT32 rfn_calltf(p_cb_data cb)
{
  s_vpi_value v;
  (void)cb;
  calls_r++;
  v.format = vpiRealVal;
  v.value.real = 2.5;
  vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
  p03_no_error("vpi_put_value(vpiRealVal 2.5) onto the vpiRealFunc call $b7_rfn");
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  vpiHandle top, itr, br, node;
  const char *name;
  int seen = 0;
  (void)cb;
  P03_CHECK(calls_i > 0 && calls_r > 0, "12.32.1: calltf ran %d and %d times", calls_i, calls_r);
  top = vpi_handle_by_name((PLI_BYTE8 *)"b7_functype", NULL);
  itr = vpi_iterate(vpiBranchObj, top);
  P03_CHECK(itr != NULL, "11.6.6: the top module has no branches");
  while ((br = vpi_scan(itr)) != NULL) {
    node = vpi_handle(vpiPosNode, br);
    P03_CHECK(node != NULL, "11.6.6: a branch has no positive node");
    name = vpi_get_str(vpiName, node);
    P03_CHECK(name != NULL, "11.6.5: a node has no name");
    if (strcmp(name, "a") == 0) {
      P03_NEAR(p03_real_of(vpi_handle(vpiPotential, br), NULL), 1.0, 1e-12,
               "12.32.1: V(a) = $b7_ifn($abstime) / 2, integer division of an integer return, 1");
      seen |= 1;
    } else if (strcmp(name, "b") == 0) {
      P03_NEAR(p03_real_of(vpi_handle(vpiPotential, br), NULL), 1.25, 1e-12,
               "12.32.1: V(b) = $b7_rfn($abstime) / 2, real division of a real return, 1.25");
      seen |= 2;
    }
  }
  P03_CHECK(seen == 3, "11.6.6: the branches to a and b, got mask %d", seen);
  printf("b7-functype: a=1 b=1.25\n");
  fflush(stdout);
  return 0;
}

static void b7_after_compile(void)
{
  static s_cb_data fin_cb;
  fin_cb.reason = acbFinalStep;
  fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the callbacks
 * above register at cbEndOfCompile (p03_defer, VD-044). */
static void b7_startup(void)
{
  static s_vpi_analog_systf_data ifn, rfn;

  ifn.type = vpiAnalogSysFunc;
  ifn.sysfunctype = vpiIntFunc;
  ifn.tfname = (PLI_BYTE8 *)"$b7_ifn";
  ifn.calltf = ifn_calltf;
  P03_CHECK(vpi_register_analog_systf(&ifn) != NULL, "12.32: registering $b7_ifn failed");

  rfn.type = vpiAnalogSysFunc;
  rfn.sysfunctype = vpiRealFunc;
  rfn.tfname = (PLI_BYTE8 *)"$b7_rfn";
  rfn.calltf = rfn_calltf;
  P03_CHECK(vpi_register_analog_systf(&rfn) != NULL, "12.32: registering $b7_rfn failed");

  p03_defer(b7_after_compile);
}

void (*vlog_startup_routines[])(void) = { b7_startup, 0 };
