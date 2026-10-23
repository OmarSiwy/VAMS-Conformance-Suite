/* b 26.1 — user-defined system task/function registration and the three
 * application routines (sizetf, compiletf, calltf), over systf.v.
 *
 * Every call here is to a BUILT-IN name the application overrides, which
 * §20.4 allows, so the design elaborates whether or not the override takes
 * and the run tells the override from the built-in.
 *
 * IEEE 1364-2005:
 *
 * §20.2, p. 367: "The first character of the name shall be the dollar sign
 * ($). The remaining characters shall be letters, digits, the underscore
 * character (_), or the dollar sign ($). Uppercase and lowercase letters shall
 * be considered to be unique—the name is case sensitive."
 *
 * §20.3, p. 367: "A user-defined system function can read and modify the
 * arguments of the function, and it returns a value. The bit width of a
 * vector shall be determined by a user-supplied sizetf application (see
 * 27.34)."
 *
 * §20.4, p. 367: "If a user-provided PLI application is associated with the
 * same name as a built-in system task/function (using the PLI mechanism), the
 * user-provided C application shall override the built-in system
 * task/function, replacing its functionality with that of the user-provided C
 * application." And: "The system functions $signed and $unsigned can be
 * overridden. ... If overridden, the PLI version shall have the same return
 * width for all instances of the system function. The PLI return width is
 * defined by the PLI sizetf routine."
 *
 * §20.7, p. 368: "When the PLI applications associated with a user-defined
 * system task/function are called, the task/function arguments are not passed
 * to the PLI application. Instead, a number of PLI routines are provided that
 * allow the PLI applications to read and write to the task/function
 * arguments."
 *
 * §26.1, p. 374: "User-defined system tasks and functions are created using
 * the routine vpi_register_systf() (see 27.34)." and "the user-defined system
 * task/function name shall begin with a dollar sign ($)".
 *
 * §26.1.1, p. 374: "Each sizetf routine shall be called at most once. It shall
 * be called if its associated system function appears in the design. ... The
 * sizetf routine shall not be called for user-defined system tasks or for
 * functions whose sysfunctype is set to vpiRealFunc."
 *
 * §26.1.2, p. 374: "The compiletf routine shall be called one time for each
 * instance of a system task/function in the source description."
 *
 * §26.1.3, p. 375: "A calltf VPI application routine shall be called each time
 * the associated user-defined system task/function is executed within the
 * Verilog HDL source code."
 *
 * §26.1.4, p. 375: "When the software product calls these routines, it will
 * pass to them the value supplied in the s_vpi_systf_data structure's
 * user_data field when the user-defined system task/function was registered."
 *
 * §26.2.4, p. 376-377: "Only two routines can be called at this time: —
 * vpi_register_systf() — vpi_register_cb() In addition, the vpi_register_cb()
 * routine can only be called for the following reasons: — cbEndOfCompile —
 * cbStartOfSimulation — cbEndOfSimulation — cbUnresolvedSystf — cbError —
 * cbPLIError". p. 377: "After the sizetf routines are called, the routines
 * registered for reason cbEndOfCompile are called."
 *
 * §27.11, p. 427: "The VPI routine vpi_get_systf_info() shall return
 * information about a user-defined system task/function callback in an
 * s_vpi_systf_data structure."
 *
 * §27.13, p. 429: "This routine shall return the value of the user data
 * associated with a previous call to vpi_put_userdata() for a user-defined
 * system task/function call handle. If no user data had been previously
 * associated with the object or if the routine fails, the return value shall
 * be NULL." §27.31, p. 450: "This routine will associate the value of the
 * input userdata with the specified user-defined system task/function call
 * handle. ... The routine will return a value of 1 on success or a 0 if it
 * fails."
 *
 * §27.34.1, p. 462: "The type field value shall be an integer constant of
 * vpiSysTask or vpiSysFunc." "The sysfunctype field shall be an integer
 * constant of vpiIntFunc, vpiRealFunc, vpiTimeFunc, vpiSizedFunc, or
 * vpiSizedSignedFunc." "The name shall begin with a dollar sign ($) and shall
 * be followed by one or more ASCII characters that are legal in Verilog HDL
 * simple identifiers." "The sizetf application shall only be called if the
 * PLI application type is vpiSysFunc and the sysfunctype is vpiSizedFunc or
 * vpiSizedSignedFunc." "The contents of the user_data field ... shall be the
 * only argument passed to the compiletf, sizetf, and calltf routines".
 *
 * §27.34.2, p. 463: "A means of initializing system task/function callbacks
 * ... shall be provided by placing routines in a NULL-terminated static array,
 * vlog_startup_routines."
 *
 * §27.34.3, p. 464: "Allocate a static array of s_vpi_systf_data structures,
 * and call vpi_register_systf() once for each structure in the array."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * REGISTRATION (from the startup routine, by §27.34.3's array loop):
 *   $unsigned   vpiSysFunc / vpiSizedFunc        sizetf answers 40
 *   $signed     vpiSysFunc / vpiSizedSignedFunc  sizetf answers 16
 *   $realtime   vpiSysFunc / vpiRealFunc         sizetf present, never due
 *   $monitoroff vpiSysTask                       sizetf present, never due
 * each with user_data = the one `cookie`. §20.2's name rules: "$b_Name$9"
 * and "$b_name$9" differ only in case, so both register and are two objects.
 * No malformed registration is asserted refused: §20.2's and §27.34.1's
 * name, type and sysfunctype rules bind the application, and §27.34 names no
 * failure value for a registration that breaks them.
 *
 * STARTUP (§26.2.4): the two action reasons this file needs, cbEndOfCompile
 * and cbEndOfSimulation, are two of the six and register. Only the two
 * registration routines are called there; every handle is checked later,
 * at cbEndOfCompile. What the sentence forbids binds the application; the
 * clause names no failure value for a call it rules out, so no refusal is
 * asserted.
 *
 * BUILD, read at cbEndOfCompile (after every sizetf, §26.2.4):
 *   compiletf: $unsigned 2 (call sites 1 and 2 of the design), $signed 1,
 *              $realtime 1, $monitoroff 1; calltf: 0 of each.
 *   sizetf:    $unsigned 1 (it appears, "at most once"), $signed 1 (it
 *              appears and is vpiSizedSignedFunc), $realtime 0 (vpiRealFunc),
 *              $monitoroff 0 (a task).
 *   §27.31/§27.13: on site 1's call, vpi_get_userdata is NULL before any
 *   vpi_put_userdata, the put returns 1, and the get then returns the
 *   pointer stored.
 *   Every call is handed `cookie`. Inside $unsigned's compiletf,
 *   vpi_handle(vpiSysTfCall, NULL) is the call, its one vpiArgument has
 *   vpiSize 1 at site 1 (1'b1) and 64 at site 2 (64'h0) — §20.7's routines.
 *   §26.1.2 fixes no order among call sites, so the two sizes are accepted
 *   in either order.
 *
 * RUN, read at cbEndOfSimulation: site 1 executes twice, site 2 once, so
 * $unsigned's calltf runs 3 times; $signed, $realtime, $monitoroff once. The
 * $unsigned calltf puts 40'h8000000001 into a value its sizetf made 40 bits
 * wide (§20.4 "The PLI return width is defined by the PLI sizetf routine"),
 * so the 40-bit `a` and `b` read 0x8000000001 — not the built-in's 1 and 0.
 * The $signed calltf puts 16'h8001 into its 16 bits, so `c` reads 0x8001 —
 * not the built-in's 4'sb1000 sign-extended, 16'hfff8.
 */

