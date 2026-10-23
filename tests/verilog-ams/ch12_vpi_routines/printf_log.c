/* b7 vpi_printf and the log file: VAMS-2023 12.28, with 12.25 and 12.26 to
 * find the log.
 *
 * 12.28  "The VPI routine vpi_printf() shall write to both stdout and the
 *        current product log file." "The routine shall return the number of
 *        characters printed".
 * 12.26  "The following channel descriptors are predefined and shall be
 *        automatically opened by the system: Descriptor 1 is stdout
 *        Descriptor 2 is stderr Descriptor 3 is the current log file".
 * 12.27  "a mcd of 4 (bit 2 set) corresponds to Channel 3".
 * 12.25  vpi_mcd_name(cd) "shall return the name of a file represented by a
 *        single-channel descriptor, cd."
 *
 * DERIVATION. vpi_mcd_name(4) names the log file, which 12.26 says is open.
 * vpi_printf("b7-printf-log: marker\n") returns its 22 characters and the
 * text reaches that file: after vpi_flush() (IEEE 1364-2005 §27.4, "shall
 * flush the output buffers for the simulator's output channel and current
 * log file"), the file, opened by the
 * name the routine gave, contains the line. The stdout half is p02_09's.
 */

//! lrm 12.28:1
//! design digital.v
//! stdout b7-printf-log: marker
//! stdout p02: b7_printf_log checks=5

#include "../ch11_vpi/p02_check.h"

static PLI_INT32 eoc(p_cb_data d)
{
  static char name[1024], text[4096];
  PLI_BYTE8 *p;
  FILE *f;
  size_t n;
  (void)d;

  p = vpi_mcd_name(4);
  CHECK(p != NULL && p[0] != '\0', "12.26: descriptor 3, the current log file, has no name");
  snprintf(name, sizeof name, "%s", p);
  CHECK(vpi_printf("b7-printf-log: marker\n") == 22, "12.28: vpi_printf returns the 22 characters printed");
  vpi_flush();
  f = fopen(name, "r");
  CHECK(f != NULL, "12.28: the product log file vpi_mcd_name(4) names (`%s`) cannot be read", name);
  n = fread(text, 1, sizeof text - 1, f);
  text[n] = '\0';
  fclose(f);
  CHECK(strstr(text, "b7-printf-log: marker\n") != NULL, "12.28: vpi_printf's text is not in the product log file `%s`", name);
  p02_done("b7_printf_log");
  return 0;
}

static void setup(void)
{
  static s_cb_data cb;
  cb.reason = cbEndOfCompile;
  cb.cb_rtn = eoc;
  CHECK(vpi_register_cb(&cb) != NULL, "cbEndOfCompile registration failed");
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
