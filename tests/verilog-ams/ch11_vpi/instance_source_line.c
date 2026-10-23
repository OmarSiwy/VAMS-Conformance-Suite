/* Required behavior, isolated from the census application's expected-failure guards.
 * vpi_design.va declares bus [0:3], instantiates u1 on line 39 and has an
 * internal mid net that is not a low connection of a top-level port.
 */
//! lrm 11.6.1
//! lrm 12.5:3
//! design vpi_design.va
//! stdout instance_source_line: required behavior verified
#include "p02_check.h"
static void verify(void)
{
  vpiHandle h = p02_by_name("vpi_top.u1");
  PLI_INT32 line = vpi_get(6 /* IEEE Annex G: vpiLineNo */, h);
  PLI_INT32 err = vpi_chk_error(NULL);
  CHECK(line == 39 && err == 0, "instance source location: want line 39 and no error; got %d/%d", line, err);
  puts("instance_source_line: required behavior verified");
}
static void setup(void) { p02_defer(verify); }
void (*vlog_startup_routines[])(void) = { setup, 0 };
