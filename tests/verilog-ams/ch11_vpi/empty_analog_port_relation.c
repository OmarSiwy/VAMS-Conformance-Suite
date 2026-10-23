/* Required behavior, isolated from the census application's expected-failure guards.
 * vpi_design.va declares bus [0:3], instantiates u1 on line 39 and has an
 * internal mid net that is not a low connection of a top-level port.
 */
//! lrm 11.6.8
//! lrm 12.23:2
//! design vpi_design.va
//! stdout empty_analog_port_relation: required behavior verified
#include "p02_check.h"
static void verify(void)
{
  vpiHandle net = p02_by_name("vpi_top.mid");
  vpiHandle iter = vpi_iterate(vpiPort, net);
  PLI_INT32 err = vpi_chk_error(NULL);
  CHECK(iter == NULL && err == 0, "empty analog port relation: valid empty iteration must not set an error");
  puts("empty_analog_port_relation: required behavior verified");
}
static void setup(void) { p02_defer(verify); }
void (*vlog_startup_routines[])(void) = { setup, 0 };
