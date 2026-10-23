/* 10 — vpi_register_systf(): compiletf, calltf, sizetf, argument handles, and
 * the function return value.
 *
 * LRM 12.33.1: "The compiletf, calltf, and sizetf fields of the s_vpi_systf_data
 * structure shall be pointers to the user-provided applications which are to be
 * invoked by the system task/function callback mechanism. One or more of the
 * compiletf, calltf, and sizetf fields can be set to NULL if they are not
 * needed. Callbacks to the applications pointed to by the compiletf and sizetf
 * fields shall occur when the simulation data structure is compiled or built
 * (or for the first invocation if the system task or function is invoked from
 * an interactive mode). Callbacks to the application pointed to by the calltf
 * routine shall occur each time the system task or function is invoked during
 * simulation execution."
 *
 * LRM 12.33.1: "The sizetf application shall only [be] called if the PLI
 * application type is vpiSysFunction and the sysfunctype is vpiSizedFunc. If no
 * sizetf is provided, a user-defined system function of vpiSizedFunc shall
 * return 32-bits."
 *
 * LRM 12.33.1: "The user_data field of the s_vpi_systf_data structure shall
 * specify a user-defined value, which shall be passed back to the compiletf,
 * sizetf, and calltf applications when a callback occurs."
 *
 * LRM 11.6.16, NOTE 1: "The system task or function which invoked an
 * application shall be accessed with vpi_handle(vpiSysTfCall, NULL)". The same
 * clause gives "Tf call has a one-to-many relationship to expr tagged
 * vpiArgument", the property "tf name — str: vpiName", and for a sys func call
 * "-> sys func type — int: vpiSysFuncType" and "-> user-defined — bool:
 * vpiUserDefn".
 *
 * LRM 11.6.16, NOTE 4: "All user-defined system tasks or functions shall be
 * retrieved using vpi_iterate(), with vpiUserSystf as the type argument, and a
 * NULL reference argument."
 *
 * LRM 12.30, NOTE: "vpi_put_value() shall only return a function value in a
 * calltf application, when the call to the function is active. The action of
 * vpi_put_value() to a function shall be ignored when the function is not
 * active."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * Four registrations, against systf.v:
 *
 *   $p02_sum    vpiSysFunction / vpiIntFunc   returns arg0 + arg1
 *   $p02_note   vpiSysTask                    no return value
 *   $p02_wide   vpiSysFunction / vpiSizedFunc sizetf answers 40
 *   $p02_plain  vpiSysFunction / vpiSizedFunc sizetf is NULL
 *
 * COUNTS. systf.v calls $p02_sum from TWO call sites, the second inside a
 * three-iteration loop; $p02_note, $p02_wide and $p02_plain once each.
 * 12.33.1's two rates therefore give, exactly:
 *
 *            compiletf   sizetf   calltf
 *   $p02_sum      2          -        4      (1 + 3 loop iterations)
 *   $p02_note     1          -        1
 *   $p02_wide     1          1        1
 *   $p02_plain    1          0        1      (no sizetf was registered)
 *
 * and every compiletf and sizetf invocation must precede every calltf
 * invocation, because the first group happens at build and the second during
 * execution. A sequence counter asserts that.
 *
 * SIZES. vpi_get(vpiSize) on the call to $p02_wide must be 40, the number the
 * sizetf returned. On the call to $p02_plain it must be 32 — not 0, not the
 * width of the assignment target — because "if no sizetf is provided, a
 * user-defined system function of vpiSizedFunc shall return 32-bits".
 *
 * ARGUMENTS AND RETURNS, all by hand:
 *
 *   $p02_sum(3, 4)   -> 7
 *   $p02_sum(10, 0)  -> 10     i is 0 on the first loop iteration
 *   $p02_sum(10, 1)  -> 11
 *   $p02_sum(10, 2)  -> 12     so p02_systf.r ends at 12
 *
 * The second argument of the looping call site is the variable `i`, so a calltf
 * that read its arguments once at build time would see 0, 0, 0 and leave r at
 * 10. Asserting the SEQUENCE 10, 11, 12 rather than only the final value is
 * what makes that distinguishable.
 *
 *   $p02_wide   puts 40'h0123456789  -> p02_systf.sized reads "0123456789" hex
 *   $p02_plain  puts 32'hDEADBEEF    -> p02_systf.deflt reads "deadbeef" hex
 *
 * THE INACTIVE PUT. $p02_sum's compiletf also calls vpi_put_value on its own
 * call handle with 0x7777. "The action of vpi_put_value() to a function shall
 * be ignored when the function is not active", and at compile time it is not,
 * so 0x7777 must never appear in r. The final value of r, 12, is the assertion
 * that carries this: if the ignored put had taken effect the later calltf
 * results would still overwrite it, which is why the compiletf ALSO re-reads
 * the call and asserts nothing was stored.
 */

