/* 09 — vpi_printf() and the multichannel descriptor family.
 *
 * LRM 12.28: "The VPI routine vpi_printf() shall write to both stdout and the
 * current product log file. The format string shall use the same format as the
 * C printf() routine. The routine shall return the number of characters printed
 * or EOF if an error occurred."
 *
 * LRM 12.26: "The VPI routine vpi_mcd_open() shall open a file for writing and
 * return a corresponding multichannel descriptor number (mcd). The following
 * channel descriptors are predefined and shall be automatically opened by the
 * system: Descriptor 1 is stdout. Descriptor 2 is stderr. Descriptor 3 is the
 * current log file. The vpi_mcd_open() routine shall return a zero (0) on
 * error. If the file is already opened, vpi_mcd_open() shall return the
 * descriptor number."
 *
 * LRM 12.27: "The VPI routine vpi_mcd_printf() shall write to one or more
 * channels (up to 32) determined by the mcd. An mcd of 1 (bit 0 set)
 * corresponds to Channel 1, a mcd of 2 (bit 1 set) corresponds to Channel 2, a
 * mcd of 4 (bit 2 set) corresponds to Channel 3, and so on. ... The routine
 * shall return the number of characters printed or EOF if an error occurred."
 *
 * LRM 12.24: "The VPI routine vpi_mcd_close() shall close the file(s) specified
 * by a multichannel descriptor, mcd. ... On success this routine returns a zero
 * (0); on error it returns the mcd value of the unclosed channels. The
 * following descriptors are predefined and can not be closed using
 * vpi_mcd_close(): descriptor 1 is stdout, descriptor 2 is stderr, descriptor 3
 * is the current log file."
 *
 * LRM 12.25: "The VPI routine vpi_mcd_name() shall return the name of a file
 * represented by a single-channel descriptor, cd. On error, the routine shall
 * return NULL. This routine shall overwrite the returned value on subsequent
 * calls."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * CHARACTER COUNTS are straight string lengths of the EXPANDED format:
 *
 *   vpi_printf("p02 printf %d %s\n", 7, "ok")
 *     expands to "p02 printf 7 ok\n" = 16 characters   -> returns 16
 *   vpi_mcd_printf(a, "alpha\n")      = 6 characters   -> returns 6
 *   vpi_mcd_printf(a|b, "both\n")     = 5 characters   -> returns 5
 *
 * DESCRIPTOR NUMBERS. 12.27 fixes the bit mapping (channel N is bit N-1) and
 * 12.26 reserves channels 1, 2 and 3. The first channel an application can be
 * given is therefore channel 4, whose mcd is 1<<3 = 8, and the second is
 * channel 5, mcd 1<<4 = 16. That is a derivation from two sentences rather than
 * one sentence quoted, and it is flagged as such in tests/fixtures/ch11_vpi/p02_SPEC.md at 8b1514d4; what is beyond
 * argument, and is asserted separately below, is that neither descriptor may
 * collide with the reserved 0x7.
 *
 * CLOSING THE RESERVED CHANNELS. vpi_mcd_close(0x7) names channels 1, 2 and 3,
 * all three of which "can not be closed". 12.24 says the failure return is "the
 * mcd value of the unclosed channels", and all three are unclosed, so the
 * return is 0x7 exactly. A return of 0 would be a claim to have closed stdout.
 *
 * FILE CONTENTS. Channel A receives "alpha\n" and then, as part of the two-
 * channel write, "both\n"; channel B receives only "both\n". After both are
 * closed, the files on disk must read exactly "alpha\nboth\n" (11 bytes) and
 * "both\n" (5 bytes). This is the only check that distinguishes "wrote to one
 * of the two channels" from "wrote to both".
 *
 * WHEN. cbEndOfCompile: none of this needs a simulation. The design still runs
 * to completion afterwards, so this application's expected stdout transcript
 * has three lines, listed in tests/fixtures/ch11_vpi/p02_SPEC.md at 8b1514d4.
 */

//! lrm 12.2
//! lrm 12.24
//! lrm-reject 12.24
//! lrm 12.25
//! lrm-reject 12.25
//! lrm 12.26
//! lrm 12.27
//! lrm 12.28
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 12.24:1
//! lrm-reject 12.24:1
//! lrm 12.25:1
//! lrm-reject 12.25:2
//! lrm 12.26:1
//! lrm 12.26:2
//! lrm 12.26:3
//! lrm 12.27:1
//! lrm 12.27:2
//! lrm 12.28:2
//! lrm 12.28:3
//! design ../digital/design.v
//! stdout p02 printf 7 ok
//! stdout p02: 09_printf_mcd checks=29
//! stdout p02_design: t=20 reached

#include "p02_check.h"

#define NAME_A "p02_mcd_a.log"
#define NAME_B "p02_mcd_b.log"

