/* 01 — vpi_get_value() over every Table 12-4 format a fully-known value has.
 *
 * LRM 12.16: "The VPI routine vpi_get_value() shall retrieve the simulation
 * value of VPI objects ... The value shall be placed in an s_vpi_value
 * structure, which has been allocated by the user. The format of the value
 * shall be set by the `format` field of the structure."
 *
 * LRM 12.16, on vpiObjTypeVal: "the routine shall fill in the value and change
 * the format field based on the object type, as follows: For an integer,
 * vpiIntVal. For a real, vpiRealVal. For a scalar, either vpiScalar or
 * vpiStrength. For a time variable, vpiTimeVal with vpiSimTime. For a vector,
 * vpiVectorVal."
 *
 * LRM 12.16, on the vector layout: "For vectors, the p_vpi_vecval field shall
 * point to an array of s_vpi_vecval structures. The size of this array shall be
 * determined by the size of the vector, where array_size = ((vector_size-1)/32
 * + 1). The lsb of the vector shall be represented by the lsb of the 0-indexed
 * element of s_vpi_vecval array. The 33rd bit of the vector shall be
 * represented by the lsb of the 1-indexed element of the array, and so on."
 *
 * LRM 12.16, on lifetime: "The memory for the union members str, time, vector,
 * strength, and misc ... shall be provided by the routine vpi_get_value(). This
 * memory shall only be valid until the next call to vpi_get_value()." And:
 * "The buffer this routine uses for string values shall be different from the
 * buffer which vpi_get_str() shall use."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * p02_design.known is `reg [11:0]`, assigned 12'b1010_0111_0001 at t=0. That
 * bit pattern, by hand:
 *
 *   binary   1010 0111 0001                     -> "101001110001"  (12 chars,
 *                                                   one per bit of vpiSize)
 *   octal    12 bits / 3 = 4 digits, grouped from the lsb:
 *              [11:9]=101=5  [8:6]=001=1  [5:3]=110=6  [2:0]=001=1
 *                                                -> "5161"
 *              cross-check 5*512 + 1*64 + 6*8 + 1 = 2560+64+48+1 = 2673
 *   decimal  2048+512+64+32+16+1 = 2673          -> "2673"
 *   hex      12 bits / 4 = 3 digits: 1010=a 0111=7 0001=1
 *                                                -> "a71"
 *   vpiIntVal   2673
 *   vpiRealVal  2673.0 exactly — 2673 < 2^53, so the double is not approximate
 *               and `== 2673.0` is a legal comparison rather than a tolerance.
 *   vpiVectorVal array_size = ((12-1)/32 + 1) = 1.
 *               No bit is x or z, so bval = 0 and aval = the value = 0xa71.
 *   vpiObjTypeVal -> format rewritten to vpiVectorVal (`known` is a vector).
 *
 * p02_design.wide is `reg [63:0]` = 64'h00000001FFFFFFFF. It exists only to
 * pin the "33rd bit is the lsb of the 1-indexed element" sentence:
 *
 *   array_size = ((64-1)/32 + 1) = 2
 *   vector[0].aval = 0xFFFFFFFF   (bits 31:0, all ones)
 *   vector[1].aval = 0x00000001   (bits 63:32, only bit 32 set)
 *   both bval = 0
 *
 * The same `wide` as vpiIntVal. Table 12-4: "Integer value of the handle",
 * and value.integer is a PLI_INT32, which 64 bits do not fit. VerA keeps the
 * low 32 bits, two's complement (specification/Vague_Decisions.md VD-049; IEEE
 * 1364-2005 5.6's rule for storing a wide value in a narrower integer, with
 * no diagnostic): bits 31:0 are 0xFFFFFFFF, so value.integer == -1. A tool
 * that saturated would give 0x7FFFFFFF, and one that refused would set an
 * error; the full value stays readable through vpiVectorVal above. The width
 * has no invalid form under this reading (refusing it would refuse every
 * `time` read), so no refusal is paired with it; Table 12-4's refusals are
 * a format the object cannot take (value_time_refusals.c,
 * ieee_pli/values.c).
 *
 * p02_design.text is `reg [39:0]` = 40'h5665724121. Table 12-4 for
 * vpiStringVal: "A string where each 8-bit group of the value of the object is
 * assumed to represent an ASCII character". 40 bits = 5 groups, msb group
 * first: 0x56='V' 0x65='e' 0x72='r' 0x41='A' 0x21='!' -> "VerA!". The hex
 * string of the same object, 40/4 = 10 digits, is "5665724121", which is the
 * same fact read two ways and is why both are asserted.
 *
 * p02_design.bit1 is a scalar `reg` holding 1'b1: vpiScalarVal -> vpi1,
 * vpiBinStrVal -> "1", vpiIntVal -> 1. vpiObjTypeVal on it rewrites the format
 * to EITHER of the two 12.16 names for a scalar: "For a scalar, either
 * vpiScalar or vpiStrength" (Annex G's format constants vpiScalarVal and
 * vpiStrengthVal — see tests/fixtures/ch11_vpi/p02_SPEC.md at 8b1514d4). The
 * choice is the routine's, so both are accepted, and the value is vpi1 read
 * through whichever member that format names (value.scalar, or the logic of
 * value.strength[0]). (Reconciler, 2026-10-08: an earlier revision demanded
 * vpiScalarVal alone, which a routine taking 12.16's other branch would fail.)
 *
 * WHEN. All of the above are assigned by an `initial` block, so they are only
 * true AFTER the time-0 queue has run. 12.31.2: "cbReadOnlySynch ... Callback
 * shall occur after execution of events for a specified time." This
 * application therefore reads at cbReadOnlySynch(t=0), not at
 * cbStartOfSimulation, which 12.31.4 puts at the BEGINNING of time 0.
 */

