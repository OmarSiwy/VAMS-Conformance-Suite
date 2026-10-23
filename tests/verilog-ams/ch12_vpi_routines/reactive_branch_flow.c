/* P03 — VAMS-2023 12.10: the flow of a capacitor's branch in a transient,
 * alone on its node pair and sharing it with another instance's.
 *
 *   12.10   vpi_get_analog_value() "shall retrieve the simulation value of
 *           VPI analog vpiFlow or vpiPotential (node or branch) quantity
 *           objects".
 *   5.6.1.2 a `ddt` term is the reactive part of a contribution; the
 *           branch's flow includes its time derivative.
 *   5.4.2   an unnamed branch is created in the module containing the
 *           contribution, so c1 and c2 each own a (b, gnd) branch, and each
 *           branch's flow is its own instance's contribution.
 *
 * DERIVATION. cap_ramp.va holds V(a, gnd) = V(b, gnd) = 1000 t (ideal
 * sources), with I(p, n) <+ c ddt(V(p, n)) in each capacitor: c0 (1 uF)
 * across a, c1 (1 uF) and c2 (3 uF) across b. Each branch's flow is
 * c dV/dt = c * 1000 at every t > 0:
 *
 *     c0: 1e-3 A    c1: 1e-3 A    c2: 3e-3 A
 *
 * The host integrates by backward Euler (src/vpi/analog.zig), whose
 * difference quotient of a charge linear in t is exact, so these are the
 * values at every accepted point after t = 0, to rounding (1e-12 here). At
 * acbFinalStep t = 5 ms, so V(a, gnd) = 5.
 *
 * WHAT IT CATCHES. A host that drops a flow's reactive half reads 0 for all
 * three; one that reports the summed (b, gnd) row for an instance reads 4e-3
 * for c1 and for c2.
 *
 * stdout: "p03-13: v=5 i0=0.001 i1=0.001 i2=0.003".
 *
 *! design   cap_ramp.va
 *! analysis tran 0 5m
 */

//! lrm 12.10
//! lrm 12.10:1
//! design cap_ramp.va
//! stdout p03-13: v=5 i0=0.001 i1=0.001 i2=0.003

#include "p03_vpi_analog.h"

static PLI_INT32 on_final(p_cb_data cb)
{
  double v, i0, i1, i2;
  (void)cb;

  v  = p03_real_of(p03_quantity("p03_cap_ramp.c0", vpiPotential), NULL);
  i0 = p03_real_of(p03_quantity("p03_cap_ramp.c0", vpiFlow), NULL);
  i1 = p03_real_of(p03_quantity("p03_cap_ramp.c1", vpiFlow), NULL);
  i2 = p03_real_of(p03_quantity("p03_cap_ramp.c2", vpiFlow), NULL);
  P03_NEAR(v,  5.0,  1e-12, "V(a, gnd) = 1000 t at t = 5 ms");
  P03_NEAR(i0, 1e-3, 1e-12, "c0's flow: 1 uF * 1000 V/s");
  P03_NEAR(i1, 1e-3, 1e-12, "c1's own flow, not the (b, gnd) row's 4 mA");
  P03_NEAR(i2, 3e-3, 1e-12, "c2's own flow: 3 uF * 1000 V/s");

  printf("p03-13: v=%g i0=%g i1=%g i2=%g\n", v, i0, i1, i2);
  fflush(stdout);
  return 0;
}

static void p03_13_after_compile(void)
{
  static s_cb_data fin_cb;
  fin_cb.reason = acbFinalStep;
  fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_13_startup(void)
{
  p03_defer(p03_13_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_13_startup, 0 };
