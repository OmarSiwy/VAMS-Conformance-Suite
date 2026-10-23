/* p04 03 — what the value, time, printing and control routines REFUSE, over
 * objects.v.
 *
 * LRM 11.3.2: "simulation values are also handled with the routines
 * vpi_get_value() and vpi_put_value(), along with an associated set of
 * structures." Each routine below is handed an argument outside its domain
 * and must return its documented failure value, with vpi_chk_error()
 * reporting it (12.2):
 *
 *   12.16  vpi_get_value(obj, value_p): "Handle to an expression" and a
 *          "structure, which has been allocated by the user". A NULL handle,
 *          a module (11.6.1 draws no value for a module), a NULL value_p and a
 *          format that is no Table 12-4 format are each refused; the refused
 *          call leaves the caller's structure as it was.
 *   12.30  vpiCancelEvent: "The object passed to vpi_put_value() shall be a
 *          handle to an object of type vpiSchedEvent" — r is a reg. A flags
 *          value that is none of the seven delay modes is refused, and so is a
 *          delayed put with no time_p: only vpiNoDelay, vpiForceFlag and
 *          vpiReleaseFlag say "Argument time_p shall be ignored and can be set
 *          to NULL". After the three refusals r still reads 9 — none of them
 *          wrote.
 *   12.15  "The memory for the time_p structure shall be allocated by the
 *          user": NULL is refused. "The time_p->type field shall be set to
 *          indicate if scaled real, analog, or simulation time is desired":
 *          vpiSuppressTime asks for none of them, and is refused.
 *   12.36  "bool 1 (true) if successful; 0 (false) on a failure": operation
 *          12345 is no operation. The run is NOT ended by it: the later
 *          cbReadOnlySynch at t=0 still runs, which is what prints the census.
 *   12.26  "The vpi_mcd_open() routine shall return a zero (0) on error": a
 *          NULL name, and a file in a directory that does not exist.
 *   12.27  "The routine shall return the number of characters printed or EOF
 *          if an error occurred": channel 21 (bit 20) was never opened, and a
 *          NULL format is no format.
 *   12.28  the same sentence, for vpi_printf(NULL).
 *
 * 12.1: "All arguments shall be considered mandatory unless specifically
 * noted in the definition of the PLI routine." vpi_get_value's value_p,
 * vpi_get_time's time_p and vpi_mcd_open's file name are noted nowhere as
 * optional, so a NULL for any of them is refused, not defaulted.
 *
 * EOF is C's, from <stdio.h>. The refusals run from cbReadWriteSynch at t=0,
 * where 12.31.2 allows writing, so a refused put is refused for its own
 * reason and not for the read-only region's.
 */

//! lrm-reject 11.3.2
//! lrm-reject 12.1
//! lrm-reject 12.15
//! lrm-reject 12.16
//! lrm-reject 12.26
//! lrm-reject 12.27
//! lrm-reject 12.28
//! lrm-reject 12.30
//! lrm-reject 12.36
//! lrm 12.31.2
//! lrm-reject 12.26:2
//! lrm-reject 12.27:2
//! lrm-reject 12.28:3
//! lrm-reject 12.36:2
//! design objects.v
//! stdout p02: p04_03_value_time_refusals checks=70

#include "p02_check.h"

static vpiHandle top, r;

static PLI_INT32 refuse(p_cb_data cb_data)
{
  s_vpi_value v;
  s_vpi_time t;
  (void)cb_data;

  top = p02_by_name("p04_objects");
  r   = p02_by_name("p04_objects.r");

  /* 12.16 */
  v.format = vpiIntVal;
  v.value.integer = -7;
  vpi_get_value(NULL, &v);
  expect_error("vpi_get_value(NULL)");
  vpi_get_value(top, &v);
  expect_error("vpi_get_value(module)");
  vpi_get_value(r, NULL);
  expect_error("vpi_get_value(r, NULL)");
  v.format = 9999;
  vpi_get_value(r, &v);
  expect_error("vpi_get_value(format 9999)");
  CHECK(v.format == 9999 && v.value.integer == -7, "a refused read leaves the structure alone");
  v.format = vpiIntVal;
  vpi_get_value(r, &v);
  expect_no_error("vpi_get_value(r, vpiIntVal)");
  CHECK(v.value.integer == 9, "r = 9, got %d", (int)v.value.integer);

  /* 12.30 */
  v.format = vpiIntVal;
  v.value.integer = 3;
  CHECK(vpi_put_value(r, &v, NULL, vpiCancelEvent) == NULL, "12.30: r is not a vpiSchedEvent");
  expect_error("vpi_put_value(reg, vpiCancelEvent)");
  CHECK(vpi_put_value(r, &v, NULL, 9999) == NULL, "12.30: 9999 is no delay mode");
  expect_error("vpi_put_value(flags 9999)");
  CHECK(vpi_put_value(r, &v, NULL, vpiInertialDelay) == NULL, "12.30: a delayed put needs time_p");
  expect_error("vpi_put_value(vpiInertialDelay, NULL time)");
  CHECK(vpi_put_value(NULL, &v, NULL, vpiNoDelay) == NULL, "12.30: NULL is no object");
  expect_error("vpi_put_value(NULL)");
  v.format = vpiIntVal;
  vpi_get_value(r, &v);
  CHECK(v.value.integer == 9, "12.30: no refused put wrote r, got %d", (int)v.value.integer);

  /* 12.15 */
  vpi_get_time(NULL, NULL);
  expect_error("vpi_get_time(NULL, NULL)");
  t.type = vpiSuppressTime;
  vpi_get_time(NULL, &t);
  expect_error("vpi_get_time(vpiSuppressTime)");
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  expect_no_error("vpi_get_time(vpiSimTime)");
  CHECK(t.high == 0 && t.low == 0, "12.15: the time is 0");

  /* 12.36 */
  CHECK(vpi_sim_control(12345) == 0, "12.36: 12345 is no operation");
  expect_error("vpi_sim_control(12345)");

  /* 12.26 */
  CHECK(vpi_mcd_open(NULL) == 0, "12.26: a NULL name opens nothing");
  expect_error("vpi_mcd_open(NULL)");
  CHECK(vpi_mcd_open((PLI_BYTE8 *)"p04_no_such_dir/p04.log") == 0,
        "12.26: a file in a missing directory cannot be opened");
  expect_error("vpi_mcd_open(missing directory)");

  /* 12.27 / 12.28 */
  CHECK(vpi_mcd_printf(1u << 20, (PLI_BYTE8 *)"p04\n") == EOF, "12.27: channel 21 is not open");
  expect_error("vpi_mcd_printf(unopened)");
  CHECK(vpi_mcd_printf(1u, NULL) == EOF, "12.27: a NULL format is no format");
  expect_error("vpi_mcd_printf(NULL format)");
  CHECK(vpi_printf(NULL) == EOF, "12.28: a NULL format is no format");
  expect_error("vpi_printf(NULL)");
  return 0;
}

static PLI_INT32 census(p_cb_data cb_data)
{
  (void)cb_data;
  p02_done("p04_03_value_time_refusals");
  return 0;
}

static void setup_after_compile(void)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data rw, ro;
  rw.reason = cbReadWriteSynch;
  rw.cb_rtn = refuse;
  rw.time = &t;
  CHECK(vpi_register_cb(&rw) != NULL, "cbReadWriteSynch(0) registration failed");
  ro.reason = cbReadOnlySynch;
  ro.cb_rtn = census;
  ro.time = &t;
  CHECK(vpi_register_cb(&ro) != NULL, "cbReadOnlySynch(0) registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
