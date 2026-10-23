/* IEEE 1364-2005 §27.33.1.1: cbStmt runs immediately before the indicated
 * statement. §27.33.1.3 applies the callback to a module's statements.
 * The registration is made from a running calltf, so no callback exists
 * when the initial process starts. Values seen before its watched blocking
 * assignments must be 0, 1 and 3; removing the registration suppresses the
 * intervening assignment. No source delay separates any of these actions.
 * A variable is an invalid cbStmt target; the module is its legal neighbour.
 * §26.6.39 exposes these registrations from each covered statement. The
 * module registration and a direct registration on q = 2 are distinct
 * handles, each returned once, and neither belongs to the global set.
 * §26.6.43 keeps the callback iterator's reference and requested type.
 */
//! inherited IEEE 1364-2005 27.33.1.1
//! inherited IEEE 1364-2005 27.33.1.3
//! inherited-reject IEEE 1364-2005 27.33.1.1
//! inherited IEEE 1364-2005 26.6.39
//! inherited IEEE 1364-2005 26.6.43
//! design stmt_registration_during_call.v
//! stdout stmt-registration: before=0,1,3 final=4

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static vpiHandle statement_callback, direct_callback, direct_statement, variable;
static unsigned calls, direct_calls, arms, disarms;
static const int expected[] = {0, 1, 3};

static void require(int condition, const char *message)
{
    if (!condition) {
        fprintf(stderr, "audit_stmt_registration_during_call: %s\n", message);
        exit(1);
    }
}

static void associated(vpiHandle statement, unsigned want)
{
    vpiHandle it = vpi_iterate(vpiCallback, statement), h;
    unsigned seen = 0;
    require(vpi_chk_error(NULL) == 0, "callback traversal failed");
    require((it == NULL) == (want == 0), "callback set has wrong emptiness");
    if (it == NULL) return;
    require(vpi_get(vpiIteratorType, it) == vpiCallback, "iterator lost its type");
    require(vpi_compare_objects(vpi_handle(vpiUse, it), statement), "iterator lost its reference");
    while ((h = vpi_scan(it)) != NULL) {
        unsigned bit = statement_callback && vpi_compare_objects(h, statement_callback) ? 1u :
            direct_callback && vpi_compare_objects(h, direct_callback) ? 2u : 0u;
        require(bit != 0 && (want & bit) != 0 && (seen & bit) == 0,
                "unexpected or duplicate callback on statement");
        seen |= bit;
    }
    require(seen == want, "missing callback on statement");
}

static PLI_INT32 before_direct_statement(p_cb_data callback)
{
    s_vpi_value value;
    require(vpi_compare_objects(callback->obj, direct_statement), "wrong direct callback statement");
    value.format = vpiIntVal;
    vpi_get_value(variable, &value);
    require(value.value.integer == 1, "direct callback did not precede q = 2");
    ++direct_calls;
    return 0;
}

static PLI_INT32 before_statement(p_cb_data callback)
{
    s_vpi_value value;
    if (vpi_get(vpiType, callback->obj) != vpiAssignment) return 0;
    require(vpi_compare_objects(vpi_handle(vpiLhs, callback->obj), variable),
            "callback identifies the wrong assignment");
    require(calls < sizeof expected / sizeof expected[0], "unexpected assignment callback");
    value.format = vpiIntVal;
    vpi_get_value(variable, &value);
    require(value.value.integer == expected[calls], "callback did not precede the expected assignment");
    associated(callback->obj, 1u | (direct_callback &&
        vpi_compare_objects(callback->obj, direct_statement) ? 2u : 0u));
    ++calls;
    return 0;
}

