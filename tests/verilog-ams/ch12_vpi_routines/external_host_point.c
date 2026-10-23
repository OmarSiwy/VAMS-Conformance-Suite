/* P03 — VAMS-2023 12.7, 12.8, 12.9 and 12.32 under a host that solves the
 * circuit itself and binds VerA only to run calltf (VerA #83, ESPice's
 * shape), and 12.10 refusing a value that host never handed over.
 *
 *   12.7  vpi_get_analog_delta() "returns the elapsed time between the latest
 *         converged and accepted solution and the solution being calculated.
 *         The function shall return zero (0) during DC or the time zero
 *         transient solution."
 *   12.8  vpi_get_analog_freq() is "the current frequency used in the
 *         small-signal analysis ... zero (0) during DC or transient analysis."
 *   12.9  vpi_get_analog_time() is "the time of the solution attempted ...
 *         zero (0) during DC or the time zero transient solution."
 *   12.32 calltf runs "each time the system task or function is invoked".
 *   12.10 vpi_get_analog_value() "shall retrieve the simulation value" of a
 *         quantity.
 *
 * THE HOST. The banner's `*! external` lines make tests/fixtures/ch11_vpi/vpi_host.zig attach
 * the built library's call table with no solution in it (n_u = n_rows =
 * n_shares = 0), then, per line, call analog_run.setPoint(kind, t, dt, freq)
 * and run every call's calltf once. Nothing is solved in this process, so
 * every value below is a literal from those lines:
 *
 *   tran 2m 1u 0    a transient point:      t = 0.002, dt = 1e-06, f = 0
 *   ac   2m 1u 1k   a small-signal point:   t = 0, dt = 0 (12.9, 12.7: the
 *                   sweep stands on a DC operating point; the host's t and dt
 *                   are not reported), f = 1000
 *   op   0  0  0    a DC point:             t = 0, dt = 0, f = 0
 *
 * vpi_get_time(vpiAnalogTime) is 12.9's value (12.15), so it equals
 * vpi_get_analog_time() at each point.
 *
 * THE REFUSAL. V(b, gnd) is no argument of $p03_env (its argument is
 * V(a, gnd)), so its value would come from the solution, and the library
 * holds none: vpi_get_analog_value() must set vpiError with code NOSOLUTION,
 * not read past the empty solution. The legal neighbour is p03_93, the same
 * design and quantity under VerA's own walk, which reads V(b) = 1.
 *
 *! design   env_probe.va
 *! external tran 2m 1u 0
 *! external ac 2m 1u 1k
 *! external op 0 0 0
 */

//! lrm 12.7
//! lrm 12.8
//! lrm 12.9
//! lrm 12.32
//! lrm-reject 12.10
//! design env_probe.va
//! stdout p03-14: point=1 t=0.002 dt=1e-06 f=0 v_b=NOSOLUTION
//! stdout p03-14: point=2 t=0 dt=0 f=1000 v_b=NOSOLUTION
//! stdout p03-14: point=3 t=0 dt=0 f=0 v_b=NOSOLUTION

#include <string.h>
#include "p03_vpi_analog.h"

static int points;

static PLI_INT32 env_calltf(p_cb_data cb)
{
  s_vpi_time t;
  s_vpi_analog_value av;
  s_vpi_error_info info;
  vpiHandle top, itr, br, q = NULL;
  double at, dt, f;
  (void)cb;
  points++;
  at = vpi_get_analog_time();
  dt = vpi_get_analog_delta();
  f = vpi_get_analog_freq();
  p03_no_error("vpi_get_analog_time/delta/freq");
  t.type = vpiAnalogTime;
  vpi_get_time(NULL, &t);
  p03_no_error("vpi_get_time(vpiAnalogTime)");
  P03_CHECK(t.real == at, "12.15: vpiAnalogTime %.17g is not vpi_get_analog_time() %.17g", t.real, at);

  /* top's branches, in contribution order: (a, gnd), then (b, gnd). */
  top = vpi_handle_by_name((PLI_BYTE8 *)"p03_env_probe", NULL);
  itr = vpi_iterate(vpiBranchObj, top);
  P03_CHECK(itr != NULL, "11.6.6: the top module has no branches");
  while ((br = vpi_scan(itr)) != NULL) q = vpi_handle(vpiPotential, br);
  P03_CHECK(q != NULL, "11.6.6: no potential quantity on (b, gnd)");
  av.format = vpiRealVal;
  vpi_get_analog_value(q, &av);
  P03_CHECK(vpi_chk_error(&info) == vpiError, "12.10: V(b) read with no solution attached set no error");
  P03_CHECK(info.code && strcmp(info.code, "NOSOLUTION") == 0, "12.10: code %s, want NOSOLUTION",
            info.code ? info.code : "(none)");
  printf("p03-14: point=%d t=%g dt=%g f=%g v_b=%s\n", points, at, dt, f, info.code);
  fflush(stdout);
  return 0;
}

static void p03_14_startup(void)
{
  static s_vpi_analog_systf_data systf;

  systf.type = vpiAnalogSysFunc;
  systf.sysfunctype = vpiRealFunc;
  systf.tfname = (PLI_BYTE8 *)"$p03_env";
  systf.calltf = env_calltf;
  P03_CHECK(vpi_register_analog_systf(&systf) != NULL, "12.32: registering $p03_env failed");
}

void (*vlog_startup_routines[])(void) = { p03_14_startup, 0 };
