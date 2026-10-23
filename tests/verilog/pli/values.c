/* b 27 values — vpi_get_value(), vpi_put_value() and vpi_get_time(), over
 * values.v (`timescale 1us/1ns: 1 us = 1000 ticks).
 *
 * IEEE 1364-2005:
 *
 * §27.12, p. 428: "The VPI routine vpi_get_time() shall retrieve the current
 * simulation time, using the time scale of the object. If obj is NULL, the
 * simulation time is retrieved using the simulation time unit. ... The memory
 * for the time_p structure shall be allocated by the application."
 *
 * §27.14, p. 429-430: "When the format field is vpiObjTypeVal, the routine shall
 * fill in the value and change the format field based on the object type, as
 * follows: — For an integer, vpiIntVal — For a real, vpiRealVal — For a
 * scalar, either vpiScalar or vpiStrength — For a time variable, vpiTimeVal
 * with vpiSimTime — For a vector, vpiVectorVal". p. 430: "The size of this
 * array shall be determined by the size of the vector, where array_size =
 * ((vector_size-1)/32 + 1). The lsb of the vector shall be represented by the
 * lsb of the 0-indexed element of s_vpi_vecval array." Table 27-3, p. 431,
 * vpiOctStrVal/vpiHexStrVal: "x when all the bits are x / X when some of the
 * bits are x / z when all the bits are z / Z when some of the bits are z";
 * vpiIntVal: "Any bits x or z in the value of the object are mapped to a 0";
 * vpiStringVal: "A string where each 8-bit group of the value of the object is
 * assumed to represent an ASCII character". p. 431: "If the object is a reg or
 * variable, the strength will always be returned as strong." p. 433: "Real
 * valued objects shall be converted to an integer using the rounding defined
 * in 4.8.2 before being returned in a format other than vpiRealVal and
 * vpiStringVal. If the format specified is vpiStringVal, then the value shall
 * be returned as a string representation of a floating point number."
 *
 * §27.32, p. 451: "vpiInertialDelay All scheduled events on the object shall
 * be removed before this event is scheduled. vpiTransportDelay All events on
 * the object scheduled for times later than this event shall be removed
 * (modified transport delay). vpiPureTransportDelay No events on the object
 * shall be removed (transport delay). vpiNoDelay The object shall be set to
 * the passed value with no delay." "vpiCancelEvent A previously scheduled
 * event shall be cancelled. The object passed to vpi_put_value() shall be a
 * handle to an object of type vpiSchedEvent." "If the flags argument also has
 * the bit mask vpiReturnEvent, vpi_put_value() shall return a handle of type
 * vpiSchedEvent to the newly scheduled event, provided there is some form of a
 * delay and an event is scheduled. If the bit mask is not used, or if no delay
 * is used, or if an event is not scheduled, the return value shall be NULL."
 * "It shall not be an error to cancel an event that has already occurred. The
 * scheduled event can be tested by calling vpi_get() with the flag
 * vpiScheduled." "When vpi_put_value() is called for an object of type vpiNet
 * ... the value supplied overrides the resolved value of the net. This value
 * shall remain in effect until one of the drivers of the net changes value."
 * p. 452: "It shall be illegal to specify the format of the value as
 * vpiStringVal when putting a value to a real variable ... It shall be illegal
 * to specify the format of the value as vpiStrengthVal when putting a value to
 * a vector object." "Calling vpi_put_value() on an object of type
 * vpiNamedEvent shall cause the named event to toggle. Objects of type
 * vpiNamedEvent shall not require an actual value, and the value_p argument
 * may be NULL." p. 453: "For vpiScaledRealTime, the indicated time shall be in
 * the timescale associated with the object." And p. 451: "The routine can be
 * applied to nets, regs, variables, variable selects, memory words, named
 * events, system function calls, sequential UDPs, and scheduled events."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * GET, at t=0 (cbReadWriteSynch, after the initial block):
 *   known 12'ha71      bin "101001110001", dec "2673", hex "a71".
 *   mixed 12'b1010_zzzz_01x1, bits 11..0 = 1 0 1 0 z z z z 0 1 x 1:
 *         octal groups [11:9] 101 -> 5, [8:6] 0zz -> Z, [5:3] zz0 -> Z,
 *         [2:0] 1x1 -> X: "5ZZX"; hex [11:8] 1010 -> a, [7:4] zzzz -> z,
 *         [3:0] 01x1 -> X: "azX".
 *   xz 4'b1x1z as vpiIntVal: x, z -> 0, so 1010 = 10.
 *   one -> vpi1, hiz -> vpiZ (vpiScalarVal).
 *   text "VerA!" (40'h5665724121) as vpiStringVal -> "VerA!".
 *   wide 64'h00000001FFFFFFFF as vpiVectorVal: (64-1)/32+1 = 2 elements,
 *         [0].aval 0xFFFFFFFF, [1].aval 1, both bval 0.
 *   rp 2.5 -> vpiRealVal 2.5; vpiIntVal 3 (§4.8.2: ties away from zero);
 *         rn -2.5 -> -3; rp as vpiStringVal parses back to 2.5.
 *   vpiObjTypeVal: k -> vpiIntVal -7; rp -> vpiRealVal; one -> vpiScalarVal
 *         or vpiStrengthVal; known -> vpiVectorVal; tv -> vpiTimeVal, and
 *         5000000000 = 0x1_2A05F200 is high 1, low 705032704.
 *   vpiStrengthVal (Annex G 10) of the reg `one`: logic vpi1 driven strong
 *         (s1 = vpiStrongDrive, Annex G 0x40; s0 is not asserted, since the
 *         clause does not say what a 1 carries in its 0 strength).
 *   Format 9999 is none of Table 27-3's -> an error.
 *
 * PUT, at t=0 (1 us = 1000 ticks; delays are scaled reals in the module's
 * 1 us unit):
 *   q  vpiNoDelay 8'h0A: reads 0x0A at once, and returns NULL.
 *   q  vpiInertialDelay 8'h11 at +2.0 (returning event e1, vpiScheduled 1),
 *      then vpiInertialDelay 8'h22 at +1.0, which removes e1's event:
 *      q is 0x22 from 1 us on, still 0x22 at 2.5 us.
 *   p  vpiPureTransportDelay 8'h33 at +3.0 and 8'h44 at +4.0: both happen,
 *      p = 0x33 at 3.5 us and 0x44 at 4.5 us. Then vpiTransportDelay 8'h55
 *      at +6.0 and 8'h66 at +5.0: the second removes the later first, so
 *      p = 0x66 at 5.5 us and at 6.5 us.
 *   c  vpiInertialDelay|vpiReturnEvent 8'h77 at +7.0 -> event e2, cancelled
 *      at once: c is still 0 at 7.5 us.
 *   ev toggled with value_p NULL: `always @ev` counts hits = 1.
 *   wn (a net driven by d = 8'h01) vpiNoDelay 8'hAA: reads 0xAA until the
 *      driver d changes at 8 us, then the net resolves again to 0x02.
 * REFUSED: vpiStringVal onto the real rq and vpiStrengthVal onto the vector q
 * (illegal, rq stays 1.25 and q stays 0x0A); a put onto the parameter P
 * (not in the list of objects); vpiCancelEvent with q, which is no
 * vpiSchedEvent.
 *
 * TIME, at 1.5 us: vpi_get_time(NULL, vpiSimTime) low 1500; (module,
 * vpiScaledRealTime) 1.5; (NULL, vpiScaledRealTime) 1500.0 in the 1 ns
 * simulation unit. A NULL time_p is no application-allocated structure.
 */

