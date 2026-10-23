/* 12 — one name, two domains: the uniqueness rule of LRM 12.32, and the '$'
 * rule on tfname.
 *
 * LRM 12.32: "Tasks or functions can be registered with either the analog or
 * digital domain. The registration function (vpi_register_analog_systf() or
 * vpi_register_systf()) with which the task or function is registered shall
 * determine the context or contexts from which the task or function can be
 * invoked and how and when the call backs associated with the function shall be
 * called. THE TASK OR FUNCTION NAME SHALL BE UNIQUE IN THE DOMAIN IN WHICH IT
 * IS REGISTERED. That is, the same name can be shared by two sets of callbacks,
 * provided that one set is registered in the digital domain and the other is
 * registered in the analog." (emphasis added)
 *
 * LRM 12.33, Figure 12-19 and 12.32, Figure 12-18, both on the same field:
 * "char *tfname; /" "* first character shall be "$" *" "/".
 *
 * LRM 12.14 / 12.13: vpi_get_systf_info() and vpi_get_analog_systf_info()
 * "shall return information about a user-defined system task or function
 * callback", into a structure "allocated by the user".
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * The rule has exactly four corners and this file visits all four. `$p02_both`
 * is registered once digitally and once analogically:
 *
 *   vpi_register_systf        ($p02_both)  -> handle D, non-NULL   LEGAL
 *   vpi_register_systf        ($p02_both)  -> NULL + vpiError      duplicate in
 *                                                                  the digital
 *                                                                  domain
 *   vpi_register_analog_systf ($p02_both)  -> handle A, non-NULL   LEGAL: the
 *                                                                  other domain
 *   vpi_register_analog_systf ($p02_both)  -> NULL + vpiError      duplicate in
 *                                                                  the analog
 *                                                                  domain
 *
 * D and A are two different registrations of the same spelling, so
 * vpi_compare_objects(D, A) must be 0 — the LRM's "two sets of callbacks" is
 * two objects, not one object reached two ways, and 12.3 is the only routine
 * that can tell the difference. The two info round trips then show the two sets
 * are genuinely separate: D reports vpiSysFunction / vpiRealFunc and D's own
 * two function pointers, A reports vpiAnalogSysTask and A's.
 *
 * A failed registration must ALSO leave the successful one intact. After the
 * rejected duplicate, vpi_get_systf_info(D) is read again and must still report
 * D's own calltf — a tool that overwrote the entry and then reported failure
 * would pass a check that only looked at the return value.
 *
 * THE '$' RULE. "first character shall be `$`" is a `shall` on the application's
 * side of the interface, so a registration of "p02_nodollar" is a request the
 * implementation must refuse: NULL, with 12.2's error status set, rather than a
 * silently-accepted task no source can ever name. This is the one deliberate
 * refusal check in the P02 set.
 *
 * No design source is read: every assertion here is about the registration
 * table, and nothing it registers is ever called. The registrations, refused
 * ones included, are made from vlog_startup_routines; the comparison and the
 * read-backs wait for cbEndOfCompile, since IEEE 1364-2005 26.2.4 allows only
 * the registration routines at startup.
 */

//! lrm 11.2.3
//! lrm 12.2
//! lrm 12.3
//! lrm 12.13
//! lrm 12.14
//! lrm 12.32
//! lrm-reject 12.32
//! lrm 12.33
//! lrm-reject 12.33
//! lrm 12.33.2
//! lrm 11.2.3:1
//! lrm 11.2.3:2
//! lrm 12.2:1
//! lrm 12.3:2
//! lrm 12.13:1
//! lrm 12.32:3
//! lrm-reject 12.32:3
//! design analog_system_task_registration.va
//! stdout p02: 12_systf_domains checks=26

#include "p02_check.h"

