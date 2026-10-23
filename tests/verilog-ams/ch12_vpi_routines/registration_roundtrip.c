/* P03 — VAMS-2023 12.13 and 12.6: what was registered can be read back.
 *
 *   12.13  "The VPI routine vpi_get_analog_systf_info() shall return
 *          information about a user-defined analog system task or function
 *          callback in an s_vpi_analog_systf_data structure. The memory for
 *          this structure shall be allocated by the user."
 *   12.6   vpi_get_cb_info() is its counterpart for a callback registered with
 *          vpi_register_cb(): "Pointer to a structure containing callback
 *          information".
 *   12.32  "The task or function name shall be unique in the domain in which it
 *          is registered. That is, the same name can be shared by two sets of
 *          callbacks, provided that one set is registered in the digital domain
 *          and the other is registered in the analog."
 *
 * A round trip is a weak test of a value and a STRONG test of a record: it is
 * the only thing that catches a registration that stored the structure by
 * POINTER and then read a caller's stack frame, or one that kept the fields it
 * happened to need and dropped the rest. Both are the natural first
 * implementation of vpi_register_analog_systf(), and both pass every other
 * fixture in this directory. So every field of Figure 12-18 is written with a
 * distinct value and every field is compared:
 *
 *     type        = vpiAnalogSysFunc   (not vpiAnalogSysTask)
 *     sysfunctype = vpiRealFunc        (not vpiIntFunc)
 *     tfname      = "$p03_probe"       (compared with strcmp, not by pointer:
 *                                       12.12's buffer rule means a returned
 *                                       string may legitimately be a copy)
 *     calltf, compiletf, sizetf, derivtf, user_data — four distinct function
 *                                       pointers and one data pointer, each
 *                                       compared for identity, because an
 *                                       implementation that transposed two of
 *                                       them would otherwise be found only when
 *                                       a solve gave a wrong number.
 *
 * The callback round trip does the same for Figure 12-17, and adds the one
 * assertion that is a VALUE rather than a record: the registered acbAbsTime
 * names t = 2.5e-3, get_cb_info reports 2.5e-3, and the callback is delivered at
 * 2.5e-3 — so the time an application reads back is the time the engine will
 * actually use. Expected: exactly one delivery, at exactly 2.5e-3.
 *
 * 12.32's uniqueness rule closes the fixture: a SECOND analog registration of
 * "$p03_probe" must fail with 12.2's error. Its digital-domain half — the same
 * name registered through vpi_register_systf() must SUCCEED — is P02's routine
 * and is deliberately not asserted here.
 *
 * The DOMAIN, as 12.32 says, is the registration function's: the same name is
 * registered in the analog domain by vpi_register_analog_systf() and in the
 * digital domain by vpi_register_systf(). Each handle reads back through its
 * own info routine and is refused by the other (12.13/12.14), so the context
 * a callback will be invoked in is fixed at registration, not by the name.
 *
 *! design   dc_divider.va
 *! analysis tran 0 5m
 *! expect   11_registration_roundtrip.expected.txt
 */

//! lrm 12.6
//! lrm 12.13
//! lrm 12.31.3
//! lrm 12.32
//! lrm-reject 12.32
//! lrm 12.6:2
//! lrm 12.13:1
//! lrm 12.13:3
//! lrm 12.32:2
//! lrm-reject 12.32:2
//! lrm-reject 12.32:3
//! lrm 12.32:4
//! design dc_divider.va
//! stdout p03-11: systf_roundtrip=1 cb_roundtrip=1 dup_rejected=1 probe_hits=1 probe_t=0.0025

#include "p03_vpi_analog.h"
#include <string.h>

#define T_PROBE 2.5e-3

static int systf_roundtrip, cb_roundtrip, dup_rejected, probe_hits;
static double probe_t = -1.0;
static char probe_ctx[] = "p03 user data";

