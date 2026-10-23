/* 02 — vpi_get_value() over a value that has x and z bits.
 *
 * This is where Table 12-4 stops being a formatting exercise. LRM 12.16,
 * Table 12-4, for vpiOctStrVal and vpiHexStrVal, defines FOUR characters and
 * distinguishes them by quantifier:
 *
 *   "x   When all the bits are x
 *    X   When some of the bits are x
 *    z   When all the bits are z
 *    Z   When some of the bits are z"
 *
 * — where "the bits" are the bits of the one octal or hex DIGIT being printed,
 * not of the whole value. A lowercase digit therefore means a uniform group and
 * an uppercase one means a mixed group, and an implementation that prints x for
 * both is wrong in a way no all-known fixture can see.
 *
 * Table 12-4, for vpiIntVal: "Integer value of the handle. Any bits x or z in
 * the value of the object are mapped to a 0".
 *
 * LRM 12.16, Figure 12-10: "bit encoding: ab: 00=0, 10=1, 11=X, 01=Z" — so
 * `aval` carries the bits that are 1 or X, and `bval` carries the bits that are
 * X or Z. A value with no unknowns cannot tell those two apart; this one can.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * p02_design.unknown is `reg [11:0]` = 12'b1010_zzzz_01x1, i.e.
 *
 *   index   11 10  9  8   7  6  5  4   3  2  1  0
 *   value    1  0  1  0   z  z  z  z   0  1  x  1
 *
 *   vpiBinStrVal  one character per bit, msb first -> "1010zzzz01x1"
 *
 *   vpiHexStrVal  three nibbles, msb first:
 *                   [11:8] = 1010          -> 'a'
 *                   [ 7:4] = zzzz          -> all z            -> 'z'
 *                   [ 3:0] = 01x1          -> some bits are x  -> 'X'
 *                                                        -> "azX"
 *
 *   vpiOctStrVal  four 3-bit groups from the lsb:
 *                   [ 2:0] = 1,x,1  (bits 2,1,0) -> some x     -> 'X'
 *                   [ 5:3] = z,z,0  (bits 5,4,3) -> some z     -> 'Z'
 *                   [ 8:6] = 0,z,z  (bits 8,7,6) -> some z     -> 'Z'
 *                   [11:9] = 1,0,1               -> 5
 *                                                        -> "5ZZX"
 *
 *   vpiIntVal     every x and z becomes 0:
 *                   1010 0000 0101 = 0xa05 = 2560 + 5 = 2565
 *
 *   vpiVectorVal  array_size = ((12-1)/32 + 1) = 1
 *                   aval = bits that are 1 or X = {11, 9, 2, 1, 0}
 *                        = 1010 0000 0111 = 0xa07 = 2567
 *                   bval = bits that are X or Z = {7, 6, 5, 4, 1}
 *                        = 0000 1111 0010 = 0x0f2 = 242
 *                 Note aval != the vpiIntVal answer (0xa07 vs 0xa05): bit 1 is
 *                 x, which sets aval's bit 1 but maps to 0 for vpiIntVal. That
 *                 difference is the point of asserting both.
 *
 * p02_design.bitz is a scalar `reg` holding 1'bz:
 *   vpiScalarVal -> vpiZ; vpiBinStrVal -> "z"; vpiIntVal -> 0 (z maps to 0);
 *   vpiVectorVal -> aval = 0, bval = 1, by the ab encoding 01 = Z.
 *
 * WHEN: cbReadOnlySynch at t=0, after the `initial` block that writes them —
 * same reasoning as 01_get_value_formats.c.
 */

//! lrm 11.6.9
//! lrm 12.2
//! lrm 12.5
//! lrm 12.16
//! lrm 12.21
//! lrm 12.31.2
//! lrm 12.33.2
//! lrm 12.16:5
//! design ../digital/design.v
//! stdout p02: 02_get_value_unknown checks=21
//! stdout p02_design: t=20 reached

#include "p02_check.h"

static int read_unknowns(p_cb_data cb_data)
{
  s_vpi_value v;
  vpiHandle unknown, bitz;

  (void)cb_data;

  unknown = p02_by_name("p02_design.unknown");
  bitz    = p02_by_name("p02_design.bitz");

  CHECK(vpi_get(vpiSize, unknown) == 12, "unknown should be 12 bits");

  v.format = vpiBinStrVal;
  vpi_get_value(unknown, &v);
  expect_no_error("vpi_get_value on a value with x and z");
  CHECK_STR(v.value.str, "1010zzzz01x1", "unknown as binary");

  /* The uppercase/lowercase distinction of Table 12-4, both ways in one
   * string: 'z' is a nibble that is entirely z, 'X' is a nibble that is only
   * partly x. */
  v.format = vpiHexStrVal;
  vpi_get_value(unknown, &v);
  CHECK_STR(v.value.str, "azX", "unknown as hex");

  v.format = vpiOctStrVal;
  vpi_get_value(unknown, &v);
  CHECK_STR(v.value.str, "5ZZX", "unknown as octal");

  v.format = vpiIntVal;
  vpi_get_value(unknown, &v);
  CHECK(v.value.integer == 2565,
        "x and z must map to 0, giving 0xa05 = 2565, got %d", (int)v.value.integer);

  v.format = vpiVectorVal;
  vpi_get_value(unknown, &v);
  CHECK(v.value.vector[0].aval == 0xa07u,
        "aval carries the 1 and X bits: want 0xa07, got 0x%x",
        (unsigned)v.value.vector[0].aval);
  CHECK(v.value.vector[0].bval == 0x0f2u,
        "bval carries the X and Z bits: want 0x0f2, got 0x%x",
        (unsigned)v.value.vector[0].bval);

  /* The scalar z. */
  v.format = vpiScalarVal;
  vpi_get_value(bitz, &v);
  CHECK(v.value.scalar == vpiZ, "bitz as vpiScalarVal should be vpiZ");

  v.format = vpiBinStrVal;
  vpi_get_value(bitz, &v);
  CHECK_STR(v.value.str, "z", "bitz as binary");

  v.format = vpiIntVal;
  vpi_get_value(bitz, &v);
  CHECK(v.value.integer == 0, "a z bit maps to 0 for vpiIntVal");

  v.format = vpiVectorVal;
  vpi_get_value(bitz, &v);
  CHECK(v.value.vector[0].aval == 0u && v.value.vector[0].bval == 1u,
        "the ab encoding of Z is 01: aval=0 bval=1, got a=%u b=%u",
        (unsigned)v.value.vector[0].aval, (unsigned)v.value.vector[0].bval);

  p02_done("02_get_value_unknown");
  return 0;
}

static void setup_after_compile(void)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data  cb;

  cb.reason    = cbReadOnlySynch;
  cb.cb_rtn    = read_unknowns;
  cb.obj       = NULL;
  cb.time      = &t;
  cb.value     = NULL;
  cb.index     = 0;
  cb.user_data = NULL;

  CHECK(vpi_register_cb(&cb) != NULL, "cbReadOnlySynch(0) registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