//! lrm 12.16
//! lrm 12.16:5
//! lrm 12.30
//! lrm 12.30:19
//! inherited IEEE 1364-2005 27.12
//! inherited-reject IEEE 1364-2005 27.12
//! inherited IEEE 1364-2005 27.14
//! inherited-reject IEEE 1364-2005 27.14
//! inherited IEEE 1364-2005 27.32
//! inherited-reject IEEE 1364-2005 27.32
//! design values.v
//! stdout p02: b_27_values checks=140

#include "b_check.h"

static vpiHandle top, q, p, c, wn, rq;

static PLI_INT32 int_of(vpiHandle h)
{
  s_vpi_value v;
  v.format = vpiIntVal;
  vpi_get_value(h, &v);
  return v.value.integer;
}

static const char *str_of(const char *name, PLI_INT32 fmt)
{
  s_vpi_value v;
  v.format = fmt;
  vpi_get_value(p02_by_name(name), &v);
  expect_no_error("vpi_get_value");
  return v.value.str;
}

static void put(vpiHandle h, PLI_INT32 val, double delay, PLI_INT32 flags, vpiHandle *ev)
{
  s_vpi_value v;
  s_vpi_time t;
  vpiHandle r;
  v.format = vpiIntVal;
  v.value.integer = val;
  t.type = vpiScaledRealTime;
  t.high = t.low = 0;
  t.real = delay;
  r = vpi_put_value(h, &v, &t, flags);
  expect_no_error("vpi_put_value");
  if (ev) *ev = r;
}

