/* b 27 mcd — vpi_printf() and the multichannel descriptor routines, over
 * mcd.v, from a cbReadWriteSynch at t=0 (after the HDL's two $fopen).
 * Every file is a relative name, so it lands in the run's working directory.
 *
 * IEEE 1364-2005:
 *
 * §27.22, p. 440-441: "The VPI routine vpi_mcd_close() shall close the
 * file(s) specified by a multichannel descriptor, mcd. Several channels can be
 * closed simultaneously because channels are represented by discrete bits in
 * the integer mcd. On success, this routine shall return a 0; on error, it
 * shall return the mcd value of the unclosed channels. This routine can also
 * be used to close file descriptors that were opened using the system function
 * $fopen()." "The following descriptors are predefined and cannot be closed
 * using vpi_mcd_close(): descriptor 1 is for the output channel of the
 * software product that invoked the PLI application and the current log file"
 *
 * §27.24, p. 441: "The VPI routine vpi_mcd_name() shall return the name of a
 * file represented by a single-channel descriptor, cd. On error, the routine
 * shall return NULL. ... This routine can be used to get the name of any file
 * opened using the system function $fopen or the VPI routine vpi_mcd_open().
 * The channel descriptor cd could be an fd file descriptor returned from
 * $fopen (indicated by the most significant bit being set) or an mcd
 * multichannel descriptor returned by either the system function $fopen or
 * the VPI routine vpi_mcd_open()."
 *
 * §27.25, p. 442: "The VPI routine vpi_mcd_open() shall open a file for
 * writing and shall return a corresponding multichannel description number
 * (mcd). The channel descriptor 1 (least significant bit) is reserved for
 * representing the output channel of the software product that invoked the
 * PLI application and the log file (if one is currently open). The channel
 * descriptor 32 (most significant bit) is reserved to represent a file
 * descriptor (fd) returned from the Verilog HDL $fopen system function." "The
 * vpi_mcd_open() routine shall return a 0 on error. If the file has already
 * been opened either by a previous call to vpi_mcd_open() or using $fopen in
 * the Verilog source code, then vpi_mcd_open() shall return the descriptor
 * number."
 *
 * §27.26, p. 443: "The VPI routine vpi_mcd_printf() shall write to one or more
 * channels (up to 31) determined by the mcd. ... Channel 1 is reserved for the
 * output channel of the software product that invoked the PLI application and
 * the current log file." "vpi_mcd_printf() shall also write to a file
 * represented by an mcd that was returned from the Verilog HDL $fopen system
 * function. vpi_mcd_printf() shall not write to a file represented by an fd
 * file descriptor returned from $fopen (indicated by the most significant bit
 * being set)." "The format strings shall use the same format as the C
 * fprintf() routine. The routine shall return the number of characters printed
 * or return EOF if an error occurred."
 *
 * §27.28, p. 444: "The VPI routine vpi_printf() shall write to both the output
 * channel of the software product that invoked the PLI application and the
 * current product log file. The format string shall use the same format as the
 * C printf() routine. The routine shall return the number of characters
 * printed or return EOF if an error occurred."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * The HDL holds hm = $fopen("b_27_mcd_hdl.log") (an mcd, msb clear) and
 * hf = $fopen("b_27_mcd_fd.log", "w") (an fd, msb set).
 *
 *   §27.28  vpi_printf("b27 printf %d %s\n", 7, "ok") expands to
 *           "b27 printf 7 ok\n", 16 characters, on the output channel.
 *   §27.25  a = open("b_27_mcd_a.log"), b = open("b_27_mcd_b.log"): each a
 *           single bit, neither bit 0 (channel 1) nor bit 31, and a != b.
 *           Opening a's file again returns a; opening the HDL's file returns
 *           hm. A NULL name is an error: 0.
 *   §27.26  (a, "alpha\n") 6; (a|b, "both\n"), one call, both files: 5
 *           characters, or 10 if the count is summed over the two channels
 *           (the clause does not say which);
 *           (hm, "hdl\n") 4; (1, "b27 mcd1\n") 9 characters, on the output
 *           channel; (hf, "no\n") must write nothing to the fd's file.
 *   §27.24  name(a) "b_27_mcd_a.log"; name(hf) "b_27_mcd_fd.log"; name(a|b)
 *           is no single channel, and the highest channel bit below the
 *           fd bit that is none of a, b, hm or the descriptor the HDL file's
 *           open returned was never opened: NULL.
 *   §27.22  close(a|b) 0, then the files read "alpha\nboth\n" (11 bytes) and
 *           "both\n" (5). close(1) cannot close channel 1: returns 1.
 *           close(a) again: a is not open, so a is unclosed: returns a.
 *           close(hm) 0, then the HDL's file reads "hdl\n". close(hf) 0: the
 *           routine "can also be used to close file descriptors that were
 *           opened using the system function $fopen()", after which hf names
 *           no file (§27.24's NULL).
 *
 * VAMS-2023 §12.24 fixes the three predefined descriptors by number: 1 is
 * stdout, 2 is stderr, 3 is the current log file, and none can be closed.
 * In the mcd bit mask descriptor n is bit n-1, so those are mcd values 1, 2
 * and 4. vpi_mcd_name reads back their names, and vpi_mcd_close returns the
 * unclosed mask, 1, 2 and 4.
 */

