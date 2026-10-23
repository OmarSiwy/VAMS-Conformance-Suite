/* Helpers shared by the P03 analog VPI fixtures.
 *
 * src/vpi/vpi_user.h supplies the public value, callback and system-function
 * interfaces. This compatibility header retains the fixture aliases and
 * assertion helpers below; it does not describe an unimplemented P03 phase.
 *
 * Three interface choices follow the normative structures where illustrative
 * listings differ:
 * - Figure 12-17 gives s_cb_data.time a pointer type. Each fixture owns an
 *   s_vpi_time and points at it, despite the embedded-field spelling in the
 *   §12.32.3 sampler example.
 * - §12.32.2 names the partials member derivative_wrt. The public header also
 *   accepts the derivative_to spelling used in the §12.22.2 example.
 * - The public analog systf callbacks take p_cb_data. Figure 12-18's
 *   unprototyped callbacks and the examples do not supply a consistent C
 *   prototype; p_cb_data carries the active call and user data.
 *
 * AMS §12.31 refers to the IEEE 1364 Annex G header for callback reason
 * constants; §12.2 describes vpi_chk_error and makes no such reference.
 * IEEE names retain Annex G's numbers. AMS-only names use the implementation
 * values declared in the public header; these fixtures assert behavior,
 * not those implementation-assigned numbers.
 */

#ifndef VERA_P03_VPI_ANALOG_H
#define VERA_P03_VPI_ANALOG_H

#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

/* ==========================================================================
 * IEEE 1364 Annex G numbering — names that already have a standard value.
 * ========================================================================== */

/* ==========================================================================
 * VerA ALLOCATION — names Verilog-AMS defines and gives no number to.
 *
 * Everything below this line is named by the LRM (§11.6.6, §11.6.7, §12.10,
 * §12.22.1, §12.31.3, §12.32) and numbered by VerA. 700+ is chosen to sit above
 * every 1364 Annex G object, property and reason so a full Annex G header can be
 * dropped in beside this one without a collision.
 * ========================================================================== */

/* §12.31.3 "Simulator analog and related callbacks", in the clause's order. */
#define acbInitialStep        701   /* "Upon acceptance of the first analog solution" */
#define acbFinalStep          702   /* "Upon acceptance of the last analog solution" */
#define acbAbsTime            703   /* "...for the given time (this callback shall force a solution at that time)" */
#define acbElapsedTime        704   /* "...advanced from the current solution by the given interval" */
#define acbConvergenceTest    705   /* "Prior acceptance ... allows rejection ... and backup to an earlier time" */
#define acbAcceptedPoint      706   /* "Upon acceptance of the solution at the given time" */

/* §12.10's vpiExpStrVal moved to src/vpi/vpi_user.h with the routine. */

/* §11.6.6/§11.6.7 object and relationship tags a quantity is reached through. */
#define vpiQuantity           720   /* §11.6.7 the Quantity object */
#define vpiBranchObj          721   /* §11.6.6 the branch object (Annex G's vpiBranch is not defined) */
#define vpiPotential          722   /* §11.6.6 branch bit -> Quantity via vpiPotential */
#define vpiFlow               723   /* §11.6.6 branch bit -> Quantity via vpiFlow; also §11.6.20's bool property */
#define vpiPosNode            724   /* §11.6.6 */
#define vpiNegNode            725   /* §11.6.6 */


/* ==========================================================================
 * Structures.
 * ========================================================================== */

/* Figure 12-3 (s_vpi_analog_value) moved to src/vpi/vpi_user.h. */

/* ==========================================================================
 * Routines.
 * ========================================================================== */

/* §12.7/§12.8/§12.9. All three take no arguments and return a double; all three
 * are defined to return 0 outside the analysis they describe. */
extern double    vpi_get_analog_delta(void);
extern double    vpi_get_analog_freq(void);
extern double    vpi_get_analog_time(void);

/* §12.10 vpi_get_analog_value() is declared by src/vpi/vpi_user.h. */

/* §12.28. */
extern PLI_INT32 vpi_printf(const PLI_BYTE8 *format, ...);

#ifdef __cplusplus
}
#endif

/* ==========================================================================
 * The plugins' shared self-check, same contract as tests/fixtures/ch11_vpi/vpi_app.c's: first
 * failure prints the check and exits 1, success prints one census line.
 * ========================================================================== */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* Not every plugin uses every helper, and a shared header full of statics
 * otherwise costs each of them a -Wunused-function. */
#if defined(__GNUC__) || defined(__clang__)
#  define P03_UNUSED __attribute__((unused))
#else
#  define P03_UNUSED
#endif

#define P03_FAIL(...)                                                         \
  do {                                                                        \
    fprintf(stderr, "p03: %s:%d: ", __FILE__, __LINE__);                      \
    fprintf(stderr, __VA_ARGS__);                                             \
    fprintf(stderr, "\n");                                                    \
    exit(1);                                                                  \
  } while (0)

