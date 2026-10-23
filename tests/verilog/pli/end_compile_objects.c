/* IEEE26.2.4: startup may register this callback, but must not walk objects.
 * Full API access begins at cbEndOfCompile.26.3.2 requires both numeric and
 * string forms of vpiType. All outputs are observed after the legal boundary.
 */
//! lrm 11.6.1
//! lrm 12.2
//! lrm 12.5
//! lrm 12.12
//! lrm 12.21
//! lrm 12.31.4
//! lrm 12.31.4:1001
//! lrm 12.33.2
//! design end_compile_objects.v
//! stderr pli-end-compile type=vpiModule

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned visits;
static void require(int condition, const char *message)
{
    if (!condition) {
        fprintf(stderr, "audit_end_compile_objects: %s\n", message);
        exit(1);
    }
}

static PLI_INT32 inspect_objects(p_cb_data data)
{
    vpiHandle top;
    const char *type_name;
    (void)data;
    require(++visits == 1, "end-of-compile callback repeated");
    top = vpi_handle_by_name("audit_end_compile_objects", NULL);
    require(top != NULL, "top unavailable at end of compile");
    require(vpi_chk_error(NULL) == 0, "lookup error");
    require(vpi_get(vpiType, top) == vpiModule, "numeric type is not module");
    require(vpi_chk_error(NULL) == 0, "numeric type error");
    type_name = vpi_get_str(vpiType, top);
    require(type_name != NULL, "missing type-name string");
    require(strcmp(type_name, "vpiModule") == 0, "wrong type-name string");
    require(vpi_chk_error(NULL) == 0, "string type error");
    fprintf(stderr, "pli-end-compile type=vpiModule\n");
    return 0;
}

static void register_inspection(void)
{
    static s_cb_data callback;
    callback.reason = cbEndOfCompile;
    callback.cb_rtn = inspect_objects;
    /* No vpi_chk_error, object lookup or property query is legal here. */
    require(vpi_register_cb(&callback) != NULL, "callback registration failed");
}

void (*vlog_startup_routines[])(void) = {register_inspection, NULL};