//! lrm 11.6.9
//! lrm 12.2
//! lrm 12.5
//! lrm 12.12
//! lrm 12.16
//! lrm 12.21
//! lrm 12.31.2
//! lrm 12.33.2
//! inherited IEEE 1364-2005 27.14
//! lrm 12.2:2
//! lrm 12.5:1
//! lrm 12.12:1
//! lrm 12.12:3
//! lrm 12.16:1
//! lrm 12.16:2
//! lrm 12.16:3
//! lrm 12.16:5
//! lrm 12.16:6
//! lrm 12.16:7
//! lrm 12.16:8
//! lrm 12.16:9
//! lrm 12.21:1
//! lrm 12.21:2
//! lrm 12.33.2:1
//! lrm 12.33.2:2
//! lrm 12.33.2:4
//! design ../digital/design.v
//! stdout p02: 01_get_value_formats checks=50
//! stdout p02_design: t=20 reached

#include "p02_check.h"

static int read_values(p_cb_data cb_data)
{
  s_vpi_value v;
  vpiHandle known, wide, text, bit1;
  char saved[64];

  (void)cb_data;

  known = p02_by_name("p02_design.known");
  wide  = p02_by_name("p02_design.wide");
  text  = p02_by_name("p02_design.text");
  bit1  = p02_by_name("p02_design.bit1");

  CHECK(vpi_get(vpiSize, known) == 12, "known should be 12 bits");

  /* --- the four string formats of Table 12-4 ------------------------------ */
  v.format = vpiBinStrVal;
  vpi_get_value(known, &v);
  expect_no_error("vpi_get_value(vpiBinStrVal)");
  CHECK(v.format == vpiBinStrVal, "vpi_get_value must not rewrite an explicit format");
  CHECK_STR(v.value.str, "101001110001", "known as binary");

  v.format = vpiOctStrVal;
  vpi_get_value(known, &v);
  CHECK_STR(v.value.str, "5161", "known as octal");

  v.format = vpiDecStrVal;
  vpi_get_value(known, &v);
  CHECK_STR(v.value.str, "2673", "known as decimal");

  v.format = vpiHexStrVal;
  vpi_get_value(known, &v);
  CHECK_STR(v.value.str, "a71", "known as hex");

  /* 12.16: the string buffer "is overwritten with each call. If the value is
   * needed, it needs to be saved by the application." Saved here, then a
   * further call is made, then the SAVED copy is re-checked — an
   * implementation that handed out per-call storage would pass this too, but
   * one that handed out a pointer into the object's live value would not. */
  strcpy(saved, v.value.str);
  v.format = vpiBinStrVal;
  vpi_get_value(known, &v);
  CHECK(strcmp(saved, "a71") == 0, "the application's own copy was clobbered");

  /* 12.16: "The buffer this routine uses for string values shall be different
   * from the buffer which vpi_get_str() shall use." */
  v.format = vpiHexStrVal;
  vpi_get_value(known, &v);
  {
    char *name = vpi_get_str(vpiName, known);
    CHECK(strcmp(name, "known") == 0, "vpi_get_str(vpiName) should be `known`");
    CHECK_STR(v.value.str, "a71", "vpi_get_str() overwrote vpi_get_value()'s buffer");
  }

  /* --- the scalar-carrying formats --------------------------------------- */
  v.format = vpiIntVal;
  vpi_get_value(known, &v);
  CHECK(v.value.integer == 2673, "known as vpiIntVal should be 2673, got %d",
        (int)v.value.integer);

  v.format = vpiRealVal;
  vpi_get_value(known, &v);
  CHECK(v.value.real == 2673.0, "known as vpiRealVal should be exactly 2673.0");

  /* --- vpiVectorVal, one element ------------------------------------------ */
  v.format = vpiVectorVal;
  vpi_get_value(known, &v);
  CHECK(v.value.vector != NULL, "vpiVectorVal must supply the array");
  CHECK(v.value.vector[0].aval == 0xa71u, "known aval should be 0xa71, got 0x%x",
        (unsigned)v.value.vector[0].aval);
  CHECK(v.value.vector[0].bval == 0u, "known has no x or z, so bval must be 0");

  /* --- vpiVectorVal, two elements: the 33rd-bit sentence ------------------ */
  CHECK(vpi_get(vpiSize, wide) == 64, "wide should be 64 bits");
  v.format = vpiVectorVal;
  vpi_get_value(wide, &v);
  CHECK(v.value.vector[0].aval == 0xFFFFFFFFu,
        "wide[31:0] should be 0xFFFFFFFF, got 0x%x", (unsigned)v.value.vector[0].aval);
  CHECK(v.value.vector[0].bval == 0u, "wide[31:0] has no x or z");
  CHECK(v.value.vector[1].aval == 0x00000001u,
        "wide[63:32] should be 0x00000001, got 0x%x", (unsigned)v.value.vector[1].aval);
  CHECK(v.value.vector[1].bval == 0u, "wide[63:32] has no x or z");
  v.format = vpiIntVal;
  vpi_get_value(wide, &v);
  expect_no_error("vpi_get_value(wide, vpiIntVal)");
  CHECK(v.value.integer == (PLI_INT32)0xFFFFFFFFu,
        "wide as vpiIntVal keeps bits 31:0, -1, got %d", (int)v.value.integer);

  /* --- vpiStringVal, and the same bits as hex ---------------------------- */
  CHECK(vpi_get(vpiSize, text) == 40, "text should be 40 bits");
  v.format = vpiStringVal;
  vpi_get_value(text, &v);
  CHECK_STR(v.value.str, "VerA!", "text as ASCII");
  v.format = vpiHexStrVal;
  vpi_get_value(text, &v);
  CHECK_STR(v.value.str, "5665724121", "text as hex");

  /* --- the scalar object -------------------------------------------------- */
  CHECK(vpi_get(vpiSize, bit1) == 1, "bit1 should be 1 bit");
  v.format = vpiScalarVal;
  vpi_get_value(bit1, &v);
  CHECK(v.value.scalar == vpi1, "bit1 as vpiScalarVal should be vpi1");
  v.format = vpiBinStrVal;
  vpi_get_value(bit1, &v);
  CHECK_STR(v.value.str, "1", "bit1 as binary");
  v.format = vpiIntVal;
  vpi_get_value(bit1, &v);
  CHECK(v.value.integer == 1, "bit1 as vpiIntVal should be 1");

  /* --- vpiObjTypeVal rewrites `format` ------------------------------------ */
  v.format = vpiObjTypeVal;
  vpi_get_value(known, &v);
  CHECK(v.format == vpiVectorVal,
        "vpiObjTypeVal on a vector must become vpiVectorVal, got %d", (int)v.format);
  CHECK(v.value.vector[0].aval == 0xa71u, "and must carry the value it named");

  v.format = vpiObjTypeVal;
  vpi_get_value(bit1, &v);
  CHECK(v.format == vpiScalarVal || v.format == vpiStrengthVal,
        "vpiObjTypeVal on a scalar must become vpiScalarVal or vpiStrengthVal, got %d",
        (int)v.format);
  CHECK((v.format == vpiScalarVal && v.value.scalar == vpi1) ||
            (v.format == vpiStrengthVal && v.value.strength != NULL &&
             v.value.strength[0].logic == vpi1),
        "and must carry vpi1");

  p02_done("01_get_value_formats");
  return 0;
}

static void setup_after_compile(void)
{
  static s_vpi_time  t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data   cb;

  cb.reason    = cbReadOnlySynch;
  cb.cb_rtn    = read_values;
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
