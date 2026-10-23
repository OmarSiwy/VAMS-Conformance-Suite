/* p04 05 — vpi_get_vlog_info(), 12.17.
 *
 * LRM 12.17: "The VPI routine vpi_get_vlog_info() shall obtain the following
 * information about Verilog-AMS product execution: The number of invocation
 * options (argc); Invocation option values (argv); Product and version
 * strings. The information shall be contained in an s_vpi_vlog_info
 * structure. The routine shall return TRUE on success and FALSE on failure."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * The product here is the VPI host `zig build` runs (build.zig, `vpi_runs`):
 * it is invoked as `<host> <design>`, with exactly one option, the path of
 * objects.v. So argc is 2, argv[0] is the host's own name, and argv[1]
 * ends in "objects.v" (the build passes it as an absolute path, so only
 * the tail is fixed). C's own rule for argv, which the structure's
 * `char **argv` inherits, is that argv[argc] is NULL.
 *
 * The product string is the product's name — VerA — and the version string
 * is non-empty; its digits are not asserted, because no clause fixes them.
 *
 * FAILURE: the structure "has been allocated by the user" in every other
 * routine that fills one (12.6, 12.14, 12.16); with no structure there is
 * nothing to fill, so vpi_get_vlog_info(NULL) is the routine's failure —
 * FALSE, with the error 12.2 reports.
 *
 * Called twice, from the end-of-compile callback and again at the start of
 * simulation, to show the answer is a property of the product's execution and
 * not of the moment it is asked. Not from the startup routine: IEEE 1364-2005
 * 26.2.4 allows only vpi_register_systf() and vpi_register_cb() there
 * (ieee_pli/startup_phase.c pins the refusal).
 */

//! lrm 12.17
//! lrm-reject 12.17
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 12.17:1
//! lrm 12.17:2
//! lrm-reject 12.17:2
//! design objects.v
//! stdout p02: p04_05_vlog_info checks=30

#include "p02_check.h"

static void check_info(const char *when)
{
  s_vpi_vlog_info info;
  size_t n;

  memset(&info, 0, sizeof info);
  CHECK(vpi_get_vlog_info(&info) == 1, "%s: vpi_get_vlog_info returns TRUE", when);
  expect_no_error("vpi_get_vlog_info");
  CHECK(info.argc == 2, "%s: the host is invoked with one option, argc == 2, got %d", when, (int)info.argc);
  CHECK(info.argv != NULL, "%s: argv is supplied", when);
  CHECK(info.argv[0] != NULL && info.argv[0][0] != '\0', "%s: argv[0] names the product", when);
  CHECK(info.argv[1] != NULL, "%s: argv[1] is the design", when);
  n = strlen(info.argv[1]);
  CHECK(n >= sizeof("objects.v") - 1 && strcmp(info.argv[1] + n - (sizeof("objects.v") - 1), "objects.v") == 0,
        "%s: argv[1] should end in objects.v, got `%s`", when, info.argv[1]);
  CHECK(info.argv[2] == NULL, "%s: argv[argc] is NULL", when);
  CHECK(info.product != NULL && strcmp(info.product, "VerA") == 0, "%s: the product is VerA", when);
  CHECK(info.version != NULL && info.version[0] != '\0', "%s: a version string is supplied", when);

  CHECK(vpi_get_vlog_info(NULL) == 0, "%s: with no structure, FALSE", when);
  expect_error("vpi_get_vlog_info(NULL)");
}

static PLI_INT32 end_of_compile(p_cb_data cb_data)
{
  (void)cb_data;
  check_info("cbEndOfCompile");
  return 0;
}

static PLI_INT32 start_of_simulation(p_cb_data cb_data)
{
  (void)cb_data;
  check_info("cbStartOfSimulation");
  p02_done("p04_05_vlog_info");
  return 0;
}

static void setup(void)
{
  static s_cb_data cb, sos;
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = end_of_compile;
  CHECK(vpi_register_cb(&cb) != NULL, "cbEndOfCompile registration failed");
  sos.reason = cbStartOfSimulation;
  sos.cb_rtn = start_of_simulation;
  CHECK(vpi_register_cb(&sos) != NULL, "cbStartOfSimulation registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