//! lrm 12.33.1
//! lrm 12.33.1:9
//! inherited IEEE 1364-2005 20.2
//! inherited IEEE 1364-2005 20.3
//! inherited IEEE 1364-2005 20.4
//! inherited IEEE 1364-2005 20.7
//! inherited IEEE 1364-2005 26.1
//! inherited IEEE 1364-2005 26.1.1
//! inherited-reject IEEE 1364-2005 26.1.1
//! inherited IEEE 1364-2005 26.1.2
//! inherited IEEE 1364-2005 26.1.3
//! inherited IEEE 1364-2005 26.1.4
//! inherited IEEE 1364-2005 26.2.4
//! inherited IEEE 1364-2005 27.11
//! inherited IEEE 1364-2005 27.13
//! inherited IEEE 1364-2005 27.31
//! inherited-reject IEEE 1364-2005 27.11
//! inherited IEEE 1364-2005 27.34
//! inherited IEEE 1364-2005 27.34.1
//! inherited IEEE 1364-2005 27.34.2
//! inherited IEEE 1364-2005 27.34.3
//! design systf.v
//! stdout p02: b_26_1_systf checks=45

#include "b_check.h"

enum { U, S, R, M, N };
static char cookie[] = "b_26_1";
static int sizes[N], compiles[N], calls[N], bad_ud = 0;
static int arg_sizes[2], sites = 0;

