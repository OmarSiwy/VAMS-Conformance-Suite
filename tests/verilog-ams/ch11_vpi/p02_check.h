/* Shared scaffolding for the P02 VPI applications. Nothing normative lives
 * here — every LRM claim is in the application that makes it.
 *
 * The reporting contract is tests/fixtures/ch11_vpi/vpi_app.c's, unchanged: an application is
 * entered only through LRM 12.33.2's `vlog_startup_routines`, reports by EXIT
 * CODE, calls exit(1) at its first failed check, and on success prints exactly
 * one census line. The census line is what proves the startup routine ran at
 * all, so a harness that asserts the line cannot be fooled by a table that was
 * never called.
 */

#ifndef P02_CHECK_H
#define P02_CHECK_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vpi_user.h"

/* Not every application uses every helper, and under the harness's -Wall
 * -Werror an unused `static` function is an error — the same reason
 * p03_vpi_analog.h marks its helpers P03_UNUSED. */
#if defined(__GNUC__) || defined(__clang__)
#  define P02_UNUSED __attribute__((unused))
#else
#  define P02_UNUSED
#endif

static int p02_checks = 0;

static P02_UNUSED void p02_report_error(void)
{
  s_vpi_error_info info;
  if (!vpi_chk_error(&info)) {
    fprintf(stderr, "  (vpi_chk_error reports no error)\n");
    return;
  }
  fprintf(stderr, "  vpi_chk_error: level=%d state=%d code=%s message=%s\n",
          info.level, info.state,
          info.code ? info.code : "(none)",
          info.message ? info.message : "(none)");
}

#define CHECK(cond, ...)                                                      \
  do {                                                                        \
    p02_checks++;                                                             \
    if (!(cond)) {                                                            \
      fprintf(stderr, "p02: %s:%d: ", __FILE__, __LINE__);                    \
      fprintf(stderr, __VA_ARGS__);                                           \
      fprintf(stderr, "\n  failed: %s\n", #cond);                             \
      p02_report_error();                                                     \
      exit(1);                                                                \
    }                                                                         \
  } while (0)

#define CHECK_STR(got, want, what)                                            \
  do {                                                                        \
    const char *g_ = (got);                                                   \
    CHECK(g_ != NULL, "%s: value.str is NULL", (what));                       \
    CHECK(strcmp(g_, (want)) == 0, "%s: got `%s`, want `%s`",                 \
          (what), g_, (want));                                                \
  } while (0)

/* 12.2: "The error status shall be reset by any VPI routine call except
 * vpi_chk_error()." Asserted after every call expected to SUCCEED, so a stale
 * error cannot make a later negative check pass for the wrong reason. */
static P02_UNUSED void expect_no_error(const char *what)
{
  s_vpi_error_info info;
  p02_checks++;
  if (vpi_chk_error(&info) != 0) {
    fprintf(stderr, "p02: %s unexpectedly set an error: code=%s message=%s\n",
            what, info.code ? info.code : "(none)",
            info.message ? info.message : "(none)");
    exit(1);
  }
}

static P02_UNUSED void expect_error(const char *what)
{
  s_vpi_error_info info;
  p02_checks++;
  if (vpi_chk_error(&info) != vpiError) {
    fprintf(stderr, "p02: %s should have set vpiError\n", what);
    exit(1);
  }
  CHECK(info.state == vpiPLI, "%s: error state should be vpiPLI", what);
  CHECK(info.code != NULL && info.code[0] != '\0', "%s: error carries no code", what);
}

/* Every P02 application resolves its objects by name from the top, because
 * 12.21's hierarchical form is the only way a standalone C file can name a
 * design object without depending on iteration order. */
static P02_UNUSED vpiHandle p02_by_name(const char *name)
{
  vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
  CHECK(h != NULL, "vpi_handle_by_name(\"%s\", NULL) returned NULL", name);
  expect_no_error("vpi_handle_by_name");
  return h;
}

/* IEEE 1364-2005 26.2.4: while vlog_startup_routines run, "Only two routines
 * can be called at this time": vpi_register_systf() and vpi_register_cb(),
 * the latter only for cbEndOfCompile, cbStartOfSimulation, cbEndOfSimulation,
 * cbUnresolvedSystf, cbError and cbPLIError. When cbEndOfCompile runs, "all
 * functionality is available". So a startup routine hands the rest of its
 * work to p02_defer(fn), which runs fn at cbEndOfCompile (docs/
 * Vague_Decisions.md VD-044). Not a CHECK: the census counts are the
 * application's own assertions. One deferral per application. */
static P02_UNUSED void (*p02_deferred)(void);

static P02_UNUSED PLI_INT32 p02_run_deferred(p_cb_data d)
{
  (void)d;
  p02_deferred();
  return 0;
}

static P02_UNUSED void p02_defer(void (*fn)(void))
{
  static s_cb_data cb;
  p02_deferred = fn;
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = p02_run_deferred;
  if (vpi_register_cb(&cb) == NULL) {
    fprintf(stderr, "p02: the cbEndOfCompile deferral failed to register\n");
    p02_report_error();
    exit(1);
  }
}

static P02_UNUSED void p02_done(const char *app)
{
  printf("p02: %s checks=%d\n", app, p02_checks);
  fflush(stdout);
}

#endif /* P02_CHECK_H */
