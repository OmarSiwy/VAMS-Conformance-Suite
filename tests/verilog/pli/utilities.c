/* b 27 utilities — the Clause 27 routines outside the object model, over
 * ch11_vpi/objects.v (mem [0:3] = 8'h00 8'h11 8'h22 8'h33 at t=0;
 * `#1 $finish(0)`).
 *
 * IEEE 1364-2005:
 *
 * §27.3, p. 420: "The VPI routine vpi_control() shall pass information from a
 * user PLI application to a Verilog software tool, such as a simulator."
 * "vpiFinish Causes the $finish built-in Verilog system task to be executed
 * upon return of the application routine." Returns: "1 (true) if successful;
 * 0 (false) on a failure."
 *
 * §27.4, p. 421: "The routine vpi_flush() shall flush the output buffers for
 * the simulator's output channel and current log file." Returns: "0 if
 * successful; nonzero if unsuccessful."
 *
 * §27.8, p. 423: "This routine can only be called from an application routine
 * that has been called for reason cbStartOfRestart or cbEndOfRestart." "On a
 * failure, the return value shall be 0." §27.29, p. 445: "This routine can
 * only be called from an application routine that has been called for the
 * reason cbStartOfSave or cbEndOfSave." "A zero shall be returned if an error
 * is detected."
 *
 * §27.13, p. 429: "This routine shall return the value of the user data
 * associated with a previous call to vpi_put_userdata() for a user-defined
 * system task/function call handle. If no user data had been previously
 * associated with the object or if the routine fails, the return value shall
 * be NULL." §27.31, p. 450: "The routine will return a value of 1 on success
 * or a 0 if it fails."
 *
 * §27.18, p. 438: "The VPI routine vpi_handle_by_multi_index() shall provide
 * access to an index-selected subobject of the reference handle. ... If the
 * indices provided do not lead to the construction of a legal Verilog index
 * select expression, the routine shall return a null handle."
 *
 * §27.23, p. 441: "The routine vpi_mcd_flush() shall flush the output buffers
 * for the file(s) specified by the multichannel descriptor mcd." Returns: "0
 * if successful; nonzero if unsuccessful."
 *
 * §27.27, p. 444: "This routine performs the same function as
 * vpi_mcd_printf(), except that varargs have already been started." §27.26,
 * p. 443: "The most significant bit of the descriptor is reserved by the tool
 * to indicate that the descriptor is actually a file descriptor instead of an
 * mcd." "vpi_mcd_printf() shall not write to a file represented by an fd file
 * descriptor". §27.37, p. 466: "This routine performs the same function as
 * vpi_printf(), except that varargs have already been started."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * From a cbReadWriteSynch at t=0:
 *   §27.4   vpi_flush() -> 0.
 *   §27.23  on a vpi_mcd_open()ed file -> 0; on the highest channel bit below
 *           the fd bit that is not that file's, never opened -> nonzero.
 *   §27.37  vpi_vprintf("b27v %d\n", 5) through a va_list -> 7 characters,
 *           "b27v 5\n" on the output channel.
 *   §27.27  vpi_mcd_vprintf(that file, "v%d\n", 3) -> 3 characters; the
 *           same call with the fd bit (0x80000000) added writes nothing and
 *           returns EOF ("return EOF if an error occurred", §27.26), so the
 *           closed file reads "v3\n".
 *   §27.18  (mem, 1, {2}) is mem[2], reading 8'h22; (mem, 1, {4}) is past
 *           [0:3]: no word mem[4] exists, read as "do not lead to the
 *           construction of a legal Verilog index select expression" -> NULL
 *           (mem[4] is legal SYNTAX in the HDL, reading x; the reading taken
 *           is that no object is selected).
 *   §27.13/§27.31  a module is no system task/function call: put -> 0, get
 *           -> NULL. (The success half is systf.c's.)
 *   §27.8/§27.29  not inside a save or restart callback: get and put -> 0.
 *   §27.3   vpi_control(9999) is no operation -> 0; vpi_control(vpiFinish, 0)
 *           -> 1, and the simulation ends at t=0, not at the design's t=1.
 * Each refusal is also read through vpi_chk_error().
 */

//! inherited IEEE 1364-2005 27.3
//! inherited-reject IEEE 1364-2005 27.3
//! inherited IEEE 1364-2005 27.4
//! inherited-reject IEEE 1364-2005 27.8
//! inherited IEEE 1364-2005 27.18
//! inherited-reject IEEE 1364-2005 27.18
//! inherited-reject IEEE 1364-2005 27.13
//! inherited IEEE 1364-2005 27.23
//! inherited-reject IEEE 1364-2005 27.23
//! inherited IEEE 1364-2005 27.27
//! inherited-reject IEEE 1364-2005 27.27
//! inherited-reject IEEE 1364-2005 27.29
//! inherited-reject IEEE 1364-2005 27.31
//! inherited IEEE 1364-2005 27.37
//! design ../../verilog-ams/ch11_vpi/objects.v
//! stdout b27v 5
//! stdout p02: b_27_utilities checks=33