//! lrm 11.6.16
//! lrm 12.5
//! lrm 12.12
//! lrm 12.14
//! lrm 12.16
//! lrm 12.19
//! lrm 12.23
//! lrm 12.30
//! lrm 12.33
//! lrm 12.33.1
//! lrm 12.35
//! lrm 12.14:1
//! lrm 12.14:3
//! lrm 12.33:1
//! lrm 12.33.1:1
//! lrm 12.33.1:3
//! lrm 12.33.1:6
//! lrm 12.33.1:7
//! lrm 12.33.1:8
//! lrm 12.33.1:10
//! lrm 12.33.1:11
//! lrm 12.33:2
//! lrm 12.33.2
//! lrm 12.33.2:5
//! design ../digital/systf.v
//! stdout p02: 10_systf_digital checks=92

#include "p02_check.h"

static int order = 0;
static int sum_compile = 0, sum_call = 0, sum_last_compile_order = 0, sum_first_call_order = 0;
static int note_compile = 0, note_call = 0;
static int wide_compile = 0, wide_call = 0, wide_size = 0;
static int plain_compile = 0, plain_call = 0, plain_size = 0;
static PLI_INT32 sum_results[8];
static vpiHandle systf_sum;

static PLI_INT32 arg_value(vpiHandle call, int which)
{
  vpiHandle itr, arg = NULL;
  s_vpi_value v;
  int i;

  itr = vpi_iterate(vpiArgument, call);
  CHECK(itr != NULL, "a call with arguments must have an argument iterator");
  for (i = 0; i <= which; i++) {
    arg = vpi_scan(itr);
    CHECK(arg != NULL, "argument %d is missing", i);
  }
  v.format = vpiIntVal;
  vpi_get_value(arg, &v);
  expect_no_error("vpi_get_value on a systf argument");
  vpi_free_object(itr);
  return v.value.integer;
}

static int count_args(vpiHandle call)
{
  vpiHandle itr = vpi_iterate(vpiArgument, call);
  int n = 0;
  if (itr == NULL) return 0;
  while (vpi_scan(itr) != NULL) n++;
  return n;
}

/* ------------------------------------------------------------------ $p02_sum */

static PLI_INT32 sum_compiletf(PLI_BYTE8 *user_data)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  s_vpi_value v;
  char name[32];

  sum_compile++;
  sum_last_compile_order = ++order;

  CHECK(user_data != NULL && strcmp(user_data, "sum") == 0,
        "12.33.1: user_data must be passed back to compiletf");
  CHECK(call != NULL, "11.6.16 NOTE 1: vpi_handle(vpiSysTfCall, NULL) in compiletf");
  strcpy(name, vpi_get_str(vpiName, call));
  CHECK(strcmp(name, "$p02_sum") == 0, "the call's vpiName should be $p02_sum, got %s", name);
  CHECK(vpi_get(vpiUserDefn, call) == 1, "a user systf call must report vpiUserDefn");
  CHECK(vpi_get(vpiSysFuncType, call) == vpiIntFunc,
        "$p02_sum was registered vpiIntFunc");
  CHECK(count_args(call) == 2, "$p02_sum is called with two arguments");

  /* 12.30 NOTE: ignored, because the function is not active here. */
  v.format = vpiIntVal;
  v.value.integer = 0x7777;
  vpi_put_value(call, &v, NULL, vpiNoDelay);
  v.format = vpiIntVal;
  v.value.integer = -1;
  vpi_get_value(call, &v);
  CHECK(v.value.integer != 0x7777,
        "a put to an inactive function must be ignored, but 0x7777 stuck");
  return 0;
}

