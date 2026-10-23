/* Required behavior, isolated from the census application's expected-failure guards.
 * vpi_design.va declares bus [0:3], instantiates u1 on line 39 and has an
 * internal mid net that is not a low connection of a top-level port.
 */
//! lrm 11.6.8
//! lrm 12.20:1
//! design vpi_design.va
//! stdout indexed_analog_net_bit: required behavior verified
#include "p02_check.h"
static void verify(void)
{
  vpiHandle bus = p02_by_name("vpi_top.bus");
  vpiHandle bit = vpi_handle_by_index(bus, 0);
  PLI_INT32 err = vpi_chk_error(NULL);
  CHECK(bit != NULL && err == 0, "indexed analog net bit: valid bus[0] must exist without an error");
  CHECK(vpi_get(vpiSize, bit) == 1, "indexed analog net bit: the selected bit must have size 1");
  puts("indexed_analog_net_bit: required behavior verified");
}
static void setup(void) { p02_defer(verify); }
void (*vlog_startup_routines[])(void) = { setup, 0 };