static PLI_INT32 probe_calltf(p_cb_data cb)   { (void)cb; return 0; }
static PLI_INT32 probe_compiletf(p_cb_data cb){ (void)cb; return 0; }
static PLI_INT32 probe_sizetf(p_cb_data cb)   { (void)cb; return 64; }
static p_vpi_stf_partials probe_derivtf(p_cb_data cb) { (void)cb; return 0; }
/* The digital registration's calltf has the IEEE 1364-2005 prototype, not the
 * analog one; it is never called, but 12.14's round trip compares the field. */
static PLI_INT32 probe_digital_calltf(PLI_BYTE8 *u) { (void)u; return 0; }

static PLI_INT32 on_probe(p_cb_data cb)
{
  (void)cb;
  probe_hits++;
  probe_t = vpi_get_analog_time();
  P03_NEAR(probe_t, T_PROBE, 1e-12, "12.6: the time get_cb_info reported is the time used");
  return 0;
}

static PLI_INT32 on_final(p_cb_data cb)
{
  (void)cb;
  P03_CHECK(systf_roundtrip, "12.13: the systf registration did not round trip");
  P03_CHECK(cb_roundtrip, "12.6: the callback registration did not round trip");
  P03_CHECK(dup_rejected, "12.32: a duplicate analog registration was accepted");
  P03_CHECK(probe_hits == 1, "12.31.3: the probe fired %d times, want 1", probe_hits);
  printf("p03-11: systf_roundtrip=%d cb_roundtrip=%d dup_rejected=%d probe_hits=%d probe_t=%g\n",
         systf_roundtrip, cb_roundtrip, dup_rejected, probe_hits, probe_t);
  fflush(stdout);
  return 0;
}

/* IEEE 1364-2005 26.2.4: the startup routine registers; the read-backs and
 * the analog callback wait for cbEndOfCompile. */
static vpiHandle sh, dh;

static void p03_11_after_compile(void)
{
  static s_cb_data probe_cb, fin_cb;
  static s_vpi_time probe_time;
  s_vpi_analog_systf_data back;
  s_cb_data cb_back;
  vpiHandle ch;

  memset(&back, 0, sizeof back);
  vpi_get_analog_systf_info(sh, &back);
  p03_no_error("vpi_get_analog_systf_info");
  P03_CHECK(back.type == vpiAnalogSysFunc, "12.13: type came back as %d", (int)back.type);
  P03_CHECK(back.sysfunctype == vpiRealFunc, "12.13: sysfunctype came back as %d",
            (int)back.sysfunctype);
  P03_CHECK(back.tfname && strcmp((char *)back.tfname, "$p03_probe") == 0,
            "12.13: tfname came back as `%s`", back.tfname ? (char *)back.tfname : "(null)");
  P03_CHECK(back.calltf    == probe_calltf,    "12.13: calltf was not preserved");
  P03_CHECK(back.compiletf == probe_compiletf, "12.13: compiletf was not preserved");
  P03_CHECK(back.sizetf    == probe_sizetf,    "12.13: sizetf was not preserved");
  P03_CHECK(back.derivtf   == probe_derivtf,   "12.13: derivtf was not preserved");
  P03_CHECK(back.user_data == (PLI_BYTE8 *)probe_ctx, "12.13: user_data was not preserved");
  systf_roundtrip = 1;

  probe_time.type = vpiScaledRealTime;
  probe_time.real = T_PROBE;
  probe_cb.reason    = acbAbsTime;
  probe_cb.cb_rtn    = on_probe;
  probe_cb.time      = &probe_time;
  probe_cb.user_data = (PLI_BYTE8 *)probe_ctx;
  ch = vpi_register_cb(&probe_cb);
  P03_CHECK(ch != NULL, "12.31: acbAbsTime registration failed");

  memset(&cb_back, 0, sizeof cb_back);
  cb_back.time = &probe_time;   /* 12.6 fills a structure the USER allocated */
  vpi_get_cb_info(ch, &cb_back);
  p03_no_error("vpi_get_cb_info");
  P03_CHECK(cb_back.reason == acbAbsTime, "12.6: reason came back as %d", (int)cb_back.reason);
  P03_CHECK(cb_back.cb_rtn == on_probe, "12.6: cb_rtn was not preserved");
  P03_CHECK(cb_back.user_data == (PLI_BYTE8 *)probe_ctx, "12.6: user_data was not preserved");
  P03_CHECK(cb_back.time != NULL && cb_back.time->type == vpiScaledRealTime,
            "12.6: the time type was not preserved");
  P03_NEAR(cb_back.time->real, T_PROBE, 0.0, "12.6 the registered callback time");
  cb_roundtrip = 1;

  /* 12.32: the registration function fixes the domain. The same name is both
   * an analog and a digital registration; each handle is readable only
   * through its own domain's info routine, and the other refuses it. */
  {
    s_vpi_systf_data dinfo;
    memset(&dinfo, 0, sizeof dinfo);
    vpi_get_systf_info(dh, &dinfo);
    p03_no_error("vpi_get_systf_info(digital $p03_probe)");
    P03_CHECK(dinfo.type == vpiSysFunc && dinfo.sysfunctype == vpiRealFunc &&
              dinfo.tfname != NULL && strcmp((char *)dinfo.tfname, "$p03_probe") == 0 &&
              dinfo.calltf == probe_digital_calltf,
              "12.32: the digital registration reads back as registered");
    vpi_get_analog_systf_info(dh, &back);
    (void)p03_saw_error("12.32: vpi_get_analog_systf_info on a digital registration");
    vpi_get_systf_info(sh, &dinfo);
    (void)p03_saw_error("12.32: vpi_get_systf_info on an analog registration");
  }

  fin_cb.reason = acbFinalStep; fin_cb.cb_rtn = on_final;
  P03_CHECK(vpi_register_cb(&fin_cb) != NULL, "acbFinalStep registration failed");
}