#define P03_CHECK(cond, ...)                                                  \
  do { if (!(cond)) P03_FAIL(__VA_ARGS__); } while (0)

/* Every expected value in this directory is hand-derived and EXACT in exact
 * arithmetic; the tolerance is there for the solver's last bits only. */
#define P03_NEAR(got, want, tol, what)                                        \
  P03_CHECK(fabs((got) - (want)) <= (tol),                                    \
            "%s: got %.17g want %.17g (tol %g)", (what), (double)(got),       \
            (double)(want), (double)(tol))

/* §12.2, as tests/fixtures/ch11_vpi/vpi_app.c uses it: a call that must fail has to SAY so. */
static P03_UNUSED int p03_saw_error(const char *what)
{
  s_vpi_error_info info;
  if (vpi_chk_error(&info) != vpiError)
    P03_FAIL("%s should have set vpiError", what);
  P03_CHECK(info.state == vpiPLI, "%s: error state should be vpiPLI", what);
  P03_CHECK(info.code && info.code[0], "%s: error carries no code", what);
  P03_CHECK(info.message && info.message[0], "%s: error carries no message", what);
  return 1;
}

static P03_UNUSED void p03_no_error(const char *what)
{
  s_vpi_error_info info;
  if (vpi_chk_error(&info) != 0)
    P03_FAIL("%s unexpectedly set an error: %s: %s", what,
             info.code ? info.code : "(no code)",
             info.message ? info.message : "(no message)");
}

/* IEEE 1364-2005 26.2.4: a startup routine may call only
 * vpi_register_systf() (here, vpi_register_analog_systf()) and
 * vpi_register_cb() for cbEndOfCompile, cbStartOfSimulation,
 * cbEndOfSimulation, cbUnresolvedSystf, cbError and cbPLIError. The analog
 * callbacks and every other routine wait for cbEndOfCompile, where "all
 * functionality is available": p03_defer(fn) runs fn there
 * (specification/Vague_Decisions.md VD-044). One deferral per plugin. */
static P03_UNUSED void (*p03_deferred)(void);

static P03_UNUSED PLI_INT32 p03_run_deferred(p_cb_data d)
{
  (void)d;
  p03_deferred();
  return 0;
}

static P03_UNUSED void p03_defer(void (*fn)(void))
{
  static s_cb_data cb;
  p03_deferred = fn;
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = p03_run_deferred;
  P03_CHECK(vpi_register_cb(&cb) != NULL, "the cbEndOfCompile deferral failed to register");
}

/* §11.6.6/§11.6.7 in two lines: "the bit-level branch has tagged one-to-one
 * relationships ... to Quantity via vpiFlow, and to Quantity via vpiPotential",
 * and §11.6.7 gives Quantity its "real value"/"imaginary value" through
 * vpi_get_analog_value(). Every P03 fixture that reads a circuit value reaches
 * it this way — a NODE is not a quantity, and nothing in §11.6.5 gives a node a
 * value, so going through the branch of a known instance is the only route the
 * data model actually draws.
 *
 * `inst` is the full hierarchical name of a two-terminal instance; `tag` is
 * vpiPotential or vpiFlow. Not part of the interface: this is fixture code and
 * stays here when the declarations above move into src/vpi/vpi_user.h. */
static P03_UNUSED vpiHandle p03_quantity(const char *inst, PLI_INT32 tag)
{
  vpiHandle m, itr, br, q;
  /* Annex G's signature is mutable; the lookup does not modify this name. */
  m = vpi_handle_by_name((PLI_BYTE8 *)inst, NULL);
  P03_CHECK(m != NULL, "no instance named `%s`", inst);
  itr = vpi_iterate(vpiBranchObj, m);
  P03_CHECK(itr != NULL, "§11.6.6: `%s` has no branches", inst);
  br = vpi_scan(itr);
  P03_CHECK(br != NULL, "§11.6.6: `%s` has an empty branch iterator", inst);
  vpi_free_object(itr);
  q = vpi_handle(tag, br);
  P03_CHECK(q != NULL, "§11.6.6: branch of `%s` has no quantity for tag %d", inst, (int)tag);
  return q;
}

/* §12.10 with vpiRealVal: "Real and imaginary values of the object are returned
 * as doubles." Returns the real part and, when `im` is non-NULL, the imaginary
 * one. */
static P03_UNUSED double p03_real_of(vpiHandle q, double *im)
{
  s_vpi_analog_value v;
  v.format = vpiRealVal;
  vpi_get_analog_value(q, &v);
  p03_no_error("vpi_get_analog_value(vpiRealVal)");
  if (im) *im = v.imaginary.real;
  return v.real.real;
}

#endif /* VERA_P03_VPI_ANALOG_H */
