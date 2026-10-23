/* Required-positive IEEE26.6.19(e) host probe: asking for an argument's
 * handle does not evaluate it; asking for its value executes its HDL call.
 * Load before elaboration. No manual callback invocation or header shims.
 */
//! lrm 11.6.16
//! lrm 12.16
//! lrm 12.19
//! lrm 12.23
//! lrm 12.31.4
//! lrm 12.33
//! lrm 12.35
//! inherited IEEE 1364-2005 26.6.19
//! design argument_handle_delays_evaluation.v
//! stdout unread=0
//! stdout read=1
//! stderr pli-lazy-arguments calls=2 reads=1

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>

static unsigned calls;

static void require(int condition, const char *message)
{
    if (!condition) {
        fprintf(stderr, "audit_lazy_arguments: %s\n", message);
        exit(1);
    }
}

static PLI_INT32 invoke(PLI_BYTE8 *unused)
{
    vpiHandle call, iterator, mode, lazy;
    s_vpi_value value;
    (void)unused;
    call = vpi_handle(vpiSysTfCall, NULL);
    require(call != NULL, "missing current task");
    iterator = vpi_iterate(vpiArgument, call);
    require(iterator != NULL, "missing arguments");
    mode = vpi_scan(iterator);
    lazy = vpi_scan(iterator);
    require(mode != NULL && lazy != NULL, "missing argument");
    require(vpi_scan(iterator) == NULL, "extra argument");
    value.format = vpiIntVal;
    vpi_get_value(mode, &value);
    require(value.value.integer == (PLI_INT32)calls, "wrong mode or call order");
    require(++calls <= 2, "extra invocation");
    if (calls == 2) {
        value.format = vpiIntVal;
        value.value.integer = -1;
        vpi_get_value(lazy, &value);
        require(vpi_chk_error(NULL) == 0, "function value request failed");
        require(value.value.integer == 1, "function not evaluated at value request");
    }
    return 0;
}

static PLI_INT32 finish(p_cb_data unused)
{
    (void)unused;
    require(calls == 2, "missing execution");
    fprintf(stderr, "pli-lazy-arguments calls=2 reads=1\n");
    return 0;
}

static void register_probe(void)
{
    static s_vpi_systf_data task;
    static s_cb_data final_check;
    task.type = vpiSysTask;
    task.tfname = "$audit_lazy_arguments";
    task.calltf = invoke;
    require(vpi_register_systf(&task) != NULL, "registration failed");
    final_check.reason = cbEndOfSimulation;
    final_check.cb_rtn = finish;
    require(vpi_register_cb(&final_check) != NULL, "end registration failed");
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};
