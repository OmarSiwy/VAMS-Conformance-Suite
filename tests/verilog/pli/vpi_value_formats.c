/* IEEE 1364-2005 27.14/27.32: runtime value conversion and independent
 * get_value/get_str buffers. Startup only registers a permitted callback.
 * No substitute header or local VPI declarations: missing API is real debt. */
//! lrm 11.3.2
//! lrm 12.2
//! lrm 12.12
//! lrm 12.16
//! lrm 12.21
//! lrm 12.30
//! lrm 12.31.4
//! lrm 12.33.2
//! design vpi_value_formats.v
//! stdout vpi-value-formats=ok

#include "vpi_user.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define REQUIRE(c) do { if (!(c)) { fprintf(stderr,"value formats: %s\n",#c); exit(1); } } while (0)
static PLI_INT32 check_values(p_cb_data cb) {
    s_vpi_value value = {0};
    s_vpi_vecval words[2] = {{12,6},{5,0}};
    vpiHandle wide = vpi_handle_by_name("audit_vpi_value_formats.wide",NULL);
    vpiHandle nibble = vpi_handle_by_name("audit_vpi_value_formats.nibble",NULL);
    vpiHandle realvar = vpi_handle_by_name("audit_vpi_value_formats.realvar",NULL);
    (void)cb;
    REQUIRE(wide && nibble && realvar);
    /* Low nibble 1xz0: aval=1100, bval=0110; upper three bits 101. */
    value.format=vpiVectorVal; value.value.vector=words;
    REQUIRE(vpi_put_value(wide,&value,NULL,vpiNoDelay)==NULL);
    REQUIRE(vpi_chk_error(NULL)==0);
    vpi_get_value(wide,&value);
    REQUIRE(value.value.vector != NULL);
    REQUIRE((uint32_t)value.value.vector[0].aval==12);
    REQUIRE((uint32_t)value.value.vector[0].bval==6);
    REQUIRE(((uint32_t)value.value.vector[1].aval & 7)==5);
    REQUIRE(((uint32_t)value.value.vector[1].bval & 7)==0);
    value.format=vpiVectorVal; value.value.vector=words;
    vpi_put_value(nibble,&value,NULL,vpiNoDelay);
    value.format=vpiIntVal; vpi_get_value(nibble,&value);
    REQUIRE(value.value.integer==8); /* x/z map to zero, not unknown. */
    value.format=vpiBinStrVal; vpi_get_value(nibble,&value);
    REQUIRE(strcmp(value.value.str,"1xz0")==0);
    {
        const char *saved=value.value.str;
        REQUIRE(strcmp(vpi_get_str(vpiName,nibble),"nibble")==0);
        REQUIRE(strcmp(saved,"1xz0")==0); /* Separate routine buffers. */
    }
    value.format=vpiRealVal; value.value.real=-2.5;
    vpi_put_value(realvar,&value,NULL,vpiNoDelay);
    value.format=vpiIntVal; vpi_get_value(realvar,&value);
    REQUIRE(value.value.integer==-3); /* 4.8.2 rounds ties away from zero. */
    REQUIRE(vpi_chk_error(NULL)==0);
    puts("vpi-value-formats=ok");
    return 0;
}
static void register_probe(void) {
    s_cb_data cb={0}; cb.reason=cbStartOfSimulation; cb.cb_rtn=check_values;
    if (!vpi_register_cb(&cb)) exit(1);
}
void (*vlog_startup_routines[])(void)={register_probe,NULL};
