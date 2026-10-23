/* Shared scaffolding for the b_*.c IEEE 1364-2005 VPI applications: p02's
 * reporting contract (tests/fixtures/ch11_vpi/p02_check.h: exit 1 at the
 * first failed CHECK, one census line on success), plus XFAIL for a check
 * VerA is known to fail. Nothing normative lives here.
 */

#ifndef B_CHECK_H
#define B_CHECK_H

#include "../../verilog-ams/ch11_vpi/p02_check.h"

/* A requirement VerA does not meet yet: prints `xfail <clause>: <what>` on
 * stdout instead of exiting. The fixture's `//! stdout` pins that line, so the fix
 * changes the transcript and fails the run until the marker is removed. */
#define XFAIL(cond, clause, what)                                             \
  do {                                                                        \
    p02_checks++;                                                             \
    if (!(cond)) printf("xfail %s: %s\n", (clause), (what));                  \
  } while (0)

/* A refusal the previous call reported. 1364-2005 names no severity or state
 * for any refusal (§27.1 only has vpi_chk_error() return nonzero), so unlike
 * p02's expect_error() this accepts any level. */
static P02_UNUSED void expect_refusal(const char *what)
{
  p02_checks++;
  if (vpi_chk_error(NULL) == 0) {
    fprintf(stderr, "b: %s should have reported an error\n", what);
    exit(1);
  }
}

/* A refusal whose vpi_chk_error() message contains `needle`: for a call
 * that could be refused for another reason too, so the check pins which. The
 * wording is VerA's; the standard fixes none. */
static P02_UNUSED void expect_refusal_saying(const char *what, const char *needle)
{
  s_vpi_error_info info;
  p02_checks++;
  if (vpi_chk_error(&info) == 0 || info.message == NULL || strstr(info.message, needle) == NULL) {
    fprintf(stderr, "b: %s should have been refused for `%s`\n", what, needle);
    exit(1);
  }
}

#endif /* B_CHECK_H */
