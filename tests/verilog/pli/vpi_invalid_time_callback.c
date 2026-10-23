/* IEEE 1364-2005 27.33.2: time callbacks require a real/simulation time
 * format; suppress-time and NULL time are errors and create no callback. */
//! lrm 11.2.3
//! lrm 12.2
//! lrm-reject 12.31.2
//! lrm 12.31.4
//! lrm 12.33.2
//! design vpi_invalid_time_callback.v
//! stdout vpi-invalid-time-callback=ok

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>
static PLI_INT32 forbidden(p_cb_data cb) { (void)cb; exit(1); return 0; }
static PLI_INT32 begin(p_cb_data cb) {
    s_vpi_time time={0}; s_cb_data bad={0}; (void)cb;
    bad.reason=cbAfterDelay; bad.cb_rtn=forbidden;
    time.type=vpiSuppressTime; bad.time=&time;
    if (vpi_register_cb(&bad)!=NULL || vpi_chk_error(NULL)==0) exit(1);
    bad.time=NULL;
    if (vpi_register_cb(&bad)!=NULL || vpi_chk_error(NULL)==0) exit(1);
    puts("vpi-invalid-time-callback=ok"); return 0;
}
static void register_probe(void) {
    s_cb_data cb={0}; cb.reason=cbStartOfSimulation; cb.cb_rtn=begin;
    if (!vpi_register_cb(&cb)) exit(1);
}
void (*vlog_startup_routines[])(void)={register_probe,NULL};
