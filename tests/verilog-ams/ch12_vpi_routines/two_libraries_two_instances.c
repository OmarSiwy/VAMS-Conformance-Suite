/* P03 — VAMS-2023 12.32 and IEEE 1364-2005 27.31/27.13 under a host that
 * attaches TWO device libraries and runs TWO instances of each (VerA #84,
 * ESPice's shape): every library keeps its own call table and design, and
 * every instance its own per-call state.
 *
 *   12.32  calltf runs "each time the system task or function is invoked".
 *   1364 27.31  vpi_put_userdata() "will associate user data with a system
 *               task/function call handle"; 27.13 vpi_get_userdata() "shall
 *               return the user data value associated with" it, NULL "if no
 *               user data had been previously associated".
 *
 * Two instances of a device are two invocations of each of its calls, so
 * what the application associates with the call under one instance is not
 * the other's.
 *
 * THE HOST. As for p03_14 (`*! external`), tests/fixtures/ch11_vpi/vpi_host.zig attaches the
 * design's library with no solution in it, on the installed design. The
 * `*! library` line adds a second, built from env_twin.va, attached with
 * its own design; `*! instances 2` makes it call every call once for host
 * instance 0, then once for instance 1. Per point the order is: library 1
 * (`$p03_env`) instance 0, instance 1; library 2 (`$p03_twin`) instance 0,
 * instance 1.
 *
 * THE APPLICATION. One calltf for both names. It reads the call's user
 * data; on NULL it hands out the next counter slot (1, 2, ...) and puts it
 * there; then it counts the call on that slot and prints the slot, the
 * count and the name of the design's one top module (vpi_iterate(vpiModule,
 * NULL), 11.6.1).
 *
 * THE DERIVATION. Point 1 (t = 1 ms): every (library, instance) pair is
 * new, so each gets a fresh slot in call order, 1 to 4, count 1. Point 2
 * (t = 2 ms): each pair reads back its own slot, count 2. The top is
 * p03_env_probe for library 1 and p03_env_twin for library 2: each call runs
 * in its own design. A shared user data table would give instance 1 slot 1
 * (count 2 at point 1); designs sharing it (the twin's call has the same
 * object index) would give library 2 slots 1 and 2.
 *
 *! design    env_probe.va
 *! library   env_twin.va
 *! instances 2
 *! external  tran 1m 1u 0
 *! external  tran 2m 1u 0
 */

//! lrm 12.32
//! inherited IEEE 1364-2005 27.31
//! inherited IEEE 1364-2005 27.13
//! design env_probe.va
//! stdout p03-15: t=0.001 top=p03_env_probe slot=1 n=1
//! stdout p03-15: t=0.001 top=p03_env_probe slot=2 n=1
//! stdout p03-15: t=0.001 top=p03_env_twin slot=3 n=1
//! stdout p03-15: t=0.001 top=p03_env_twin slot=4 n=1
//! stdout p03-15: t=0.002 top=p03_env_probe slot=1 n=2
//! stdout p03-15: t=0.002 top=p03_env_probe slot=2 n=2
//! stdout p03-15: t=0.002 top=p03_env_twin slot=3 n=2
//! stdout p03-15: t=0.002 top=p03_env_twin slot=4 n=2

#include "p03_vpi_analog.h"

#define P03_15_SLOTS 4

static int counts[P03_15_SLOTS];
static int handed;

static PLI_INT32 count_calltf(p_cb_data cb)
{
  vpiHandle call, itr, m, top = NULL;
  int *slot;
  int tops = 0;
  (void)cb;
  call = vpi_handle(vpiSysTfCall, NULL);
  P03_CHECK(call != NULL, "11.6.16: no vpiSysTfCall inside calltf");
  slot = (int *)vpi_get_userdata(call);
  p03_no_error("vpi_get_userdata");
  if (slot == NULL) {
    P03_CHECK(handed < P03_15_SLOTS, "27.13: more than %d (library, instance) pairs saw no user data", P03_15_SLOTS);
    slot = &counts[handed++];
    P03_CHECK(vpi_put_userdata(call, slot) == 1, "27.31: vpi_put_userdata failed");
  }
  (*slot)++;

  itr = vpi_iterate(vpiModule, NULL);
  P03_CHECK(itr != NULL, "11.6.1: the design has no top module");
  while ((m = vpi_scan(itr)) != NULL) {
    top = m;
    tops++;
  }
  P03_CHECK(tops == 1, "11.6.1: %d top modules, want 1", tops);
  printf("p03-15: t=%g top=%s slot=%d n=%d\n", vpi_get_analog_time(), vpi_get_str(vpiName, top),
         (int)(slot - counts) + 1, *slot);
  fflush(stdout);
  return 0;
}

static void p03_15_startup(void)
{
  static s_vpi_analog_systf_data env, twin;

  env.type = vpiAnalogSysFunc;
  env.sysfunctype = vpiRealFunc;
  env.tfname = (PLI_BYTE8 *)"$p03_env";
  env.calltf = count_calltf;
  P03_CHECK(vpi_register_analog_systf(&env) != NULL, "12.32: registering $p03_env failed");
  twin = env;
  twin.tfname = (PLI_BYTE8 *)"$p03_twin";
  P03_CHECK(vpi_register_analog_systf(&twin) != NULL, "12.32: registering $p03_twin failed");
}

void (*vlog_startup_routines[])(void) = { p03_15_startup, 0 };
