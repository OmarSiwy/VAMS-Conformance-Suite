/* IEEE 1364-2005 27.32: freeing a handle does not cancel its event;
 * cancellation does not undo previous inertial cancellation. No same-time race. */
//! lrm 12.2
//! lrm 12.4
//! lrm 12.5
//! lrm 12.16
//! lrm 12.21
//! lrm 12.30
//! lrm 12.31.2
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 12.30:14
//! lrm 12.30:15
//! lrm 12.30:1002
//! lrm 12.30:1003
//! design vpi_event_handles.v
//! stdout vpi-event-handles=ok

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>
#define REQUIRE(c) do { if (!(c)) { fprintf(stderr,"event handles: %s\n",#c); exit(1); } } while (0)
static vpiHandle a,b,c;
static PLI_INT32 observe(p_cb_data cb) {
    s_vpi_value v={0}; (void)cb; v.format=vpiIntVal;
    vpi_get_value(a,&v); REQUIRE(v.value.integer==1);
    vpi_get_value(b,&v); REQUIRE(v.value.integer==0);
    vpi_get_value(c,&v); REQUIRE(v.value.integer==0);
    REQUIRE(vpi_chk_error(NULL)==0);
    puts("vpi-event-handles=ok"); return 0;
}
static PLI_INT32 begin(p_cb_data cb) {
    s_vpi_value v={0}; s_vpi_time time={0}; s_cb_data later={0};
    vpiHandle event; (void)cb;
    a=vpi_handle_by_name("audit_vpi_event_handles.a",NULL);
    b=vpi_handle_by_name("audit_vpi_event_handles.b",NULL);
    c=vpi_handle_by_name("audit_vpi_event_handles.c",NULL);
    REQUIRE(a && b && c);
    v.format=vpiIntVal; v.value.integer=0;
    vpi_put_value(a,&v,NULL,vpiNoDelay);
    vpi_put_value(b,&v,NULL,vpiNoDelay);
    vpi_put_value(c,&v,NULL,vpiNoDelay);
    time.type=vpiSimTime; time.low=3; v.value.integer=1;
    event=vpi_put_value(a,&v,&time,vpiPureTransportDelay|vpiReturnEvent);
    REQUIRE(event && vpi_get(vpiScheduled,event)==1);
    REQUIRE(vpi_free_object(event)==1); /* Event itself must remain. */
    event=vpi_put_value(b,&v,&time,vpiPureTransportDelay|vpiReturnEvent);
    REQUIRE(event != NULL);
    vpi_put_value(event,NULL,NULL,vpiCancelEvent);
    REQUIRE(vpi_chk_error(NULL)==0);
    time.low=2;
    vpi_put_value(c,&v,&time,vpiPureTransportDelay);
    time.low=4; v.value.integer=2; /* Distinct from current0 and predecessor1. */
    event=vpi_put_value(c,&v,&time,vpiInertialDelay|vpiReturnEvent);
    REQUIRE(event != NULL);
    vpi_put_value(event,NULL,NULL,vpiCancelEvent); /* Must not resurrect t=2. */
    REQUIRE(vpi_chk_error(NULL)==0);
    time.low=5; later.reason=cbAfterDelay; later.cb_rtn=observe; later.time=&time;
    REQUIRE(vpi_register_cb(&later)!=NULL);
    return 0;
}
static void register_probe(void) {
    s_cb_data cb={0}; cb.reason=cbStartOfSimulation; cb.cb_rtn=begin;
    if (!vpi_register_cb(&cb)) exit(1);
}
void (*vlog_startup_routines[])(void)={register_probe,NULL};