//! lrm 12.24:1001
//! lrm-reject 12.24:1001
//! lrm 12.24:1002
//! inherited IEEE 1364-2005 27.22
//! inherited-reject IEEE 1364-2005 27.22
//! inherited IEEE 1364-2005 27.24
//! inherited-reject IEEE 1364-2005 27.24
//! inherited IEEE 1364-2005 27.25
//! inherited-reject IEEE 1364-2005 27.25
//! inherited IEEE 1364-2005 27.26
//! inherited-reject IEEE 1364-2005 27.26
//! inherited IEEE 1364-2005 27.28
//! design mcd.v
//! stdout b27 printf 7 ok
//! stdout b27 mcd1
//! stdout p02: b_27_mcd checks=41
//! stderr

#include "b_check.h"

static int one_bit(PLI_UINT32 m) { return m != 0 && (m & (m - 1)) == 0; }

static int file_is(const char *path, const char *want)
{
  char buf[64];
  size_t n;
  FILE *f = fopen(path, "rb");
  if (!f) return 0;
  n = fread(buf, 1, sizeof buf - 1, f);
  fclose(f);
  buf[n] = '\0';
  return strcmp(buf, want) == 0;
}

static PLI_UINT32 int_of(const char *name)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(p02_by_name(name), &v);
  return (PLI_UINT32)v.value.integer;
}