static void get_values(void)
{
  s_vpi_value v;
  s_vpi_strengthval st;
  double d;
  char *end;

  CHECK(strcmp(str_of("b_27_values.known", vpiBinStrVal), "101001110001") == 0, "27.14: bin");
  CHECK(strcmp(str_of("b_27_values.known", vpiDecStrVal), "2673") == 0, "27.14: dec");
  CHECK(strcmp(str_of("b_27_values.known", vpiHexStrVal), "a71") == 0, "27.14: hex");
  CHECK(strcmp(str_of("b_27_values.mixed", vpiOctStrVal), "5ZZX") == 0,
        "27.14: Table 27-3 octal, got %s", str_of("b_27_values.mixed", vpiOctStrVal));
  CHECK(strcmp(str_of("b_27_values.mixed", vpiHexStrVal), "azX") == 0,
        "27.14: Table 27-3 hex, got %s", str_of("b_27_values.mixed", vpiHexStrVal));
  CHECK(int_of(p02_by_name("b_27_values.xz")) == 10, "27.14: x and z map to 0 in vpiIntVal");
  CHECK(strcmp(str_of("b_27_values.text", vpiStringVal), "VerA!") == 0, "27.14: string");

  v.format = vpiScalarVal;
  vpi_get_value(p02_by_name("b_27_values.one"), &v);
  CHECK(v.value.scalar == vpi1, "27.14: one is vpi1");
  vpi_get_value(p02_by_name("b_27_values.hiz"), &v);
  CHECK(v.value.scalar == vpiZ, "27.14: hiz is vpiZ");

  v.format = vpiVectorVal;
  vpi_get_value(p02_by_name("b_27_values.wide"), &v);
  CHECK(v.value.vector[0].aval == (PLI_INT32)0xFFFFFFFF && v.value.vector[0].bval == 0 &&
        v.value.vector[1].aval == 1 && v.value.vector[1].bval == 0,
        "27.14: the lsb is element 0's lsb, two elements");

  v.format = vpiRealVal;
  vpi_get_value(p02_by_name("b_27_values.rp"), &v);
  CHECK(v.value.real == 2.5, "27.14: rp is 2.5");
  CHECK(int_of(p02_by_name("b_27_values.rp")) == 3, "27.14: 2.5 rounds away from zero to 3");
  CHECK(int_of(p02_by_name("b_27_values.rn")) == -3, "27.14: -2.5 rounds to -3");
  d = strtod(str_of("b_27_values.rp", vpiStringVal), &end);
  CHECK(d == 2.5 && *end == '\0', "27.14: a real as vpiStringVal is its decimal string");

  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.k"), &v);
  CHECK(v.format == vpiIntVal && v.value.integer == -7, "27.14: an integer -> vpiIntVal");
  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.rp"), &v);
  CHECK(v.format == vpiRealVal && v.value.real == 2.5, "27.14: a real -> vpiRealVal");
  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.one"), &v);
  CHECK(v.format == vpiScalarVal || v.format == vpiStrengthVal, "27.14: a scalar -> vpiScalarVal or vpiStrengthVal");
  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.known"), &v);
  CHECK(v.format == vpiVectorVal && v.value.vector[0].aval == 0xa71, "27.14: a vector -> vpiVectorVal");
  v.format = vpiObjTypeVal;
  vpi_get_value(p02_by_name("b_27_values.tv"), &v);
  CHECK(v.format == vpiTimeVal && v.value.time->type == vpiSimTime &&
        v.value.time->high == 1 && v.value.time->low == 705032704,
        "27.14: a time variable as vpiObjTypeVal is not vpiTimeVal 5000000000");

  v.format = vpiStrengthVal;
  v.value.strength = &st;
  memset(&st, 0, sizeof st);
  vpi_get_value(p02_by_name("b_27_values.one"), &v);
  CHECK(vpi_chk_error(NULL) == 0 && st.logic == vpi1 && st.s1 == vpiStrongDrive,
        "27.14: vpiStrengthVal of a reg is logic 1 at strong strength");

  v.format = 9999;
  vpi_get_value(p02_by_name("b_27_values.known"), &v);
  expect_refusal("vpi_get_value(format 9999)");
}