static PLI_INT32 d_calltf(PLI_BYTE8 *u)    { (void)u; return 0; }
static PLI_INT32 d_compiletf(PLI_BYTE8 *u) { (void)u; return 0; }
static PLI_INT32 a_calltf(p_cb_data c)     { (void)c; return 0; }
static PLI_INT32 a_compiletf(p_cb_data c)  { (void)c; return 0; }

static vpiHandle d, a;

static void read_back(void)
{
  s_vpi_systf_data        dinfo;
  s_vpi_analog_systf_data ainfo;

  CHECK(vpi_compare_objects(d, a) == 0,
        "the two registrations are two sets of callbacks, so two objects");

  /* The refusals must not have damaged the two that succeeded. */
  memset(&dinfo, 0, sizeof dinfo);
  vpi_get_systf_info(d, &dinfo);
  expect_no_error("vpi_get_systf_info after a refused duplicate");
  CHECK(dinfo.type == vpiSysFunction, "the digital set is still a function");
  CHECK(dinfo.sysfunctype == vpiRealFunc, "and still vpiRealFunc");
  CHECK(dinfo.calltf == d_calltf, "and still carries its own calltf");
  CHECK(dinfo.user_data != NULL && strcmp(dinfo.user_data, "digital") == 0,
        "the refused duplicate must not have replaced user_data");

  memset(&ainfo, 0, sizeof ainfo);
  vpi_get_analog_systf_info(a, &ainfo);
  expect_no_error("vpi_get_analog_systf_info after a refused duplicate");
  CHECK(ainfo.type == vpiAnalogSysTask, "the analog set is still a task");
  CHECK(ainfo.calltf == a_calltf, "and still carries its own calltf");
  CHECK(ainfo.user_data != NULL && strcmp(ainfo.user_data, "analog") == 0,
        "the two domains must not share user_data");

  p02_done("12_systf_domains");
}

static void setup(void)
{
  static s_vpi_systf_data digital = {
    vpiSysFunction, vpiRealFunc, "$p02_both", d_calltf, d_compiletf, NULL, "digital"
  };
  static s_vpi_systf_data digital_again = {
    vpiSysFunction, vpiRealFunc, "$p02_both", d_calltf, d_compiletf, NULL, "dup"
  };
  static s_vpi_analog_systf_data analog = {
    vpiAnalogSysTask, 0, "$p02_both", a_calltf, a_compiletf, NULL, NULL, "analog"
  };
  static s_vpi_analog_systf_data analog_again = {
    vpiAnalogSysTask, 0, "$p02_both", a_calltf, a_compiletf, NULL, NULL, "dup"
  };
  static s_vpi_systf_data nodollar = {
    vpiSysTask, 0, "p02_nodollar", d_calltf, NULL, NULL, NULL
  };

  /* 1 — the digital registration. */
  d = vpi_register_systf(&digital);
  expect_no_error("vpi_register_systf($p02_both)");
  CHECK(d != NULL, "the first digital registration must succeed");

  /* 2 — the same name again, same domain. */
  CHECK(vpi_register_systf(&digital_again) == NULL,
        "a duplicate name in the digital domain must be refused");
  expect_error("duplicate vpi_register_systf");

  /* 3 — the same name in the other domain. */
  a = vpi_register_analog_systf(&analog);
  expect_no_error("vpi_register_analog_systf($p02_both)");
  CHECK(a != NULL,
        "12.32: the same name may be shared across the two domains");

  /* 4 — the same name again, analog domain. */
  CHECK(vpi_register_analog_systf(&analog_again) == NULL,
        "a duplicate name in the analog domain must be refused");
  expect_error("duplicate vpi_register_analog_systf");

  /* The '$' rule. */
  CHECK(vpi_register_systf(&nodollar) == NULL,
        "a tfname whose first character is not `$` must be refused");
  expect_error("vpi_register_systf with a tfname lacking `$`");

  /* IEEE 1364-2005 26.2.4: the two registrations are all a startup routine
   * may call; the comparisons and read-backs wait for cbEndOfCompile. */
  p02_defer(read_back);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
