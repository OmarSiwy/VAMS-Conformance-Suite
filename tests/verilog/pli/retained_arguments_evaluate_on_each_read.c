/* IEEE 1364-2005 §26.6.19(e): "Arguments to PLI tasks or functions are not
 * evaluated until an application requests their value."
 * A request evaluates the function then, including another request through
 * the same retained handle. §26.6.19(b) lets a running system function read
 * its current return value; this must not recursively invoke its calltf.
 *
 * DERIVATION, with the paired HDL (times are distinct; no active race):
 * t=0: root calls=0. Retain bump(offset), then HDL changes offset 10 -> 20.
 * t=1: the child's bump changes its own calls 100 -> 101 and returns 101.
 * t=2: read the retained root handle twice: 1+20=21, then 2+20=22. A NULL
 *      value pointer is refused first (§27.14), with no function execution.
 * t=3: read bump(0)+bump(0) twice: 3+4=7, then 5+6=11. rbump(1.5) returns
 *      exactly 2.0 and advances calls to 7. wide(0) returns the literal's
 *      72 bits including x/z and advances calls to 8. Two reads of
 *      $lazy_inner(bump(0)) call inner twice; each reads its one argument
 *      once and adds 100, returning 109 then 110. Root calls therefore ends
 *      at 10. Inner reads its own result after putting it, without calling
 *      itself again. Both the original call handle and user_data survive
 *      the nested calls. Integer expectations are derived above, not copied
 *      from a simulator transcript. No invalid form of the lazy rule exists;
 *      the refusal pins §27.14's required value pointer beside valid reads.
 */
//! inherited IEEE 1364-2005 26.6.19
//! inherited IEEE 1364-2005 27.14
//! inherited-reject IEEE 1364-2005 27.14
//! design retained_arguments_evaluate_on_each_read.v
//! stdout root_calls=10
//! stderr pli-lazy-scopes calls=3 nested=2 retained=2

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned calls, inner_calls, retained_reads;
static vpiHandle retained;

static void require(int condition, const char *message)
{
    if (!condition) {
        fprintf(stderr, "b_26_6_19_lazy_arguments: %s\n", message);
        exit(1);
    }
}

static PLI_INT32 read_int(vpiHandle h)
{
    s_vpi_value v;
    s_vpi_error_info error;
    v.format = vpiIntVal;
    v.value.integer = -1;
    vpi_get_value(h, &v);
    if (vpi_chk_error(&error) != 0) {
        fprintf(stderr, "integer request at probe=%u nested=%u retained=%u: %s\n",
                calls, inner_calls, retained_reads, error.message);
        require(0, "integer value request failed");
    }
    return v.value.integer;
}

static PLI_INT32 later(p_cb_data unused)
{
    (void)unused;
    vpi_get_value(retained, NULL);
    require(vpi_chk_error(NULL) != 0, "NULL value pointer was not refused");
    require(read_int(retained) == 21, "retained call lost its lexical scope or ran early");
    require(read_int(retained) == 22, "retained call did not execute again");
    retained_reads = 2;
    return 0;
}

static PLI_INT32 inner(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle arg = vpi_scan(it);
    s_vpi_value value;
    PLI_INT32 result;
    require(call != NULL && arg != NULL && vpi_scan(it) == NULL, "nested function arguments");
    require(user_data != NULL && strcmp(user_data, "nested") == 0, "nested user_data");
    require(++inner_calls <= 2, "reading the active return value recursively called the function");
    result = read_int(arg) + 100;
    require(vpi_handle(vpiSysTfCall, NULL) == call, "HDL argument evaluation lost the active call");
    value.format = vpiIntVal;
    value.value.integer = result;
    vpi_put_value(call, &value, NULL, vpiNoDelay);
    require(vpi_chk_error(NULL) == 0, "nested return put failed");
    require(read_int(call) == result, "active return value is not the value just put");
    return 0;
}

static PLI_INT32 probe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle mode = vpi_scan(it), arg = vpi_scan(it);
    PLI_INT32 which;
    (void)unused;
    require(call != NULL && mode != NULL && arg != NULL, "probe arguments");
    which = read_int(mode);
    require(++calls <= 3, "extra probe call");
    if (which == 0) {
        static s_vpi_time time = {vpiSimTime, 0, 2, 0.0};
        static s_cb_data callback;
        retained = arg;
        callback.reason = cbAfterDelay;
        callback.cb_rtn = later;
        callback.time = &time;
        require(vpi_register_cb(&callback) != NULL, "retained-read callback registration");
    } else if (which == 2) {
        require(read_int(arg) == 101, "child function evaluated in another instance");
    } else {
        s_vpi_value value;
        vpiHandle real_arg, wide_arg, nested_arg;
        require(which == 1 && retained_reads == 2, "unexpected probe order");
        require(read_int(arg) == 7, "compound argument was eager or evaluated incorrectly");
        require(read_int(arg) == 11, "compound argument was cached");
        real_arg = vpi_scan(it);
        wide_arg = vpi_scan(it);
        nested_arg = vpi_scan(it);
        require(real_arg != NULL && wide_arg != NULL && nested_arg != NULL, "missing typed arguments");
        value.format = vpiRealVal;
        vpi_get_value(real_arg, &value);
        require(vpi_chk_error(NULL) == 0 && value.value.real == 2.0, "real function result");
        value.format = vpiHexStrVal;
        vpi_get_value(wide_arg, &value);
        require(vpi_chk_error(NULL) == 0 && strcmp(value.value.str, "12abcdef00112233xz") == 0,
                "wide four-state function result");
        require(read_int(nested_arg) == 109, "nested system function first result");
        require(read_int(nested_arg) == 110, "nested system function repeated result");
        require(vpi_handle(vpiSysTfCall, NULL) == call, "nested function lost the outer active call");
    }
    require(vpi_scan(it) == NULL, "extra probe argument");
    return 0;
}

static PLI_INT32 finish(p_cb_data unused)
{
    (void)unused;
    require(calls == 3 && inner_calls == 2 && retained_reads == 2, "missing lazy evaluations");
    fprintf(stderr, "pli-lazy-scopes calls=3 nested=2 retained=2\n");
    return 0;
}

static void register_probe(void)
{
    static s_vpi_systf_data task, function;
    static s_cb_data final_check;
    task.type = vpiSysTask;
    task.tfname = "$lazy_probe";
    task.calltf = probe;
    require(vpi_register_systf(&task) != NULL, "probe registration");
    function.type = vpiSysFunc;
    function.sysfunctype = vpiIntFunc;
    function.tfname = "$lazy_inner";
    function.calltf = inner;
    function.user_data = "nested";
    require(vpi_register_systf(&function) != NULL, "nested function registration");
    final_check.reason = cbEndOfSimulation;
    final_check.cb_rtn = finish;
    require(vpi_register_cb(&final_check) != NULL, "end callback registration");
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};
