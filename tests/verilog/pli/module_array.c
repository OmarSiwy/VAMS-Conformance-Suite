/* IEEE26.6.1(d),26.6.2: module-array membership/index graphs.
 * Startup only registers; all queries occur at cbEndOfCompile (26.2.4).
 * Iterate members without assuming their order. Numeric array indices are
 * obtained from expression handles, not invented integer properties.
 */
//! lrm 11.3.1
//! lrm 12.2
//! lrm 12.3
//! lrm 12.5
//! lrm 12.16
//! lrm 12.19
//! lrm 12.20
//! lrm 12.21
//! lrm 12.23
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 12.35
//! lrm 12.20:1
//! lrm 12.20:1001
//! lrm 12.21:1001
//! design module_array.v
//! stderr pli-module-array members=2 indices=0,1

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>

static void require(int condition, const char *message)
{
    if (!condition) {
        fprintf(stderr, "audit_module_array: %s\n", message);
        exit(1);
    }
}

static PLI_INT32 inspect_array(p_cb_data callback)
{
    vpiHandle top, array, iterator, member, index, parent, direct;
    s_vpi_value value;
    unsigned seen = 0, count = 0;
    (void)callback;
    top = vpi_handle_by_name("audit_module_array", NULL);
    require(top != NULL, "missing top");
    require(vpi_handle(vpiIndex, top) == NULL, "nonarray module has an index");
    require(vpi_chk_error(NULL) == 0, "valid absent index treated as an error");
    array = vpi_handle_by_name("audit_module_array.u", NULL);
    require(array != NULL, "missing module-array object");
    require(vpi_get(vpiType, array) == vpiModuleArray, "wrong array type");
    require(vpi_get(vpiSize, array) == 2, "array size is not two instances");
    iterator = vpi_iterate(vpiModule, array);
    require(iterator != NULL, "missing member iteration");
    while ((member = vpi_scan(iterator)) != NULL) {
        require(++count <= 2, "too many members");
        require(vpi_get(vpiType, member) == vpiModule, "member is not a module");
        require(vpi_get(vpiArray, member) == 1, "member lacks array flag");
        parent = vpi_handle(vpiModuleArray, member);
        require(vpi_compare_objects(parent, array) == 1, "wrong reverse array relationship");
        index = vpi_handle(vpiIndex, member);
        require(index != NULL, "missing index expression");
        value.format = vpiIntVal;
        vpi_get_value(index, &value);
        require(vpi_chk_error(NULL) == 0, "cannot read index expression");
        require(value.value.integer == 0 || value.value.integer == 1, "index outside declaration");
        require((seen & (1u << value.value.integer)) == 0, "duplicate array member");
        seen |= 1u << value.value.integer;
        direct = vpi_handle_by_index(array, value.value.integer);
        require(vpi_compare_objects(direct, member) == 1, "direct index differs from iteration");
    }
    require(vpi_chk_error(NULL) == 0, "iteration termination is not successful");
    require(count == 2 && seen == 3, "missing array members");
    fprintf(stderr, "pli-module-array members=2 indices=0,1\n");
    return 0;
}

static void register_array_probe(void)
{
    static s_cb_data callback;
    callback.reason = cbEndOfCompile;
    callback.cb_rtn = inspect_array;
    require(vpi_register_cb(&callback) != NULL, "registration failed");
}

void (*vlog_startup_routines[])(void) = {register_array_probe, NULL};
