/* IEEE26.6.7/8/9: legacy memory methods return reg-array/reg objects;
 * variable arrays (including real) instead iterate var-select objects.
 * All traversal is deferred to the legal end-of-compile phase (26.2.4).
 */
//! lrm 11.3.1
//! lrm 11.6.11
//! lrm 12.2
//! lrm 12.3
//! lrm 12.5
//! lrm 12.16
//! lrm 12.19
//! lrm 12.21
//! lrm 12.23
//! lrm 12.31.4
//! lrm 12.33.2
//! lrm 12.35
//! design array_object_kinds.v
//! stderr pli-array-kinds reg-words=2 real-selects=2

#include "vpi_user.h"
#include <stdio.h>
#include <stdlib.h>

static void require(int condition, const char *message)
{
    if (!condition) {
        fprintf(stderr, "audit_array_object_kinds: %s\n", message);
        exit(1);
    }
}

static unsigned members(vpiHandle array, PLI_INT32 method, PLI_INT32 type)
{
    vpiHandle iterator = vpi_iterate(method, array), word, index;
    s_vpi_value value;
    unsigned count = 0, seen = 0;
    require(iterator != NULL, "missing word iteration");
    while ((word = vpi_scan(iterator)) != NULL) {
        require(++count <= 2, "too many words");
        require(vpi_get(vpiType, word) == type, "relationship tag confused with object type");
        require(vpi_compare_objects(vpi_handle(vpiParent, word), array) == 1, "wrong word parent");
        if (type == vpiReg) require(vpi_get(vpiSize, word) == 8, "reg word size is not bits");
        index = vpi_handle(vpiIndex, word);
        require(index != NULL, "missing word index expression");
        value.format = vpiIntVal;
        vpi_get_value(index, &value);
        require(vpi_chk_error(NULL) == 0, "cannot read index");
        require(value.value.integer == 0 || value.value.integer == 1, "index out of range");
        require(!(seen & (1u << value.value.integer)), "duplicate word index");
        seen |= 1u << value.value.integer;
    }
    require(vpi_chk_error(NULL) == 0, "iteration ended with error");
    require(count == 2 && seen == 3, "missing words");
    return count;
}

static PLI_INT32 inspect_arrays(p_cb_data callback)
{
    vpiHandle top, memory, iterator, real_array;
    (void)callback;
    top = vpi_handle_by_name("audit_array_object_kinds", NULL);
    require(top != NULL, "missing top");
    iterator = vpi_iterate(vpiMemory, top);
    require(iterator != NULL, "missing legacy memory iteration");
    memory = vpi_scan(iterator);
    require(memory != NULL, "missing memory");
    require(vpi_scan(iterator) == NULL, "unexpected additional memory");
    require(vpi_get(vpiType, memory) == vpiRegArray, "legacy method must return reg-array object");
    require(vpi_get(vpiIsMemory, memory) == 1, "missing memory flag");
    require(vpi_get(vpiSize, memory) == 2, "array size must count words not bits");
    (void)members(memory, vpiMemoryWord, vpiReg);
    real_array = vpi_handle_by_name("audit_array_object_kinds.samples", NULL);
    require(real_array != NULL, "missing real array");
    require(vpi_get(vpiType, real_array) == vpiRealVar, "real array has wrong variable type");
    require(vpi_get(vpiArray, real_array) == 1, "real array lacks array flag");
    require(vpi_get(vpiSize, real_array) == 2, "variable-array size must count variables");
    (void)members(real_array, vpiVarSelect, vpiVarSelect);
    fprintf(stderr, "pli-array-kinds reg-words=2 real-selects=2\n");
    return 0;
}

static void register_array_kinds(void)
{
    static s_cb_data callback;
    callback.reason = cbEndOfCompile;
    callback.cb_rtn = inspect_arrays;
    require(vpi_register_cb(&callback) != NULL, "registration failed");
}

void (*vlog_startup_routines[])(void) = {register_array_kinds, NULL};