static void expect_file(const char *path, const char *want)
{
  char buf[64];
  size_t got;
  FILE *f = fopen(path, "rb");
  CHECK(f != NULL, "%s was never created", path);
  got = fread(buf, 1, sizeof buf - 1, f);
  fclose(f);
  buf[got] = '\0';
  CHECK(got == strlen(want),
        "%s should hold %zu bytes, holds %zu", path, strlen(want), got);
  CHECK(strcmp(buf, want) == 0, "%s should hold `%s`, holds `%s`", path, want, buf);
}

static int run(p_cb_data cb_data)
{
  PLI_UINT32 a, b, again;
  char saved[64];
  char *name;
  (void)cb_data;

  remove(NAME_A);
  remove(NAME_B);

  /* --- 12.28 ------------------------------------------------------------- */
  CHECK(vpi_printf("p02 printf %d %s\n", 7, "ok") == 16,
        "vpi_printf must return the 16 characters of `p02 printf 7 ok\\n`");
  /* 12.28 gives vpi_printf C's printf, which bounds no precision: 0.5 at
   * %.100f is "0.5" and 99 zeros, 102 characters. Channel 3, the log, takes
   * the text and discards it (see src/vpi/print.zig), so the count is all
   * that shows. */
  CHECK(vpi_mcd_printf(0x4u, "%.100f", 0.5) == 102,
        "a %%.100f conversion must print 102 characters, not a clamped count");
  CHECK(vpi_mcd_printf(0x4u, "%.60e", 1.0) == 66,
        "a %%.60e conversion must print 66 characters: 1. 60 zeros e+00");

  /* --- 12.24: the reserved channels ------------------------------------- */
  CHECK(vpi_mcd_close(0x7u) == 0x7u,
        "channels 1, 2 and 3 cannot be closed, so all three come back unclosed");

  /* --- 12.26 ------------------------------------------------------------- */
  a = vpi_mcd_open(NAME_A);
  expect_no_error("vpi_mcd_open");
  CHECK(a != 0, "vpi_mcd_open returned 0, which is its error value");
  CHECK((a & 0x7u) == 0, "a user channel must not alias stdout/stderr/log");
  CHECK(a == 8u, "the first user channel is channel 4, mcd 8; got %u", (unsigned)a);

  /* "If the file is already opened, vpi_mcd_open() shall return the descriptor
   * number" — the same one, not a second channel onto the same file. */
  again = vpi_mcd_open(NAME_A);
  CHECK(again == a, "reopening an open file must return its existing mcd %u, got %u",
        (unsigned)a, (unsigned)again);

  b = vpi_mcd_open(NAME_B);
  CHECK(b == 16u, "the second user channel is channel 5, mcd 16; got %u", (unsigned)b);
  CHECK((a & b) == 0, "two channels must not share a bit");

  /* --- 12.25 ------------------------------------------------------------- */
  name = vpi_mcd_name(a);
  CHECK(name != NULL, "vpi_mcd_name on an open channel must not be NULL");
  strcpy(saved, name);
  CHECK(strcmp(saved, NAME_A) == 0, "vpi_mcd_name(%u) should be `%s`, got `%s`",
        (unsigned)a, NAME_A, saved);
  /* "This routine shall overwrite the returned value on subsequent calls." */
  name = vpi_mcd_name(b);
  CHECK(strcmp(name, NAME_B) == 0, "vpi_mcd_name(%u) should be `%s`", (unsigned)b, NAME_B);
  CHECK(strcmp(saved, NAME_A) == 0, "the application's own copy was clobbered");

  /* --- 12.27 ------------------------------------------------------------- */
  CHECK(vpi_mcd_printf(a, "alpha\n") == 6, "six characters written to channel A");
  CHECK(vpi_mcd_printf(a | b, "both\n") == 5,
        "vpi_mcd_printf returns the characters of the expansion, not per channel");

  /* --- 12.24 ------------------------------------------------------------- */
  CHECK(vpi_mcd_close(a) == 0, "closing an open channel must return 0");
  expect_no_error("vpi_mcd_close");
  CHECK(vpi_mcd_close(a) == a,
        "closing it again leaves it unclosed, so the mcd comes back");
  CHECK(vpi_mcd_name(a) == NULL, "a closed channel has no name");
  CHECK(vpi_mcd_close(b) == 0, "closing channel B must return 0");

  expect_file(NAME_A, "alpha\nboth\n");
  expect_file(NAME_B, "both\n");

  remove(NAME_A);
  remove(NAME_B);

  p02_done("09_printf_mcd");
  return 0;
}

static void setup(void)
{
  static s_cb_data cb = { 0 };
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = run;
  CHECK(vpi_register_cb(&cb) != NULL, "cbEndOfCompile registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
