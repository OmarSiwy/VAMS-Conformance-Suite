/* P03 — VAMS-2023 12.10 and Table 12-2: every format vpi_get_analog_value()
 * defines, and both of the buffer rules attached to it.
 *
 *   12.10  "The VPI routine vpi_get_analog_value() shall retrieve the
 *          simulation value of VPI analog vpiFlow or vpiPotential (node or
 *          branch) quantity objects. The value shall be placed in an
 *          s_vpi_analog_value structure, which has been allocated by the user.
 *          The format of the value shall be set by the format field of the
 *          structure."
 *   12.10  "The buffer this routine uses for string values shall be different
 *          from the buffer which vpi_get_str() shall use. The string buffer
 *          used by vpi_get_analog_value() is overwritten with each call. If the
 *          value is needed, it needs to be saved by the application."
 *   Table 12-2
 *          vpiRealVal   "Real and imaginary values of the object are returned
 *                        as doubles."
 *          vpiExpStrVal "Real and imaginary values of object are returned as
 *                        strings formatted like printf %e."
 *          vpiDecStrVal "Real and imaginary values of object are returned as
 *                        strings of decimal char(s) [0-9]"
 *          vpiStringVal "Real and imaginary parts are returned as strings
 *                        formatted like printf %g. The call shall reset the
 *                        format field to vpiExpStrVal or vpiDecStrVal to the
 *                        selected format."
 *
 * THE CIRCUIT AND THE ARITHMETIC. p03_dc_divider is one ideal 1.25 V source
 * across one 500 ohm resistor:
 *
 *     potential quantity of r1 = 1.25       V   exactly
 *     flow quantity of r1      = 1.25/500
 *                              = 2.5e-3     A   exactly
 *     imaginary part of both   = 0.0            (DC is not a small-signal
 *                                                analysis; 12.8 gives it no
 *                                                frequency, so there is no
 *                                                phase to carry)
 *
 * 1.25 was chosen because it is exact in binary64 AND has a short decimal
 * expansion, which is what lets this fixture assert the SPELLINGS and not just
 * the numbers:
 *
 *     %e of 1.25   -> "1.250000e+00"       %g of 1.25   -> "1.25"
 *     %e of 2.5e-3 -> "2.500000e-03"       %g of 2.5e-3 -> "0.0025"
 *     %e of 0.0    -> "0.000000e+00"
 *
 * Those strings are C's own, fixed by the C standard's %e and %g conversions,
 * which is precisely what "formatted like printf %e" delegates to. A fixture
 * that only read the doubles back would not notice an implementation that
 * ignored the format field entirely.
 *
 * THE TWO BUFFER RULES are the half of 12.10 an application gets wrong. A
 * vpi_get_str() call is made between saving an analog string and reading it: if
 * the two share a buffer, the saved pointer now names a hierarchical name and
 * the comparison fails. Then a second vpi_get_analog_value() on a different
 * quantity must overwrite the analog buffer — the clause says it does, so an
 * implementation that hands out a fresh allocation per call is also wrong, and
 * an application written against this clause would leak against it.
 *
 *! design   dc_divider.va
 *! analysis op
 *! expect   08_analog_value_formats.expected.txt
 */

//! lrm 12.10
//! lrm 12.12
//! lrm 12.10:1
//! lrm 12.10:2
//! lrm 12.10:3
//! lrm 12.10:4
//! lrm 12.10:5
//! lrm 12.10:7
//! lrm 12.10:1001
//! design dc_divider.va
//! stdout p03-08: v=1.25 i=0.0025 vexp=1.250000e+00 vdec=1.25 vg=1.25 fmt_reset=1 sep_buf=1 overwritten=1

#include "p03_vpi_analog.h"
#include <string.h>
#include <stdlib.h>

static char saved_exp[64], saved_g[64], saved_dec[64], saved_iexp[64], saved_flow[64];
static int fmt_reset, sep_buf, overwritten;
static double vreal, ireal, vimag;

