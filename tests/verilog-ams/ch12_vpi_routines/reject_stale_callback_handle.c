/* P03 REJECT — VAMS-2023 12.34: a removed callback handle is dead, and saying
 * so is part of the routine's contract.
 *
 *   12.34  "The routine shall return a 1 (TRUE) if successful, and a 0 (FALSE)
 *          on a failure. After vpi_remove_cb() is called with a handle to the
 *          callback, the handle is no longer valid."
 *   12.6   vpi_get_cb_info() "shall return information about a simulation-
 *          related callback", i.e. about a LIVE one.
 *   12.2   "The error status shall be reset by any VPI routine call except
 *          vpi_chk_error()" — so each failure below is checked immediately, and
 *          each is required to carry a state, a code and a message.
 *
 * FOUR WAYS TO CALL vpi_remove_cb() WRONG, each with its exact return:
 *
 *   remove a live callback      -> 1   (the control, without which a
 *                                       return-0-always implementation passes)
 *   remove the same handle again-> 0 + vpiError
 *   remove NULL                 -> 0 + vpiError
 *   remove a non-callback object-> 0 + vpiError   (a module handle: 12.34 takes
 *                                       "a handle to the callback object", and
 *                                       a handle that is valid but of the wrong
 *                                       class is the case a type check exists
 *                                       for)
 *
 * plus vpi_get_cb_info() on the removed handle, which must report rather than
 * follow a freed pointer. Three of these hand the implementation a pointer it
 * once owned or never owned; all four have to survive it, because "no longer
 * valid" is a promise to the APPLICATION and an application that keeps a stale
 * handle is the reason the sentence is in the standard.
 *
 * The last assertion is the behavioural one: the removed callback was an
 * acbFinalStep, the run has exactly one final analog solution, and the routine
 * must be invoked ZERO times. A removal that returns 1 and then dispatches
 * anyway is the failure this catches, and it is invisible to every check above.
 *
 *! design   dc_divider.va
 *! analysis op
 *! expect   91_reject_stale_callback_handle.expected.txt
 */

//! lrm 12.2
//! lrm-reject 12.6
//! lrm 12.34
//! lrm-reject 12.34
//! lrm 12.34:1
//! lrm-reject 12.34:3
//! design dc_divider.va
//! stdout p03-91: first=1 second=0 null=0 wrongtype=0 info_err=1 errs=4 fired=0

#include "p03_vpi_analog.h"

static int victim_fired;
static int first_ret = -1, second_ret = -1, null_ret = -1, wrongtype_ret = -1;
static int info_err, errs;

static PLI_INT32 victim_cb(p_cb_data cb)
{
  (void)cb;
  victim_fired++;
  return 0;
}

static PLI_INT32 on_end(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(first_ret == 1, "12.34: removing a live callback returned %d, want 1", first_ret);
  P03_CHECK(second_ret == 0, "12.34: removing an already-removed handle returned %d, want 0",
            second_ret);
  P03_CHECK(null_ret == 0, "12.34: vpi_remove_cb(NULL) returned %d, want 0", null_ret);
  P03_CHECK(wrongtype_ret == 0,
            "12.34: vpi_remove_cb on a module handle returned %d, want 0", wrongtype_ret);
  P03_CHECK(info_err == 1, "12.6: vpi_get_cb_info on a removed handle must report an error");
  P03_CHECK(errs == 4, "12.2: %d of the 4 failures carried an error report", errs);
  P03_CHECK(victim_fired == 0,
            "12.34: the removed acbFinalStep callback still ran %d times", victim_fired);
  printf("p03-91: first=%d second=%d null=%d wrongtype=%d info_err=%d errs=%d fired=%d\n",
         first_ret, second_ret, null_ret, wrongtype_ret, info_err, errs, victim_fired);
  fflush(stdout);
  return 0;
}

static void p03_91_after_compile(void)
{
  static s_cb_data vic_cb, end_cb;
  s_cb_data info;
  vpiHandle h, mod;

  vic_cb.reason = acbFinalStep;
  vic_cb.cb_rtn = victim_cb;
  h = vpi_register_cb(&vic_cb);
  P03_CHECK(h != NULL, "12.31: acbFinalStep registration failed");
  p03_no_error("vpi_register_cb");

  first_ret = vpi_remove_cb(h);
  p03_no_error("the first vpi_remove_cb");

  /* "the handle is no longer valid" — and the implementation has to know that
   * about a pointer it issued itself, without dereferencing it. */
  second_ret = vpi_remove_cb(h);
  errs += p03_saw_error("vpi_remove_cb on an already-removed handle");

  vpi_get_cb_info(h, &info);
  info_err = p03_saw_error("vpi_get_cb_info on a removed handle");
  errs += info_err ? 1 : 0;

  null_ret = vpi_remove_cb(NULL);
  errs += p03_saw_error("vpi_remove_cb(NULL)");

  mod = vpi_handle_by_name((PLI_BYTE8 *)"p03_dc_divider.r1", NULL);
  P03_CHECK(mod != NULL, "no instance p03_dc_divider.r1");
  wrongtype_ret = vpi_remove_cb(mod);
  errs += p03_saw_error("vpi_remove_cb on a module handle");

  end_cb.reason = cbEndOfSimulation;
  end_cb.cb_rtn = on_end;
  P03_CHECK(vpi_register_cb(&end_cb) != NULL, "cbEndOfSimulation registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_91_startup(void)
{
  p03_defer(p03_91_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_91_startup, 0 };
