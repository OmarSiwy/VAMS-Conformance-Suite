/* b 20.3 task as function — a user system task in an expression, over
 * task_as_function.v (`x = $random;`).
 *
 * IEEE 1364-2005 §20.3, p. 367: "A user task can be used in the same places a
 * Verilog HDL task can be used (see 10.2). A user-defined system task can
 * read and modify the arguments of the task, but does not return any value."
 * §20.4, p. 367: "If a user-provided PLI application is associated with the
 * same name as a built-in system task/function (using the PLI mechanism),
 * the user-provided C application shall override the built-in system
 * task/function".
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * The startup routine registers $random as a vpiSysTask, which overrides the
 * built-in function (§20.4). The design's `x = $random;` then puts a task
 * where only an expression can stand; a task returns no value, so the design
 * is refused before time 0: the host exits 1, naming $random, and neither
 * this application's cbStartOfSimulation nor the design's $display runs.
 * Its `//! refuse` line pins the refusal. Legal neighbour:
 * systf.c, whose $unsigned override is registered as a vpiSysFunc and
 * called as a function.
 */

//! inherited-reject IEEE 1364-2005 20.3
//! design task_as_function.v
//! refuse vpi_host: `$random` is registered as a system task and called as a function (IEEE 1364-2005 §20.3)

#include "b_check.h"

static PLI_INT32 never(p_cb_data d)
{
  (void)d;
  printf("b_20_3: the refused design reached time 0\n");
  return 0;
}

static void startup(void)
{
  static s_vpi_systf_data t = { vpiSysTask, 0, "$random", NULL, NULL, NULL, NULL };
  static s_cb_data s;
  CHECK(vpi_register_systf(&t) != NULL, "$random registers as a task");
  s.reason = cbStartOfSimulation;
  s.cb_rtn = never;
  CHECK(vpi_register_cb(&s) != NULL, "cbStartOfSimulation");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
