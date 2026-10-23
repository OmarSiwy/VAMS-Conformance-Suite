/* 08 — the simulator ACTION callbacks of LRM 12.31.4, and vpi_sim_control()
 * cutting a run short.
 *
 * LRM 12.31.4: "The following action-related callbacks shall be defined:
 *   cbEndOfCompile        End of simulation data structure compilation or build
 *   cbStartOfSimulation   Start of simulation (beginning of time 0 simulation
 *                         cycle)
 *   cbEndOfSimulation     End of simulation (e.g., $finish system task
 *                         executed)
 *   cbError               Simulation run-time error occurred
 *   cbPLIError            Simulation run-time error occurred in a PLI function
 *                         call
 *   cbTchkViolation       Timing check error occurred"
 * and: "Actions are differentiated from features in that actions shall occur in
 * all VPI-compliant products, whereas features might not exist in all
 * VPI-compliant products." — which is why none of the cbStartOfSave /
 * cbEnterInteractive family is touched here.
 *
 * SIX action reasons; this file registers THREE. That is a scope decision, not
 * a reading of the clause, and the list above is quoted whole so it cannot be
 * mistaken for one:
 *
 *   cbEndOfCompile / cbStartOfSimulation / cbEndOfSimulation are the three a
 *     clean run reaches by existing, so a run that finishes delivers them.
 *   cbError and cbPLIError are reached only by provoking a run-time error, and
 *     an application that provokes one cannot also assert the run was clean —
 *     p02_check.h's expect_no_error would have nothing left to mean. They
 *     belong to a fixture whose subject is error recovery.
 *   cbTchkViolation needs a timing check, hence a specify block. No design in
 *     this row has one and no clause in this row's coverage list reaches them.
 *
 * An earlier revision of this header closed the quotation after
 * cbEndOfSimulation and called them "the three action reasons that shall occur
 * in all VPI-compliant products", which read as though 12.31.4 defined three.
 * It defines six. tests/fixtures/ch11_vpi/p02_SPEC.md at 8b1514d4's "Deliberately NOT covered" now names the other
 * three and what each would need.
 *
 * LRM 12.31.4: "The only fields in the s_cb_data structure which need to be
 * setup for simulation action/feature callbacks are the reason, cb_rtn, and
 * user_data (if desired) fields." So all three registrations below leave `time`
 * and `value` NULL, and an implementation that dereferences them fails here.
 *
 * LRM 12.36: "vpiFinish — cause $finish built-in Verilog system task to be
 * executed upon return of user function. This operation shall be passed one
 * additional diagnostic message level integer argument that is the same as the
 * argument passed to $finish". Return: "1 (true) if successful; 0 (false) on a
 * failure".
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * ORDER. The three registered reasons are defined at three different points of
 * a run's life — after the build, at the head of time 0, and at the end — so a
 * run must deliver them in exactly that order and exactly once each. The
 * application records a three-character order string and asserts "CSE".
 *
 * WHEN. vpi_get_time(NULL) inside cbStartOfSimulation must read 0, because that
 * callback is at the "beginning of time 0". Inside cbEndOfSimulation it must
 * read 12, because that is when this application asked for $finish and 12.36
 * says $finish is "executed upon return of user function" — the same tick, not
 * the next event.
 *
 * WHAT IS CUT OFF. p02_design.g changes at t=0 (xx -> 0x01), 5, 10 and 20, and
 * p02_design prints "p02_design: t=20 reached" at t=20; the design's own
 * backstop $finish is at t=40. This application calls vpi_sim_control(vpiFinish,
 * 0) from a cbAtStartOfSimTime at t=12. A correct implementation therefore
 * delivers EXACTLY THREE cbValueChange callbacks on g — t=0, t=5, t=10 — never
 * reaches t=20, and never prints the design's t=20 line. Four callbacks, or a
 * stdout carrying that line, means the finish was deferred to the design's own
 * t=40 backstop and the request did nothing.
 *
 * The stdout half of that is checked by the harness, not from inside C: this
 * application's only stdout is its own census line, so the expected transcript
 * is exactly one line (see tests/fixtures/ch11_vpi/p02_SPEC.md at 8b1514d4).
 */

//! lrm 11.2.1
//! lrm 12.2
//! lrm 12.15
//! lrm 12.21
//! lrm 12.31.1
//! lrm 12.31.2
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 12.36
//! lrm 12.31.4:3
//! lrm 12.31.4:4
//! lrm 12.36:2
//! design ../digital/design.v
//! stdout p02: 08_cb_action_sim_control checks=24

#include "p02_check.h"