static vpiHandle e1, e2;
static int stage = 0;

static PLI_INT32 at(p_cb_data d)
{
  s_vpi_time t;
  PLI_UINT32 now;
  (void)d;
  t.type = vpiSimTime;
  vpi_get_time(NULL, &t);
  now = t.low;
  switch (now) {
  case 1500:
    CHECK(int_of(q) == 0x22, "27.32: inertial 8'h22 landed at 1 us");
    CHECK(t.high == 0, "27.12: 1500 ticks");
    t.type = vpiScaledRealTime;
    vpi_get_time(top, &t);
    CHECK(t.real == 1.5, "27.12: 1.5 in the module's 1 us unit, got %f", t.real);
    vpi_get_time(NULL, &t);
    CHECK(t.real == 1500.0, "27.12: 1500 in the 1 ns simulation unit, got %f", t.real);
    vpi_get_time(NULL, NULL);
    expect_refusal("vpi_get_time(NULL, NULL)");
    break;
  case 2500: CHECK(int_of(q) == 0x22, "27.32: inertial removed the 8'h11 at 2 us"); break;
  case 3500: CHECK(int_of(p) == 0x33, "27.32: pure transport 8'h33 at 3 us"); break;
  case 4500: CHECK(int_of(p) == 0x44, "27.32: and 8'h44 at 4 us, neither removed"); break;
  case 5500: CHECK(int_of(p) == 0x66, "27.32: transport 8'h66 at 5 us"); break;
  case 6500: CHECK(int_of(p) == 0x66, "27.32: the later 8'h55 at 6 us was removed"); break;
  case 7500:
    CHECK(int_of(c) == 0, "27.32: the cancelled 8'h77 never lands");
    CHECK(int_of(wn) == 0xAA, "27.32: the net holds the put value until its driver changes");
    break;
  case 8500:
    CHECK(int_of(wn) == 0x02, "27.32: the driver changed at 8 us, the net resolves again");
    break;
  default:
    CHECK(0, "unexpected callback at %u", (unsigned)now);
  }
  stage++;
  return 0;
}