static void ud(PLI_BYTE8 *u) { if (u != cookie) bad_ud++; }

static void put_hex(const char *hex)
{
  s_vpi_value v;
  v.format = vpiHexStrVal;
  v.value.str = (PLI_BYTE8 *)hex;
  vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
}

static PLI_INT32 u_size(PLI_BYTE8 *u) { ud(u); sizes[U]++; return 40; }
static PLI_INT32 s_size(PLI_BYTE8 *u) { ud(u); sizes[S]++; return 16; }
static PLI_INT32 r_size(PLI_BYTE8 *u) { ud(u); sizes[R]++; return 64; }
static PLI_INT32 m_size(PLI_BYTE8 *u) { ud(u); sizes[M]++; return 1; }

static PLI_INT32 u_compile(PLI_BYTE8 *u)
{
  vpiHandle call = vpi_handle(vpiSysTfCall, NULL), itr, arg;
  ud(u);
  compiles[U]++;
  CHECK(call != NULL && vpi_get(vpiType, call) == vpiSysFuncCall, "compiletf: the call is active");
  CHECK(strcmp(vpi_get_str(vpiName, call), "$unsigned") == 0, "compiletf: of $unsigned");
  itr = vpi_iterate(vpiArgument, call);
  CHECK(itr != NULL, "20.7: the arguments are reached through vpi_iterate(vpiArgument)");
  arg = vpi_scan(itr);
  CHECK(arg != NULL && vpi_scan(itr) == NULL, "each $unsigned call has one argument");
  if (sites < 2) arg_sizes[sites] = vpi_get(vpiSize, arg);
  if (sites == 0) {
    CHECK(vpi_get_userdata(call) == NULL, "27.13: nothing stored yet");
    CHECK(vpi_put_userdata(call, arg_sizes) == 1, "27.31: 1 on success");
    CHECK(vpi_get_userdata(call) == (void *)arg_sizes, "27.13: the stored value");
  }
  sites++;
  return 0;
}
static PLI_INT32 s_compile(PLI_BYTE8 *u) { ud(u); compiles[S]++; return 0; }
static PLI_INT32 r_compile(PLI_BYTE8 *u) { ud(u); compiles[R]++; return 0; }
static PLI_INT32 m_compile(PLI_BYTE8 *u) { ud(u); compiles[M]++; return 0; }

static PLI_INT32 u_call(PLI_BYTE8 *u) { ud(u); calls[U]++; put_hex("8000000001"); return 0; }
static PLI_INT32 s_call(PLI_BYTE8 *u) { ud(u); calls[S]++; put_hex("8001"); return 0; }
static PLI_INT32 r_call(PLI_BYTE8 *u) { ud(u); calls[R]++; return 0; }
static PLI_INT32 m_call(PLI_BYTE8 *u) { ud(u); calls[M]++; return 0; }

static s_vpi_systf_data overrides[] = {
  { vpiSysFunc, vpiSizedFunc,       "$unsigned",   u_call, u_compile, u_size, cookie },
  { vpiSysFunc, vpiSizedSignedFunc, "$signed",     s_call, s_compile, s_size, cookie },
  { vpiSysFunc, vpiRealFunc,        "$realtime",   r_call, r_compile, r_size, cookie },
  { vpiSysTask, 0,                  "$monitoroff", m_call, m_compile, m_size, cookie },
  { 0, 0, NULL, NULL, NULL, NULL, NULL }
};
static vpiHandle reg_h[N];

static long long hex_of(const char *name)
{
  s_vpi_value v;
  v.format = vpiHexStrVal;
  vpi_get_value(p02_by_name(name), &v);
  return strtoll(v.value.str, NULL, 16);
}

static vpiHandle case_h[2], eoc_h, eos_h;

