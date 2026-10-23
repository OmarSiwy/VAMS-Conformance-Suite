/* Required-positive host probe: IEEE20.4 permits overriding $unsigned,
 * with one fixed sizetf width for all uses regardless of argument width.
 * IEEE26.1.1/2/3 supplies size/build/execution counts;27.34 supplies ABI.
 * This is a plugin, NOT a standalone C program or a header-only test.
 * The production host currently lacks registration/value APIs; do not add
 * compatibility declarations or replace this required behavior by rejection.
 */
//! lrm 11.6.16
//! lrm 12.5
//! lrm 12.12
//! lrm 12.19
//! lrm 12.23
//! lrm 12.30
//! lrm 12.31.4
//! lrm 12.33
//! lrm 12.33.1
//! lrm 12.35
//! lrm 12.33.1:7
//! lrm 12.33.1:11
//! design builtin_override.v
//! stdout first=8000000001 second=8000000001
//! stderr pli-override calls=2 size=40

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char cookie[] = "audit_builtin_override";
static unsigned sizes, builds, calls;

static void require(int condition, const char *message)
{
    if (!condition) {
        fprintf(stderr, "audit_builtin_override: %s\n", message);
        exit(1);
    }
}

static PLI_INT32 size_callback(PLI_BYTE8 *data)
{
    require(data == cookie, "sizetf user_data changed");
    require(++sizes == 1, "sizetf invoked more than once");
    return 40;
}

static PLI_INT32 build_callback(PLI_BYTE8 *data)
{
    require(data == cookie, "compiletf user_data changed");
    require(++builds <= 2, "unexpected compiletf invocation");
    return 0;
}

static PLI_INT32 call_callback(PLI_BYTE8 *data)
{
    vpiHandle call, iterator, argument;
    s_vpi_value result;
    require(data == cookie, "calltf user_data changed");
    require(sizes == 1 && builds == 2, "build callbacks incomplete at execution");
    call = vpi_handle(vpiSysTfCall, NULL);
    require(call != NULL, "no current function call");
    require(vpi_get(vpiSize, call) == 40, "return width followed argument width");
    require(strcmp(vpi_get_str(vpiName, call), "$unsigned") == 0, "wrong function dispatched");
    iterator = vpi_iterate(vpiArgument, call);
    require(iterator != NULL, "no argument iterator");
    argument = vpi_scan(iterator);
    require(argument != NULL, "missing argument");
    require(vpi_get(vpiSize, argument) == (calls == 0 ? 1 : 64), "wrong argument width");
    require(vpi_scan(iterator) == NULL, "extra argument");
    require(++calls <= 2, "unexpected runtime invocation");
    result.format = vpiHexStrVal;
    result.value.str = "8000000001";
    vpi_put_value(call, &result, NULL, vpiNoDelay);
    require(vpi_chk_error(NULL) == 0, "failed to write function result");
    return 0;
}

static PLI_INT32 end_callback(p_cb_data callback)
{
    require(callback->user_data == cookie, "end callback user_data changed");
    require(sizes == 1 && builds == 2 && calls == 2, "missing callback execution");
    fprintf(stderr, "pli-override calls=2 size=40\n");
    return 0;
}

static void register_override(void)
{
    static s_vpi_systf_data registration;
    static s_cb_data final_check;
    registration.type = vpiSysFunc;
    registration.sysfunctype = vpiSizedFunc;
    registration.tfname = "$unsigned";
    registration.calltf = call_callback;
    registration.compiletf = build_callback;
    registration.sizetf = size_callback;
    registration.user_data = cookie;
    require(vpi_register_systf(&registration) != NULL, "registration failed");
    final_check.reason = cbEndOfSimulation;
    final_check.cb_rtn = end_callback;
    final_check.user_data = cookie;
    require(vpi_register_cb(&final_check) != NULL, "end callback registration failed");
}

void (*vlog_startup_routines[])(void) = {register_override, NULL};