static PLI_INT32 arm(PLI_BYTE8 *unused)
{
    s_cb_data callback;
    s_vpi_time time;
    vpiHandle module, it, process = NULL, block, statement;
    (void)unused;
    require(statement_callback == NULL, "registration already armed");
    variable = vpi_handle_by_name("audit_stmt_registration_during_call.q", NULL);
    module = vpi_handle_by_name("audit_stmt_registration_during_call", NULL);
    require(variable != NULL && module != NULL, "design handles missing");
    memset(&callback, 0, sizeof callback);
    memset(&time, 0, sizeof time);
    time.type = vpiSuppressTime;
    callback.reason = cbStmt;
    callback.cb_rtn = before_statement;
    callback.time = &time;
    callback.obj = variable;
    require(vpi_register_cb(&callback) == NULL, "a variable is not a statement target");
    require(vpi_chk_error(NULL) != 0, "invalid target has no diagnostic");
    callback.obj = module;
    statement_callback = vpi_register_cb(&callback);
    require(statement_callback != NULL && vpi_chk_error(NULL) == 0, "module registration failed");
    if (arms == 0) {
        it = vpi_iterate(vpiProcess, module);
        require(it != NULL && (process = vpi_scan(it)) != NULL, "initial process missing");
        require(vpi_get(vpiType, process) == vpiInitial, "wrong process type");
        require(vpi_scan(it) == NULL, "unexpected extra process");
        block = vpi_handle(vpiStmt, process);
        it = vpi_iterate(vpiStmt, block);
        require(it != NULL, "initial block statements missing");
        while ((statement = vpi_scan(it)) != NULL) {
            s_vpi_value rhs;
            if (vpi_get(vpiType, statement) != vpiAssignment) continue;
            rhs.format = vpiIntVal;
            vpi_get_value(vpi_handle(vpiRhs, statement), &rhs);
            if (rhs.value.integer == 2) direct_statement = statement;
        }
        require(direct_statement != NULL, "q = 2 statement missing");
        callback.obj = direct_statement;
        callback.cb_rtn = before_direct_statement;
        direct_callback = vpi_register_cb(&callback);
        require(direct_callback != NULL && vpi_chk_error(NULL) == 0, "direct registration failed");
    }
    associated(direct_statement, direct_callback ? 3u : 1u);
    it = vpi_iterate(vpiCallback, NULL);
    require(it != NULL, "global final callback missing");
    while ((statement = vpi_scan(it)) != NULL) {
        s_cb_data info;
        memset(&info, 0, sizeof info);
        vpi_get_cb_info(statement, &info);
        require(info.reason != cbStmt, "a statement callback leaked into the global set");
    }
    ++arms;
    return 0;
}

static PLI_INT32 disarm(PLI_BYTE8 *unused)
{
    (void)unused;
    require(vpi_remove_cb(statement_callback) == 1, "removal failed");
    statement_callback = NULL;
    associated(direct_statement, 2u);
    require(vpi_remove_cb(direct_callback) == 1, "direct removal failed");
    direct_callback = NULL;
    associated(direct_statement, 0u);
    ++disarms;
    return 0;
}

static PLI_INT32 finish(p_cb_data unused)
{
    s_vpi_value value;
    (void)unused;
    require(arms == 2 && disarms == 1, "system tasks did not run");
    require(calls == sizeof expected / sizeof expected[0], "missing assignment callbacks");
    require(direct_calls == 1, "direct callback count changed");
    value.format = vpiIntVal;
    vpi_get_value(variable, &value);
    require(value.value.integer == 4, "callback changed final HDL behavior");
    puts("stmt-registration: before=0,1,3 final=4");
    return 0;
}

static void register_application(void)
{
    s_vpi_systf_data task;
    s_cb_data callback;
    memset(&task, 0, sizeof task);
    task.type = vpiSysTask;
    task.tfname = "$arm";
    task.calltf = arm;
    require(vpi_register_systf(&task) != NULL, "$arm registration failed");
    task.tfname = "$disarm";
    task.calltf = disarm;
    require(vpi_register_systf(&task) != NULL, "$disarm registration failed");
    memset(&callback, 0, sizeof callback);
    callback.reason = cbEndOfSimulation;
    callback.cb_rtn = finish;
    require(vpi_register_cb(&callback) != NULL, "final callback registration failed");
}

void (*vlog_startup_routines[])(void) = {register_application, NULL};