static PLI_INT32 rw0(p_cb_data d)
{
  static const PLI_UINT32 when[] = { 1500, 2500, 3500, 4500, 5500, 6500, 7500, 8500 };
  static s_vpi_time times[8];
  static s_cb_data cbs[8];
  s_vpi_value v;
  s_vpi_strengthval st;
  vpiHandle ev, r;
  int k;
  (void)d;

  top = p02_by_name("b_27_values");
  q = p02_by_name("b_27_values.q");
  p = p02_by_name("b_27_values.p");
  c = p02_by_name("b_27_values.c");
  wn = p02_by_name("b_27_values.wn");
  rq = p02_by_name("b_27_values.rq");
  ev = p02_by_name("b_27_values.ev");

  get_values();

  put(q, 0x0A, 0.0, vpiNoDelay, &r);
  CHECK(r == NULL, "27.32: no delay, no event handle");
  CHECK(int_of(q) == 0x0A, "27.32: vpiNoDelay sets at once");
  put(q, 0x11, 2.0, vpiInertialDelay | vpiReturnEvent, &e1);
  CHECK(e1 != NULL && vpi_get(vpiType, e1) == vpiSchedEvent, "27.32: vpiReturnEvent gives a vpiSchedEvent");
  CHECK(vpi_get(vpiScheduled, e1) == 1, "27.32: and it is scheduled");
  put(q, 0x22, 1.0, vpiInertialDelay, &r);
  CHECK(r == NULL, "27.32: without vpiReturnEvent, NULL");
  put(p, 0x33, 3.0, vpiPureTransportDelay, NULL);
  put(p, 0x44, 4.0, vpiPureTransportDelay, NULL);
  put(p, 0x55, 6.0, vpiTransportDelay, NULL);
  put(p, 0x66, 5.0, vpiTransportDelay, NULL);
  put(c, 0x77, 7.0, vpiInertialDelay | vpiReturnEvent, &e2);
  CHECK(e2 != NULL, "27.32: e2 is scheduled");
  CHECK(vpi_put_value(e2, NULL, NULL, vpiCancelEvent) == NULL, "27.32: cancel");
  expect_no_error("vpi_put_value(e2, vpiCancelEvent)");

  vpi_put_value(ev, NULL, NULL, vpiNoDelay);
  CHECK(vpi_chk_error(NULL) == 0, "27.32: a put onto a named event, value_p NULL");
  v.format = vpiIntVal;
  v.value.integer = 0xAA;
  vpi_put_value(wn, &v, NULL, vpiNoDelay);
  CHECK(vpi_chk_error(NULL) == 0 && int_of(wn) == 0xAA, "27.32: a vpiNoDelay put overrides the net");

  /* The refusals. */
  v.format = vpiStringVal;
  v.value.str = (PLI_BYTE8 *)"3.5";
  vpi_put_value(rq, &v, NULL, vpiNoDelay);
  k = vpi_chk_error(NULL);
  v.format = vpiRealVal;
  vpi_get_value(rq, &v);
  CHECK(k != 0 && v.value.real == 1.25, "27.32: vpiStringVal onto a real variable is refused");
  v.format = vpiStrengthVal;
  st.logic = vpi1;
  st.s0 = st.s1 = vpiStrongDrive;
  v.value.strength = &st;
  vpi_put_value(q, &v, NULL, vpiNoDelay);
  CHECK(vpi_chk_error(NULL) != 0 && int_of(q) == 0x0A, "27.32: vpiStrengthVal onto a vector is refused");
  v.format = vpiIntVal;
  v.value.integer = 9;
  vpi_put_value(p02_by_name("b_27_values.P"), &v, NULL, vpiNoDelay);
  expect_refusal("vpi_put_value(parameter)");
  CHECK(int_of(p02_by_name("b_27_values.P")) == 3, "27.32: P keeps 3");
  CHECK(vpi_put_value(q, NULL, NULL, vpiCancelEvent) == NULL, "27.32: q is no vpiSchedEvent");
  expect_refusal("vpi_put_value(reg, vpiCancelEvent)");

  for (k = 0; k < 8; k++) {
    times[k].type = vpiSimTime;
    times[k].low = when[k];
    cbs[k].reason = cbAtStartOfSimTime;
    cbs[k].cb_rtn = at;
    cbs[k].time = &times[k];
    CHECK(vpi_register_cb(&cbs[k]) != NULL, "reader at %u", (unsigned)when[k]);
  }
  return 0;
}

static PLI_INT32 end(p_cb_data d)
{
  (void)d;
  CHECK(stage == 8, "all eight readings ran, got %d", stage);
  CHECK(int_of(p02_by_name("b_27_values.hits")) == 1, "27.32: the named event put toggled it once");
  p02_done("b_27_values");
  return 0;
}

static PLI_INT32 start(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  (void)d;
  t.type = vpiSimTime;
  cb.reason = cbReadWriteSynch;
  cb.cb_rtn = rw0;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadWriteSynch at t=0");
  return 0;
}

static void startup(void)
{
  static s_cb_data s, e;
  s.reason = cbStartOfSimulation;
  s.cb_rtn = start;
  CHECK(vpi_register_cb(&s) != NULL, "cbStartOfSimulation");
  e.reason = cbEndOfSimulation;
  e.cb_rtn = end;
  CHECK(vpi_register_cb(&e) != NULL, "cbEndOfSimulation");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
