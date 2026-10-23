/* P03 — VAMS-2023 12.8 and 12.10: the small-signal half of the analog VPI.
 *
 *   12.8   "The VPI routine vpi_get_analog_freq() shall be used determine the
 *          current frequency used in the small-signal analysis. The function
 *          shall return zero (0) during DC or transient analysis."
 *   12.10  "shall retrieve the simulation value of VPI analog vpiFlow or
 *          vpiPotential (node or branch) quantity objects", into Figure 12-3's
 *          structure, which carries a `real` union AND an `imaginary` one.
 *   11.6.7 gives a Quantity both a "real value" and an "imaginary value", both
 *          through vpi_get_analog_value().
 *
 * The imaginary union is the only place in the interface where a small-signal
 * solution can be read at all, and it is the half an implementation silently
 * leaves at zero. So this fixture needs a circuit whose phase is not 0 and not
 * 90 degrees, and whose rectangular components are exact decimals.
 *
 * THE HAND DERIVATION. p03_rc_ac injects 1 A into node a, loaded by R = 1 kohm
 * in parallel with C = 1e-3/(2*pi*1e3). At f = 1 kHz:
 *
 *     wC = 2*pi*1e3 * 1e-3/(2*pi*1e3) = 1e-3 = 1/R
 *     Y  = 1/R + jwC = 1e-3 * (1 + j)
 *     V(a) = 1 / Y = 1000/(1 + j) = 1000*(1 - j)/2
 *
 *     real part      = +500.0 V     exactly
 *     imaginary part = -500.0 V     exactly
 *     (magnitude 500*sqrt(2) = 707.1067811865476, phase -45 degrees)
 *
 * The 45-degree point is chosen for exactly this: a swapped real/imaginary pair
 * has the right magnitude and the wrong sign, and a sign-flipped imaginary part
 * has the right magnitude too — so magnitude alone would pass three wrong
 * implementations. The signed rectangular pair passes one.
 *
 * The DC half is 12.8's own sentence. This deck's large-signal solution is
 * identically zero (ac_stim contributes nothing to it, 4.5.11), and at that
 * solution vpi_get_analog_freq() must be 0. Both observations are required
 * before the fixture prints: an implementation that returns 0 always satisfies
 * the DC check and fails the AC one, and one that returns a stale 1000 through
 * the DC solve fails the DC one.
 *
 * WHAT THIS FIXTURE DOES NOT CLAIM. 12.31.3 defines no callback reason whose
 * subject is "one frequency of a small-signal sweep". The plugin therefore
 * watches acbInitialStep, acbAcceptedPoint and acbFinalStep together and reads
 * vpi_get_analog_freq() to learn which kind of solution it is standing on —
 * which is what 12.8 is FOR. Pinning a per-frequency callback reason would
 * require inventing one, and this row does not invent callbacks.
 *
 *! design   rc_ac.va
 *! analysis op
 *! analysis ac 1000 1000 1
 *! expect   09_ac_freq_and_imaginary.expected.txt
 */

//! lrm 12.8
//! lrm 12.8:1
//! lrm 12.8:2
//! lrm 12.10
//! lrm 12.10:1
//! lrm 12.31.3
//! design rc_ac.va
//! stdout p03-09: f_dc=0 f_ac=1000 re=500 im=-500 dc_re=0

#include "p03_vpi_analog.h"

static int saw_dc, saw_ac;
static double ac_re, ac_im, dc_re, dc_im;

static PLI_INT32 observe(p_cb_data cb)
{
  double f = vpi_get_analog_freq();
  vpiHandle vq;
  double re, im;
  (void)cb;
  p03_no_error("vpi_get_analog_freq()");

  vq = p03_quantity("p03_rc_ac.r1", vpiPotential);
  re = p03_real_of(vq, &im);

  if (f == 0.0) {
    /* 12.8's "zero (0) during DC or transient analysis". */
    saw_dc = 1;
    dc_re = re;
    dc_im = im;
    P03_NEAR(dc_re, 0.0, 1e-12, "the large-signal solution of p03_rc_ac");
    P03_CHECK(dc_im == 0.0,
              "12.10: a DC solution has no imaginary part, got %.17g", dc_im);
  } else {
    saw_ac = 1;
    P03_NEAR(f, 1000.0, 0.0, "12.8 the small-signal frequency");
    ac_re = re;
    ac_im = im;
    P03_NEAR(ac_re,  500.0, 1e-9, "Re V(a) at 1 kHz: 1000/(1+j) = 500 - 500j");
    P03_NEAR(ac_im, -500.0, 1e-9, "Im V(a) at 1 kHz: 1000/(1+j) = 500 - 500j");
  }
  return 0;
}

static PLI_INT32 on_end(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(saw_dc, "12.8: no solution was observed with freq == 0");
  P03_CHECK(saw_ac, "12.8: no small-signal solution was observed at all");
  printf("p03-09: f_dc=%g f_ac=%g re=%g im=%g dc_re=%g\n",
         0.0, 1000.0, ac_re, ac_im, dc_re);
  fflush(stdout);
  return 0;
}

static void p03_09_after_compile(void)
{
  static s_cb_data icb, acb, fcb, ecb;
  icb.reason = acbInitialStep;   icb.cb_rtn = observe;
  acb.reason = acbAcceptedPoint; acb.cb_rtn = observe;
  fcb.reason = acbFinalStep;     fcb.cb_rtn = observe;
  ecb.reason = cbEndOfSimulation; ecb.cb_rtn = on_end;
  P03_CHECK(vpi_register_cb(&icb) != NULL, "acbInitialStep registration failed");
  P03_CHECK(vpi_register_cb(&acb) != NULL, "acbAcceptedPoint registration failed");
  P03_CHECK(vpi_register_cb(&fcb) != NULL, "acbFinalStep registration failed");
  P03_CHECK(vpi_register_cb(&ecb) != NULL, "cbEndOfSimulation registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p03_defer). */
static void p03_09_startup(void)
{
  p03_defer(p03_09_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_09_startup, 0 };