#include <stdarg.h>
#include "b_check.h"

static int finished_early = 0;

static PLI_INT32 vp(const char *fmt, ...)
{
  va_list ap;
  PLI_INT32 n;
  va_start(ap, fmt);
  n = vpi_vprintf((PLI_BYTE8 *)fmt, ap);
  va_end(ap);
  return n;
}

static PLI_INT32 mvp(PLI_UINT32 mcd, const char *fmt, ...)
{
  va_list ap;
  PLI_INT32 n;
  va_start(ap, fmt);
  n = vpi_mcd_vprintf(mcd, (PLI_BYTE8 *)fmt, ap);
  va_end(ap);
  return n;
}

static PLI_INT32 rw0(p_cb_data d)
{
  vpiHandle top = p02_by_name("p04_objects");
  vpiHandle mem = p02_by_name("p04_objects.mem");
  PLI_UINT32 f = vpi_mcd_open((PLI_BYTE8 *)"b_27_utilities.log");
  PLI_INT32 idx[1];
  PLI_UINT32 unused;
  PLI_BYTE8 buf[4];
  vpiHandle h;
  s_vpi_value v;
  (void)d;
  CHECK(f != 0, "a file to flush");

  CHECK(vpi_flush() == 0, "27.4: 0 on success");

  CHECK(vpi_mcd_flush(f) == 0, "27.23: 0 on success");
  for (unused = 1u << 30; unused & f; unused >>= 1) {}
  CHECK(vpi_mcd_flush(unused) != 0, "27.23: nonzero for a channel never opened");
  expect_refusal("vpi_mcd_flush(unopened)");

  CHECK(vp("b27v %d\n", 5) == 7, "27.37: 7 characters");

  CHECK(mvp(f, "v%d\n", 3) == 3, "27.27: 3 characters");
  CHECK(mvp(0x80000000u | f, "fd\n") == EOF, "27.27: EOF for a file descriptor");
  expect_refusal("vpi_mcd_vprintf(fd)");
  CHECK(vpi_mcd_close(f) == 0, "the file closes");
  {
    FILE *fp = fopen("b_27_utilities.log", "rb");
    char got[8] = { 0 };
    CHECK(fp != NULL && fread(got, 1, sizeof got - 1, fp) == 3 && strcmp(got, "v3\n") == 0,
          "27.27: the file reads v3, and nothing through the fd bit");
    fclose(fp);
  }

  idx[0] = 2;
  h = vpi_handle_by_multi_index(mem, 1, idx);
  CHECK(h != NULL, "27.18: mem[2]");
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  CHECK(v.value.integer == 0x22, "27.18: mem[2] reads 8'h22");
  idx[0] = 4;
  CHECK(vpi_handle_by_multi_index(mem, 1, idx) == NULL, "27.18: mem[4] is no legal select");
  expect_refusal("vpi_handle_by_multi_index(mem, {4})");

  CHECK(vpi_put_userdata(top, buf) == 0, "27.31: a module is no system task/function call");
  expect_refusal("vpi_put_userdata(module)");
  CHECK(vpi_get_userdata(top) == NULL, "27.13: NULL on failure");
  expect_refusal("vpi_get_userdata(module)");

  CHECK(vpi_put_data(1, buf, 4) == 0, "27.29: only from a save callback");
  expect_refusal("vpi_put_data outside a save callback");
  CHECK(vpi_get_data(1, buf, 4) == 0, "27.8: only from a restart callback");
  expect_refusal("vpi_get_data outside a restart callback");

  CHECK(vpi_control(9999) == 0, "27.3: 9999 is no operation");
  expect_refusal("vpi_control(9999)");
  CHECK(vpi_control(vpiFinish, 0) == 1, "27.3: vpiFinish");
  finished_early = 1;
  return 0;
}

static PLI_INT32 eos(p_cb_data d)
{
  s_vpi_time t;
  (void)d;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  if (finished_early) CHECK(t.low == 0, "27.3: $finish ran at t=0");
  else CHECK(t.low == 1, "the design's own $finish at t=1");
  p02_done("b_27_utilities");
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
  static s_cb_data s, e;
  s.reason = cbStartOfSimulation;
  s.cb_rtn = start;
  e.reason = cbEndOfSimulation;
  e.cb_rtn = eos;
  CHECK(vpi_register_cb(&s) != NULL && vpi_register_cb(&e) != NULL, "two action callbacks");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
