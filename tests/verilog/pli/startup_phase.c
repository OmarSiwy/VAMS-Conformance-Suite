/* b 26.2.4 — what a vlog_startup_routines entry may call, over
 * ch11_vpi/objects.v.
 *
 * IEEE 1364-2005 §26.2.4, p. 376: "when the routines within the
 * vlog_startup_routines[ ] array are executed, there is very little
 * functionality available. Only two routines can be called at this time:
 * vpi_register_systf() [and] vpi_register_cb()". "In addition, the
 * vpi_register_cb() routine can only be called for the following reasons:
 * cbEndOfCompile, cbStartOfSimulation, cbEndOfSimulation, cbUnresolvedSystf,
 * cbError, cbPLIError". And: "After the sizetf routines are called, the
 * routines registered for reason cbEndOfCompile are called. At this point,
 * and continuing until the tool has finished execution, all functionality is
 * available."
 *
 * LRM 12.33.2: "This array of C functions shall be for registering system
 * tasks and functions." Its "performing any other desired task just after
 * the simulator is invoked" is met by registering a callback that performs
 * it, as 12.31.4's setup_report_cpu example does (specification/Vague_Decisions.md
 * VD-044: VerA refuses every other routine at startup, with an error that
 * cites 26.2.4).
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * AT STARTUP, allowed, each with no error:
 *   vpi_register_systf($b264)                    a handle
 *   vpi_register_cb for cbEndOfCompile, cbStartOfSimulation,
 *     cbEndOfSimulation, cbError, cbPLIError      five handles
 * $b264's compiletf and sizetf are NULL: 12.33.1 "One or more of the
 * compiletf, calltf, and sizetf fields can be set to NULL if they are not
 * needed." The registration is accepted and reports no error.
 * (cbUnresolvedSystf is not asserted: VerA delivers no such callback and
 * refuses the reason at any time.) vpi_chk_error() is how each refusal below
 * is read; §27.1 resets the status on every call but it, so it is usable here.
 *
 * AT STARTUP, refused, each returning its routine's failure value with an
 * error whose message names 26.2.4:
 *   vpi_register_cb(cbReadOnlySynch, t=0)   NULL   a reason not in the list
 *   vpi_handle_by_name("p04_objects", NULL) NULL
 *   vpi_iterate(vpiModule, NULL)             NULL
 *   vpi_get_vlog_info(&info)                 0 (FALSE)
 *   vpi_printf("b264 startup\n")             EOF, and prints nothing
 *
 * THE LEGAL NEIGHBOURS, the same five calls from cbEndOfCompile, where "all
 * functionality is available": the cbReadOnlySynch(0) registers, and fires
 * once at t=0; the top module is found by name and is the first (only)
 * vpiModule of the NULL iteration; vpi_get_vlog_info returns TRUE;
 * vpi_printf("b264 eoc\n") writes its 9 characters. So stdout holds
 * "b264 eoc" and never "b264 startup".
 *
 * ORDER (§26.2.4 and 12.31.4): cbEndOfCompile fires once before
 * cbStartOfSimulation, which fires once before the t=0 cbReadOnlySynch;
 * cbEndOfSimulation (p04_objects's `#1 $finish(0)`) reports.
 */

//! inherited IEEE 1364-2005 26.2.4
//! inherited-reject IEEE 1364-2005 26.2.4
//! lrm 12.33.2
//! lrm-reject 12.33.2
//! lrm 12.33.2:1001
//! lrm 12.33.1:1001
//! design ../../verilog-ams/ch11_vpi/objects.v
//! stdout b264 eoc
//! stdout p02: b_26_2_4_startup_phase checks=27

#include "b_check.h"

static int order = 0, eoc_at = 0, sos_at = 0, ro_at = 0, ro_n = 0;
static s_vpi_time t0 = { vpiSimTime, 0, 0, 0.0 };

static PLI_INT32 b264_calltf(PLI_BYTE8 *ud)
{
  (void)ud;
  return 0;
}

static PLI_INT32 nothing(p_cb_data d)
{
  (void)d;
  return 0;
}

static PLI_INT32 read_only(p_cb_data d)
{
  (void)d;
  ro_at = ++order;
  ro_n++;
  return 0;
}

static s_cb_data ro_cb = { cbReadOnlySynch, read_only, NULL, &t0, NULL, 0, NULL };