static PLI_INT32 end_of_compile(p_cb_data d)
{
  s_vpi_systf_data info;
  int k;
  (void)d;
  CHECK(compiles[U] == 2 && compiles[S] == 1 && compiles[R] == 1 && compiles[M] == 1,
        "26.1.2: one compiletf per call site, got %d %d %d %d",
        compiles[U], compiles[S], compiles[R], compiles[M]);
  CHECK(calls[U] + calls[S] + calls[R] + calls[M] == 0, "no calltf before simulation");
  CHECK(sizes[U] == 1, "26.1.1: the $unsigned sizetf once, for two call sites, got %d", sizes[U]);
  CHECK(sizes[S] == 1, "27.34.1: the sizetf of a vpiSizedSignedFunc, got %d", sizes[S]);
  CHECK(sizes[R] == 0, "26.1.1: no sizetf for a vpiRealFunc");
  CHECK(sizes[M] == 0, "26.1.1: no sizetf for a system task");
  CHECK(bad_ud == 0, "26.1.4: every routine is handed the registered user_data");
  CHECK(sites == 2 && arg_sizes[0] + arg_sizes[1] == 65 && arg_sizes[0] * arg_sizes[1] == 64,
        "20.7: the two call sites' arguments are 1 and 64 bits");

  /* 27.34 / 20.2, registered at startup and checked here (§26.2.4). */
  for (k = 0; k < N; k++) CHECK(reg_h[k] != NULL, "27.34: override %d registered", k);
  CHECK(case_h[0] != NULL && case_h[1] != NULL, "20.2: $b_Name$9 and $b_name$9 are two names");
  CHECK(vpi_compare_objects(case_h[0], case_h[1]) == 0, "20.2: and two registrations");
  CHECK(eoc_h != NULL && eos_h != NULL, "26.2.4: the two action reasons registered at startup");

  /* 27.11: the registration reads back; a module is no systf callback. */
  memset(&info, 0, sizeof info);
  vpi_get_systf_info(reg_h[S], &info);
  expect_no_error("vpi_get_systf_info($signed)");
  CHECK(info.type == vpiSysFunc && info.sysfunctype == vpiSizedSignedFunc &&
        strcmp(info.tfname, "$signed") == 0 && info.sizetf == s_size &&
        info.user_data == cookie, "27.11: $signed reads back as registered");
  memset(&info, 0, sizeof info);
  vpi_get_systf_info(p02_by_name("b_26_1_systf"), &info);
  expect_refusal("vpi_get_systf_info(module)");
  CHECK(info.tfname == NULL, "27.11: nothing is written for a module handle");
  return 0;
}

static PLI_INT32 end_of_simulation(p_cb_data d)
{
  (void)d;
  CHECK(calls[U] == 3, "26.1.3: the $unsigned calltf once per execution, got %d", calls[U]);
  CHECK(hex_of("b_26_1_systf.a") == 0x8000000001LL && hex_of("b_26_1_systf.b") == 0x8000000001LL,
        "20.4: a and b hold the override's 40-bit result");
  CHECK(hex_of("b_26_1_systf.c") == 0x8001, "20.4: c holds the $signed override's 16-bit result");
  CHECK(calls[S] == 1 && calls[R] == 1 && calls[M] == 1, "20.3: each overriding function and task runs once");
  CHECK(hex_of("b_26_1_systf.a") == 0x8000000001LL || hex_of("b_26_1_systf.a") == 1,
        "the design ran: a is the override's or the built-in's 1");
  p02_done("b_26_1_systf");
  return 0;
}

static void startup(void)
{
  static s_vpi_systf_data named[] = {
    { vpiSysTask, 0, "$b_Name$9", m_call, NULL, NULL, NULL },
    { vpiSysTask, 0, "$b_name$9", m_call, NULL, NULL, NULL },
  };
  static s_cb_data eoc, eos;
  p_vpi_systf_data p;
  int k = 0;

  /* 27.34.3: the array loop, terminated by the zero element. Only
   * vpi_register_systf() and vpi_register_cb() are called here (26.2.4). */
  for (p = overrides; p->type; p++) reg_h[k++] = vpi_register_systf(p);
  case_h[0] = vpi_register_systf(&named[0]);
  case_h[1] = vpi_register_systf(&named[1]);

  /* 26.2.4: cbEndOfCompile and cbEndOfSimulation are two of the six. */
  eoc.reason = cbEndOfCompile;
  eoc.cb_rtn = end_of_compile;
  eoc_h = vpi_register_cb(&eoc);
  eos.reason = cbEndOfSimulation;
  eos.cb_rtn = end_of_simulation;
  eos_h = vpi_register_cb(&eos);
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