static PLI_INT32 sum_calltf(PLI_BYTE8 *user_data)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  s_vpi_value v;
  PLI_INT32 a, b;
  (void)user_data;

  if (sum_call == 0) sum_first_call_order = order + 1;
  ++order;

  a = arg_value(call, 0);
  b = arg_value(call, 1);
  v.format = vpiIntVal;
  v.value.integer = a + b;
  vpi_put_value(call, &v, NULL, vpiNoDelay);
  expect_no_error("vpi_put_value of a function return value");

  CHECK(sum_call < 8, "$p02_sum called more often than the design calls it");
  sum_results[sum_call++] = a + b;
  return 0;
}

/* ----------------------------------------------------------------- $p02_note */

static PLI_INT32 note_compiletf(PLI_BYTE8 *user_data)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  (void)user_data;
  note_compile++;
  ++order;
  CHECK(count_args(call) == 1, "$p02_note is called with one argument");
  return 0;
}

static PLI_INT32 note_calltf(PLI_BYTE8 *user_data)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  s_vpi_value v;
  (void)user_data;
  note_call++;
  ++order;
  v.format = vpiStringVal;
  vpi_get_value(vpi_scan(vpi_iterate(vpiArgument, call)), &v);
  CHECK_STR(v.value.str, "hello", "$p02_note's argument");
  return 0;
}

/* ----------------------------------------------------- $p02_wide / $p02_plain */

static PLI_INT32 wide_compiletf(PLI_BYTE8 *u) { (void)u; wide_compile++; ++order; return 0; }

static PLI_INT32 wide_sizetf(PLI_BYTE8 *u)
{
  (void)u;
  wide_size++;
  ++order;
  return 40;
}

static PLI_INT32 wide_calltf(PLI_BYTE8 *u)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  s_vpi_value v;
  (void)u;
  wide_call++;
  ++order;
  CHECK(vpi_get(vpiSize, call) == 40,
        "the sizetf answered 40, so the call must be 40 bits, got %d",
        (int)vpi_get(vpiSize, call));
  v.format = vpiHexStrVal;
  v.value.str = (PLI_BYTE8 *)"0123456789";
  vpi_put_value(call, &v, NULL, vpiNoDelay);
  return 0;
}

static PLI_INT32 plain_compiletf(PLI_BYTE8 *u) { (void)u; plain_compile++; ++order; return 0; }

static PLI_INT32 plain_calltf(PLI_BYTE8 *u)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
  s_vpi_value v;
  (void)u;
  plain_call++;
  ++order;
  CHECK(vpi_get(vpiSize, call) == 32,
        "a vpiSizedFunc with no sizetf is 32 bits, got %d",
        (int)vpi_get(vpiSize, call));
  v.format = vpiHexStrVal;
  v.value.str = (PLI_BYTE8 *)"deadbeef";
  vpi_put_value(call, &v, NULL, vpiNoDelay);
  return 0;
}

/* -------------------------------------------------------------------- census */