static PLI_INT32 end_of_compile(p_cb_data d)
{
  s_vpi_vlog_info info;
  vpiHandle top, itr;
  (void)d;
  eoc_at = ++order;
  CHECK(vpi_register_cb(&ro_cb) != NULL, "26.2.4: cbReadOnlySynch registers from cbEndOfCompile");
  expect_no_error("vpi_register_cb(cbReadOnlySynch) at cbEndOfCompile");
  top = vpi_handle_by_name("p04_objects", NULL);
  CHECK(top != NULL, "26.2.4: the top module is found from cbEndOfCompile");
  itr = vpi_iterate(vpiModule, NULL);
  CHECK(itr != NULL && vpi_compare_objects(vpi_scan(itr), top), "and is the first top-level module");
  vpi_free_object(itr);
  CHECK(vpi_get_vlog_info(&info) == 1, "26.2.4: vpi_get_vlog_info from cbEndOfCompile is TRUE");
  CHECK(vpi_printf("b264 eoc\n") == 9, "26.2.4: vpi_printf from cbEndOfCompile writes 9 characters");
  expect_no_error("the routines from cbEndOfCompile");
  return 0;
}

static PLI_INT32 start_of_simulation(p_cb_data d)
{
  (void)d;
  sos_at = ++order;
  return 0;
}

static PLI_INT32 end_of_simulation(p_cb_data d)
{
  (void)d;
  CHECK(eoc_at == 1 && sos_at == 2 && ro_at == 3,
        "cbEndOfCompile, cbStartOfSimulation, then the t=0 cbReadOnlySynch: got %d %d %d",
        eoc_at, sos_at, ro_at);
  CHECK(ro_n == 1, "the cbReadOnlySynch registered at cbEndOfCompile fired once, got %d", ro_n);
  p02_done("b_26_2_4_startup_phase");
  return 0;
}

static void startup(void)
{
  static s_vpi_systf_data tf = { vpiSysTask, 0, "$b264", b264_calltf, NULL, NULL, NULL };
  static s_cb_data eoc = { cbEndOfCompile, end_of_compile, NULL, NULL, NULL, 0, NULL };
  static s_cb_data sos = { cbStartOfSimulation, start_of_simulation, NULL, NULL, NULL, 0, NULL };
  static s_cb_data eos = { cbEndOfSimulation, end_of_simulation, NULL, NULL, NULL, 0, NULL };
  static s_cb_data err = { cbError, nothing, NULL, NULL, NULL, 0, NULL };
  static s_cb_data pli = { cbPLIError, nothing, NULL, NULL, NULL, 0, NULL };
  s_vpi_vlog_info info;

  /* The two routines, and five of the six reasons. */
  CHECK(vpi_register_systf(&tf) != NULL, "26.2.4: vpi_register_systf at startup");
  expect_no_error("vpi_register_systf at startup");
  CHECK(vpi_register_cb(&eoc) != NULL, "26.2.4: cbEndOfCompile at startup");
  CHECK(vpi_register_cb(&sos) != NULL, "26.2.4: cbStartOfSimulation at startup");
  CHECK(vpi_register_cb(&eos) != NULL, "26.2.4: cbEndOfSimulation at startup");
  CHECK(vpi_register_cb(&err) != NULL, "26.2.4: cbError at startup");
  CHECK(vpi_register_cb(&pli) != NULL, "26.2.4: cbPLIError at startup");
  expect_no_error("vpi_register_cb for the startup reasons");

  /* Everything else. */
  CHECK(vpi_register_cb(&ro_cb) == NULL, "26.2.4: cbReadOnlySynch is not a startup reason");
  expect_refusal_saying("vpi_register_cb(cbReadOnlySynch) at startup", "26.2.4");
  CHECK(vpi_handle_by_name("p04_objects", NULL) == NULL, "26.2.4: no vpi_handle_by_name at startup");
  expect_refusal_saying("vpi_handle_by_name at startup", "26.2.4");
  CHECK(vpi_iterate(vpiModule, NULL) == NULL, "26.2.4: no vpi_iterate at startup");
  expect_refusal_saying("vpi_iterate at startup", "26.2.4");
  CHECK(vpi_get_vlog_info(&info) == 0, "26.2.4: no vpi_get_vlog_info at startup");
  expect_refusal_saying("vpi_get_vlog_info at startup", "26.2.4");
  CHECK(vpi_printf("b264 startup\n") == EOF, "26.2.4: no vpi_printf at startup");
  expect_refusal_saying("vpi_printf at startup", "26.2.4");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
