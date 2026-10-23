/* b7 vpiReset asked on every run: VAMS-2023 12.36 with a nonzero
 * stop_value, over digital.v.
 *
 * 12.36  "vpiReset — cause $reset informative built-in Verilog system task
 *        to be executed upon return of user VPI function." IEEE 1364-2005
 *        C.7: "A nonzero value passed to $reset causes the tool to begin
 *        processing immediately."
 *
 * An application that asks again on every run never lets the run end: each
 * reset goes back to time 0 and the next request comes at t=3. Neither
 * clause bounds the number of resets; VerA performs at most 1000 in one run
 * and refuses the next request by name (specification/Vague_Decisions.md
 * §7), firing cbError (IEEE 1364-2005 §27.33.3) and exiting 1, where it
 * used to hang (#37). Legal neighbour: sim_control_reset_run.c, one
 * reset that runs on to $finish.
 *
 * DERIVATION. at3 asks vpi_sim_control(vpiReset, 1, 0, 0) at every t=3
 * and must get 1 each time (the request is accepted; the refusal comes when
 * the run performs it). cbEndOfReset counts a performed reset and
 * registers the next cbAfterDelay(3), since a time callback that fired is
 * gone after a reset (VD-106). Resets 1..1000 are performed, the 1001st
 * request is refused: cbError sees requests=1001 resets=1000, and
 * cbEndOfSimulation never fires.
 */

//! lrm 12.36:6
//! lrm 12.31.4:1002
//! design digital.v
//! stdout b7_reset_every_run: requests=1001 resets=1000
//! refuse more than 1000 vpiReset requests

#include "../ch11_vpi/p02_check.h"

#ifndef vpiReset
#define vpiReset 68
#endif

static int requests, resets;

static PLI_INT32 at3(p_cb_data d)
{
  (void)d;
  requests++;
  CHECK(vpi_sim_control(vpiReset, 1, 0, 0) == 1, "12.36: vpi_sim_control(vpiReset, 1, 0, 0) failed");
  return 0;
}

static void arm(void)
{
  static s_vpi_time t;
  static s_cb_data cb;
  t.type = vpiSimTime;
  t.low = 3;
  cb.reason = cbAfterDelay;
  cb.cb_rtn = at3;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbAfterDelay(3) registration failed");
}

static PLI_INT32 end_of_reset(p_cb_data d);

/* IEEE 1364-2005 §26.2.4: a reset reason may be registered only after
   vlog_startup_routines, so cbEndOfReset is registered here. */
static PLI_INT32 eoc(p_cb_data d)
{
  static s_cb_data r;
  (void)d;
  r.reason = cbEndOfReset;
  r.cb_rtn = end_of_reset;
  CHECK(vpi_register_cb(&r) != NULL, "cbEndOfReset registration failed");
  arm();
  return 0;
}

static PLI_INT32 end_of_reset(p_cb_data d)
{
  (void)d;
  resets++;
  arm();
  return 0;
}

static PLI_INT32 on_error(p_cb_data d)
{
  s_vpi_error_info info;
  (void)d;
  /* LRM 12.31.4: "On a cbError callback, the routine vpi_chk_error() can be
   * called to retrieve error information." Read it FIRST: 12.2 resets the
   * status on every other VPI routine, so a routine called before this would
   * hide the error the callback exists to report. */
  CHECK(vpi_chk_error(&info) != 0,
        "a cbError callback must find an error status to retrieve");
  CHECK(info.level == vpiError,
        "the status level is vpiError, got %d", (int)info.level);
  CHECK(info.code != NULL && strstr(info.code, "RUNTIME") != NULL,
        "the status code names the run-time error, got %s",
        info.code ? info.code : "(null)");
  CHECK(info.message != NULL && info.message[0] != '\0',
        "the status carries a message");
  printf("b7_reset_every_run: requests=%d resets=%d\n", requests, resets);
  fflush(stdout);
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  (void)d;
  printf("b7_reset_every_run: the run ended, which it must not\n");
  return 0;
}

static void setup(void)
{
  static s_cb_data c, e, s;
  c.reason = cbEndOfCompile;
  c.cb_rtn = eoc;
  CHECK(vpi_register_cb(&c) != NULL, "cbEndOfCompile registration failed");
  e.reason = cbError;
  e.cb_rtn = on_error;
  CHECK(vpi_register_cb(&e) != NULL, "cbError registration failed");
  s.reason = cbEndOfSimulation;
  s.cb_rtn = eos;
  CHECK(vpi_register_cb(&s) != NULL, "cbEndOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