static PLI_INT32 on_final(p_cb_data cb)
{
  vpiHandle vq, iq, mod;
  s_vpi_analog_value val;
  PLI_BYTE8 *p_analog;
  double im;
  (void)cb;

  vq = p03_quantity("p03_dc_divider.r1", vpiPotential);
  iq = p03_quantity("p03_dc_divider.r1", vpiFlow);

  /* Table 12-2, vpiRealVal. */
  vreal = p03_real_of(vq, &vimag);
  ireal = p03_real_of(iq, &im);
  P03_NEAR(vreal, 1.25,   0.0,   "12.10 vpiRealVal on the potential quantity");
  P03_NEAR(ireal, 2.5e-3, 1e-18, "12.10 vpiRealVal on the flow quantity");
  P03_CHECK(vimag == 0.0 && im == 0.0,
            "12.10: a DC solution has no imaginary part (got %.17g, %.17g)", vimag, im);

  /* Table 12-2, vpiExpStrVal: "formatted like printf %e". */
  val.format = vpiExpStrVal;
  vpi_get_analog_value(vq, &val);
  p03_no_error("vpi_get_analog_value(vpiExpStrVal)");
  P03_CHECK(val.real.str != NULL, "12.10 vpiExpStrVal returned a null real string");
  strncpy(saved_exp, (char *)val.real.str, sizeof saved_exp - 1);
  strncpy(saved_iexp, (char *)val.imaginary.str, sizeof saved_iexp - 1);
  p_analog = val.real.str;
  P03_CHECK(strcmp(saved_exp, "1.250000e+00") == 0,
            "Table 12-2 vpiExpStrVal: got `%s` want `1.250000e+00`", saved_exp);
  P03_CHECK(strcmp(saved_iexp, "0.000000e+00") == 0,
            "Table 12-2 vpiExpStrVal imaginary: got `%s` want `0.000000e+00`", saved_iexp);

  /* 12.10, buffer rule 1: a vpi_get_str() call must not disturb it. */
  mod = vpi_handle_by_name((PLI_BYTE8 *)"p03_dc_divider.r1", NULL);
  P03_CHECK(mod != NULL, "no instance p03_dc_divider.r1");
  (void)vpi_get_str(vpiFullName, mod);
  sep_buf = (strcmp((char *)p_analog, "1.250000e+00") == 0);
  P03_CHECK(sep_buf,
            "12.10: vpi_get_str() overwrote the analog string buffer (now `%s`)",
            (char *)p_analog);

  /* 12.10, buffer rule 2: the NEXT vpi_get_analog_value() overwrites it. */
  val.format = vpiExpStrVal;
  vpi_get_analog_value(iq, &val);
  strncpy(saved_flow, (char *)val.real.str, sizeof saved_flow - 1);
  P03_CHECK(strcmp(saved_flow, "2.500000e-03") == 0,
            "Table 12-2 vpiExpStrVal on the flow quantity: got `%s` want `2.500000e-03`",
            saved_flow);
  overwritten = (strcmp((char *)p_analog, "1.250000e+00") != 0);
  P03_CHECK(overwritten,
            "12.10: `the string buffer ... is overwritten with each call`, but the "
            "first result survived a second call");

  /* Table 12-2, vpiDecStrVal. The clause describes the character set, not the
   * exact spelling, so the assertion is the round trip — which is the property
   * an application actually depends on. */
  val.format = vpiDecStrVal;
  vpi_get_analog_value(vq, &val);
  strncpy(saved_dec, (char *)val.real.str, sizeof saved_dec - 1);
  P03_NEAR(strtod(saved_dec, NULL), 1.25, 0.0,
           "Table 12-2 vpiDecStrVal round trip");

  /* Table 12-2, vpiStringVal: "%g", and the format field is RESET. */
  val.format = vpiStringVal;
  vpi_get_analog_value(vq, &val);
  strncpy(saved_g, (char *)val.real.str, sizeof saved_g - 1);
  P03_CHECK(strcmp(saved_g, "1.25") == 0,
            "Table 12-2 vpiStringVal: got `%s` want `1.25`", saved_g);
  fmt_reset = (val.format == vpiExpStrVal || val.format == vpiDecStrVal);
  P03_CHECK(fmt_reset,
            "Table 12-2: `The call shall reset the format field to vpiExpStrVal or "
            "vpiDecStrVal`, but format is still %d", (int)val.format);

  printf("p03-08: v=%g i=%g vexp=%s vdec=%g vg=%s fmt_reset=%d sep_buf=%d overwritten=%d\n",
         vreal, ireal, saved_exp, strtod(saved_dec, NULL), saved_g,
         fmt_reset, sep_buf, overwritten);
  fflush(stdout);
  return 0;
}

static void p03_08_after_compile(void)
{
  static s_cb_data fin_cb;
  fin_cb.reason = acbFinalStep;
  fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_08_startup(void)
{
  p03_defer(p03_08_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_08_startup, 0 };