static PLI_INT32 rw0(p_cb_data d)
{
  PLI_UINT32 a, b, c, hm, hf, unused;
  PLI_INT32 n;
  PLI_BYTE8 *nm;
  (void)d;

  hm = int_of("b_27_mcd.hm");
  hf = int_of("b_27_mcd.hf");
  CHECK(hm != 0 && (hm & 0x80000000u) == 0, "the HDL mcd has its msb clear");
  CHECK((hf & 0x80000000u) != 0, "the HDL fd has its msb set");

  fflush(stdout);
  CHECK(vpi_printf((PLI_BYTE8 *)"b27 printf %d %s\n", 7, "ok") == 16, "27.28: 16 characters");

  a = vpi_mcd_open((PLI_BYTE8 *)"b_27_mcd_a.log");
  b = vpi_mcd_open((PLI_BYTE8 *)"b_27_mcd_b.log");
  CHECK(one_bit(a) && one_bit(b) && a != b, "27.25: two single-channel descriptors");
  CHECK(!(a & 1u) && !(b & 1u) && !(a & 0x80000000u) && !(b & 0x80000000u),
        "27.25: neither is channel 1 or the fd bit");
  CHECK(vpi_mcd_open((PLI_BYTE8 *)"b_27_mcd_a.log") == a, "27.25: an open file returns its descriptor");
  c = vpi_mcd_open((PLI_BYTE8 *)"b_27_mcd_hdl.log");
  CHECK(c == hm, "27.25: the file the HDL opened returns the HDL's mcd");
  CHECK(vpi_mcd_open(NULL) == 0, "27.25: 0 on error");
  expect_refusal("vpi_mcd_open(NULL)");

  CHECK(vpi_mcd_printf(a, (PLI_BYTE8 *)"alpha\n") == 6, "27.26: 6 characters");
  n = vpi_mcd_printf(a | b, (PLI_BYTE8 *)"both\n");
  CHECK(n == 5 || n == 10, "27.26: 5 characters, per channel or in all, got %d", (int)n);
  CHECK(vpi_mcd_printf(hm, (PLI_BYTE8 *)"hdl\n") == 4, "27.26: 4 characters");
  fflush(stdout);
  CHECK(vpi_mcd_printf(1, (PLI_BYTE8 *)"b27 mcd%d\n", 1) == 9, "27.26: channel 1, 9 characters");
  vpi_mcd_printf(hf, (PLI_BYTE8 *)"no\n");

  nm = vpi_mcd_name(a);
  CHECK(nm != NULL && strcmp(nm, "b_27_mcd_a.log") == 0, "27.24: the name of a");
  nm = vpi_mcd_name(hf);
  CHECK(nm != NULL && strcmp(nm, "b_27_mcd_fd.log") == 0, "27.24: the name of the HDL's fd");
  CHECK(vpi_mcd_name(a | b) == NULL, "27.24: a|b is no single channel");
  for (unused = 1u << 30; unused & (a | b | c | hm); unused >>= 1) {}
  CHECK(vpi_mcd_name(unused) == NULL, "27.24: a channel never opened names no file");
  expect_refusal("vpi_mcd_name(unopened)");

  CHECK(vpi_mcd_close(a | b) == 0, "27.22: both close");
  CHECK(file_is("b_27_mcd_a.log", "alpha\nboth\n"), "27.26: file a");
  CHECK(file_is("b_27_mcd_b.log", "both\n"), "27.26: file b");
  CHECK(vpi_mcd_close(1) == 1, "27.22: channel 1 cannot be closed");
  /* 12.24: the three predefined descriptors, by number. Descriptor 3 is the
   * third bit, mcd value 4. */
  CHECK_STR(vpi_mcd_name(1), "stdout", "12.24: descriptor 1 is stdout");
  CHECK_STR(vpi_mcd_name(2), "stderr", "12.24: descriptor 2 is stderr");
  nm = vpi_mcd_name(4);
  CHECK(nm != NULL && strlen(nm) > 4 && strcmp(nm + strlen(nm) - 4, ".log") == 0,
        "12.24: descriptor 3 is the current log file, got `%s`", nm ? nm : "(null)");
  CHECK(vpi_mcd_close(2) == 2, "12.24: descriptor 2, stderr, cannot be closed");
  CHECK(vpi_mcd_close(4) == 4, "12.24: descriptor 3, the log file, cannot be closed");
  CHECK(vpi_mcd_close(a) == a, "27.22: a is no longer open");
  CHECK(vpi_mcd_close(hm) == 0, "27.22: the HDL's mcd closes");
  CHECK(file_is("b_27_mcd_hdl.log", "hdl\n"), "27.26: the HDL's file");
  CHECK(file_is("b_27_mcd_fd.log", ""), "27.26: nothing is written to an fd");
  CHECK(vpi_mcd_close(hf) == 0, "27.22: the HDL's fd closes");
  CHECK(vpi_mcd_name(hf) == NULL, "27.24: a closed fd names no file");

  p02_done("b_27_mcd");
  return 0;
}

static PLI_INT32 start(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  (void)d;
  t.type = vpiSimTime;
  cb.reason = cbReadWriteSynch;
  cb.cb_rtn = rw0;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadWriteSynch at t=0");
  return 0;
}

static void startup(void)
{
  static s_cb_data cb;
  cb.reason = cbStartOfSimulation;
  cb.cb_rtn = start;
  CHECK(vpi_register_cb(&cb) != NULL, "cbStartOfSimulation");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