static char order[8];
static int  order_len = 0;
static int  g_changes = 0;
static int  finish_ok = -1;

static void note(char c)
{
  CHECK(order_len < 7, "more action callbacks than this application registered");
  order[order_len++] = c;
  order[order_len] = '\0';
}

static PLI_UINT32 now(void)
{
  s_vpi_time t;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  return t.low;
}

static int on_g(p_cb_data cb_data)
{
  (void)cb_data;
  g_changes++;
  CHECK(now() <= 12, "no g change after t=12 may be delivered, saw t=%u",
        (unsigned)now());
  return 0;
}

static int on_end_of_compile(p_cb_data cb_data)
{
  CHECK(cb_data->reason == cbEndOfCompile, "reason must be echoed back");
  note('C');
  return 0;
}

static int on_start_of_simulation(p_cb_data cb_data)
{
  static s_vpi_time  gt = { vpiSimTime, 0, 0, 0.0 };
  static s_vpi_value gv = { vpiIntVal, { 0 } };
  static s_cb_data   gcb;
  (void)cb_data;

  note('S');
  CHECK(now() == 0, "cbStartOfSimulation is at the beginning of time 0, read %u",
        (unsigned)now());
  CHECK(order_len == 2 && order[0] == 'C',
        "cbEndOfCompile must already have happened, order so far `%s`", order);

  gcb.reason = cbValueChange; gcb.cb_rtn = on_g;
  gcb.obj = p02_by_name("p02_design.g");
  gcb.time = &gt; gcb.value = &gv; gcb.index = 0; gcb.user_data = NULL;
  CHECK(vpi_register_cb(&gcb) != NULL, "cbValueChange on g failed to register");
  return 0;
}

static int ask_to_finish(p_cb_data cb_data)
{
  (void)cb_data;
  CHECK(now() == 12, "the finish request is made at t=12, read %u", (unsigned)now());
  CHECK(g_changes == 3,
        "by t=12 g has changed at t=0, 5 and 10: want 3, got %d", g_changes);
  finish_ok = vpi_sim_control(vpiFinish, 0);
  expect_no_error("vpi_sim_control(vpiFinish, 0)");
  CHECK(finish_ok == 1, "vpi_sim_control must return 1 on success, got %d", finish_ok);
  /* 12.36 says $finish runs "upon return of user function", so the run is still
   * alive right here and this reading must still work. */
  CHECK(now() == 12, "the request must not itself advance time");
  return 0;
}

static int on_end_of_simulation(p_cb_data cb_data)
{
  (void)cb_data;
  note('E');
  CHECK(strcmp(order, "CSE") == 0,
        "action callbacks must arrive compile, start, end: got `%s`", order);
  CHECK(now() == 12,
        "$finish runs on return of the t=12 callback, so the run ends at t=12, "
        "read %u", (unsigned)now());
  CHECK(g_changes == 3,
        "g's t=20 change is past the finish and must never be delivered: "
        "want 3 callbacks, got %d", g_changes);
  p02_done("08_cb_action_sim_control");
  return 0;
}

static void register_at12(void)
{
  static s_cb_data at12 = { 0 };
  static s_vpi_time t12 = { vpiSimTime, 0, 12, 0.0 };
  at12.reason = cbAtStartOfSimTime; at12.cb_rtn = ask_to_finish;
  at12.obj = NULL; at12.time = &t12; at12.value = NULL;
  at12.index = 0; at12.user_data = NULL;
  CHECK(vpi_register_cb(&at12) != NULL, "the t=12 finish request failed to register");
}

static void setup(void)
{
  /* 12.31.4: reason, cb_rtn and user_data are the only fields that need to be
   * set up for an action callback. time and value stay NULL on purpose. */
  static s_cb_data compile_cb = { 0 }, start_cb = { 0 }, end_cb = { 0 };

  compile_cb.reason = cbEndOfCompile;      compile_cb.cb_rtn = on_end_of_compile;
  start_cb.reason   = cbStartOfSimulation; start_cb.cb_rtn   = on_start_of_simulation;
  end_cb.reason     = cbEndOfSimulation;   end_cb.cb_rtn     = on_end_of_simulation;

  CHECK(vpi_register_cb(&compile_cb) != NULL, "cbEndOfCompile registration failed");
  CHECK(vpi_register_cb(&start_cb)   != NULL, "cbStartOfSimulation registration failed");
  CHECK(vpi_register_cb(&end_cb)     != NULL, "cbEndOfSimulation registration failed");

  /* IEEE 1364-2005 26.2.4: cbAtStartOfSimTime is not a startup reason. */
  p02_defer(register_at12);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