static int census(p_cb_data cb_data)
{
  s_vpi_value v;
  (void)cb_data;

  CHECK(sum_compile == 2,
        "$p02_sum has two call sites, so compiletf runs twice, ran %d", sum_compile);
  CHECK(sum_call == 4,
        "$p02_sum runs 1 + 3 times, so calltf runs four times, ran %d", sum_call);
  CHECK(note_compile == 1 && note_call == 1, "$p02_note: one site, one execution");
  CHECK(wide_compile == 1 && wide_call == 1, "$p02_wide: one site, one execution");
  CHECK(wide_size == 1,
        "the sizetf runs at build, once for the one call site, ran %d", wide_size);
  CHECK(plain_compile == 1 && plain_call == 1, "$p02_plain: one site, one execution");
  CHECK(plain_size == 0, "$p02_plain registered no sizetf, so none may be invoked");

  CHECK(sum_last_compile_order < sum_first_call_order,
        "every compiletf must run before any calltf: last compile %d, first call %d",
        sum_last_compile_order, sum_first_call_order);

  CHECK(sum_results[0] == 7,  "$p02_sum(3, 4) = 7, got %d",   (int)sum_results[0]);
  CHECK(sum_results[1] == 10, "$p02_sum(10, 0) = 10, got %d", (int)sum_results[1]);
  CHECK(sum_results[2] == 11, "$p02_sum(10, 1) = 11, got %d", (int)sum_results[2]);
  CHECK(sum_results[3] == 12, "$p02_sum(10, 2) = 12, got %d", (int)sum_results[3]);

  v.format = vpiIntVal;
  vpi_get_value(p02_by_name("p02_systf.r"), &v);
  CHECK(v.value.integer == 12, "r holds the last result, 12, got %d", (int)v.value.integer);

  v.format = vpiHexStrVal;
  vpi_get_value(p02_by_name("p02_systf.sized"), &v);
  CHECK_STR(v.value.str, "0123456789", "the 40-bit function's stored result");

  v.format = vpiHexStrVal;
  vpi_get_value(p02_by_name("p02_systf.deflt"), &v);
  CHECK_STR(v.value.str, "deadbeef", "the default-sized function's stored result");

  /* 11.6.16 NOTE 4: the four registrations, iterated back from NULL. */
  {
    vpiHandle itr = vpi_iterate(vpiUserSystf, NULL);
    int n = 0;
    CHECK(itr != NULL, "four systfs are registered, so the iterator must exist");
    while (vpi_scan(itr) != NULL) n++;
    CHECK(n == 4, "vpi_iterate(vpiUserSystf, NULL) should yield 4, yielded %d", n);
  }

  /* 12.14 round trip on one of them. */
  {
    s_vpi_systf_data info;
    memset(&info, 0, sizeof info);
    vpi_get_systf_info(systf_sum, &info);
    expect_no_error("vpi_get_systf_info");
    CHECK(info.type == vpiSysFunction, "type should round trip to vpiSysFunction");
    CHECK(info.sysfunctype == vpiIntFunc, "sysfunctype should round trip to vpiIntFunc");
    CHECK(info.tfname != NULL && strcmp(info.tfname, "$p02_sum") == 0,
          "tfname should round trip to $p02_sum");
    CHECK(info.calltf == sum_calltf && info.compiletf == sum_compiletf,
          "the two function pointers should round trip");
    CHECK(info.sizetf == NULL, "$p02_sum registered no sizetf");
  }

  p02_done("10_systf_digital");
  return 0;
}

static void register_census(void)
{
  static s_vpi_time  ct = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data   ccb;
  ccb.reason = cbReadOnlySynch; ccb.cb_rtn = census; ccb.obj = NULL;
  ccb.time = &ct; ccb.value = NULL; ccb.index = 0; ccb.user_data = NULL;
  CHECK(vpi_register_cb(&ccb) != NULL, "the census callback failed to register");
}

static void setup(void)
{
  static s_vpi_systf_data sum   = { vpiSysFunction, vpiIntFunc,   "$p02_sum",
                                    sum_calltf,   sum_compiletf,   NULL, "sum" };
  static s_vpi_systf_data note  = { vpiSysTask,    0,             "$p02_note",
                                    note_calltf,  note_compiletf,  NULL, NULL };
  static s_vpi_systf_data wide  = { vpiSysFunction, vpiSizedFunc, "$p02_wide",
                                    wide_calltf,  wide_compiletf,  wide_sizetf, NULL };
  static s_vpi_systf_data plain = { vpiSysFunction, vpiSizedFunc, "$p02_plain",
                                    plain_calltf, plain_compiletf, NULL, NULL };

  systf_sum = vpi_register_systf(&sum);
  expect_no_error("vpi_register_systf($p02_sum)");
  CHECK(systf_sum != NULL, "vpi_register_systf must return a handle");
  CHECK(vpi_register_systf(&note)  != NULL, "$p02_note registration failed");
  CHECK(vpi_register_systf(&wide)  != NULL, "$p02_wide registration failed");
  CHECK(vpi_register_systf(&plain) != NULL, "$p02_plain registration failed");
  /* IEEE 1364-2005 26.2.4: cbReadOnlySynch is not a startup reason. */
  p02_defer(register_census);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