static void p03_11_startup(void)
{
  static s_vpi_analog_systf_data systf, dup;
  static s_vpi_systf_data dsystf;

  systf.type        = vpiAnalogSysFunc;
  systf.sysfunctype = vpiRealFunc;
  systf.tfname      = (PLI_BYTE8 *)"$p03_probe";
  systf.calltf      = probe_calltf;
  systf.compiletf   = probe_compiletf;
  systf.sizetf      = probe_sizetf;
  systf.derivtf     = probe_derivtf;
  systf.user_data   = (PLI_BYTE8 *)probe_ctx;
  sh = vpi_register_analog_systf(&systf);
  P03_CHECK(sh != NULL, "12.32: registering $p03_probe failed");
  p03_no_error("vpi_register_analog_systf");

  /* 12.32: the other registration function is the other domain. The name is
   * unique per domain, so this one is a second, independent registration. */
  dsystf.type        = vpiSysFunc;
  dsystf.sysfunctype = vpiRealFunc;
  dsystf.tfname      = (PLI_BYTE8 *)"$p03_probe";
  dsystf.calltf      = probe_digital_calltf;
  dsystf.compiletf   = NULL;
  dsystf.sizetf      = NULL;
  dsystf.user_data   = (PLI_BYTE8 *)probe_ctx;
  dh = vpi_register_systf(&dsystf);
  P03_CHECK(dh != NULL, "12.32: the same name was refused in the digital domain");
  p03_no_error("vpi_register_systf(same name, digital domain)");

  /* 12.32: "The task or function name shall be unique in the domain in which it
   * is registered." */
  dup = systf;
  dup_rejected = (vpi_register_analog_systf(&dup) == NULL);
  P03_CHECK(dup_rejected, "12.32: `$p03_probe` was registered twice in the analog domain");
  (void)p03_saw_error("the duplicate vpi_register_analog_systf");

  p03_defer(p03_11_after_compile);
}

void (*vlog_startup_routines[])(void) = { p03_11_startup, 0 };
