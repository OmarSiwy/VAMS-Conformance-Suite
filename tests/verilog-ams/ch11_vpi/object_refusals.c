/* p04 02 — what the object routines REFUSE, over objects.v.
 *
 * The positive walk of these same objects is p04_01. This application asks
 * each routine a question the LRM gives no answer to and checks that the
 * routine returns its documented failure value AND reports the failure
 * through vpi_chk_error():
 *
 *   11.2.3  "The vpi_chk_error() routine shall return a nonzero value if an
 *            error occurred in the previously called VPI routine."
 *   12.2    "If the previous call to a VPI routine did not result in an error,
 *            then vpi_chk_error() shall return FALSE. The error status shall be
 *            reset by any VPI routine call except vpi_chk_error(). Calling
 *            vpi_chk_error() shall have no effect on the error status."
 *   12.3    "shall return TRUE if the two handles refer to the same object.
 *            Otherwise, FALSE shall be returned."
 *   12.4    "The routine shall return TRUE on success and FALSE on failure."
 *   12.5    "Should an error occur, vpi_get() shall return vpiUndefined."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * Each refusal is an object asked for a property or relationship its 11.6
 * diagram does not draw, or a routine handed an argument outside its domain:
 *
 *   11.6.1   `module` lists no vpiSize                 -> vpiUndefined
 *   11.6.4   `port` lists no vpiDefName (a module's)   -> NULL
 *   11.6.8   `net` lists no vpiDirection (a port's)    -> vpiUndefined
 *   11.6.9   `reg` lists no vpiDirection               -> vpiUndefined
 *   11.6.10  `integer var` lists no vpiDirection       -> vpiUndefined
 *   11.6.11  mem is declared [0:3]: no word 4, no word -1
 *            (12.20 "a handle to an object based on the index number of the
 *            object within a parent object" — there is no such object) -> NULL
 *   11.6.12 / 12.30  12.30: "The routine can be applied to nets, regs,
 *            variables, memory words, system function calls, sequential
 *            UDPs, and schedule events." A parameter is none of them, and
 *            NOTE 1 of 11.6.12 fixes its value as the elaborated one, so the
 *            put is refused and W still reads 8 afterwards.
 *   11.3.1 / 12.21  no object is named `p04_objects.nosuch`, and a NULL name
 *            names nothing                            -> NULL
 *   11.2.2   "VPI routines provide access to objects in an instantiated
 *            Verilog-AMS design. An instantiated design is one where each
 *            instance of an object is uniquely accessible. For instance, if a
 *            module m contains wire w and is instantiated twice as m1 and m2,
 *            then m1.w and m2.w are two distinct objects". p04_leaf is m:
 *            `p04_leaf.a` names the DEFINITION's port, which is u.a and v.a at
 *            once and so no one object, and `p04_leaf` itself is no instance
 *            (it is instantiated, so it is not a root either) -> NULL, while
 *            `p04_objects.u.a`, the instance path, is the object
 *   12.12    vpiSize is an int property, not a string -> NULL
 *   12.19    module ->> port is a DOUBLE arrow (11.6.1): vpi_handle() traverses
 *            "one-to-one relationships ... indicated as single arrows", so
 *            vpi_handle(vpiPort, module) has no answer -> NULL
 *   12.23    a net is the reference object of no parameter relationship
 *            -> NULL, and unlike an empty set this one is an error. The empty
 *            set is checked too: u declares no reg, so vpi_iterate(vpiReg, u)
 *            is NULL with vpi_chk_error() FALSE — the two NULLs differ only in
 *            the error status, which is the point of 11.2.3.
 *   12.35    "Once vpi_scan() returns NULL, the iterator handle is no longer
 *            valid and can not be used again": a scan of the spent iterator,
 *            and of a module handle that never was an iterator  -> NULL
 *   12.4     freeing NULL, and freeing that spent iterator     -> FALSE
 *   12.3     comparing a valid handle with NULL                -> FALSE
 *   12.5     property 9999 is no property at all               -> vpiUndefined
 *
 * Three of these refusals are also the diagram KEYS read backwards:
 *   11.3    Figure 11-1 gives a net vpiName, vpiVector and vpiSize and
 *           nothing else — vpiDirection is not among them.
 *   11.5.2  "Integer and Boolean properties are accessed with the routine
 *           vpi_get()", "String properties are accessed with routine
 *           vpi_get_str()": vpiSize is an int, so vpi_get_str(vpiSize) has
 *           no string to give.
 *   11.5.3  "A single arrow indicates a one-to-one relationship accessed
 *           with the routine vpi_handle()"; module -> port is a double arrow,
 *           so vpi_handle(vpiPort, module) has no one object to give.
 *
 * 12.1's conventions: "All arguments shall be considered mandatory unless
 * specifically noted ... Optional: Arguments tagged as optional can have
 * default values" — vpi_chk_error()'s structure is the one argument here
 * 12.2 notes as optional ("If the error information is not needed, a NULL
 * can be passed"), and vpi_chk_error(NULL) answers the level all the same.
 *
 * The application runs from cbReadWriteSynch at t=0 and NOT cbReadOnlySynch:
 * 12.31.2 forbids writing in the read-only region, so a put refused there
 * would be refused for that reason and would say nothing about parameters.
 */

//! lrm-reject 11.2.2
//! lrm-reject 11.2.3
//! lrm-reject 11.3
//! lrm-reject 11.3.1
//! lrm-reject 11.5.2
//! lrm-reject 11.5.3
//! lrm-reject 11.6.1
//! lrm-reject 11.6.4
//! lrm-reject 11.6.8
//! lrm-reject 11.6.9
//! lrm-reject 11.6.10
//! lrm-reject 11.6.11
//! lrm-reject 11.6.12
//! lrm 12.1
//! lrm 12.2
//! lrm-reject 12.2
//! lrm-reject 12.3
//! lrm-reject 12.4
//! lrm-reject 12.5
//! lrm-reject 12.12
//! lrm-reject 12.19
//! lrm-reject 12.20
//! lrm-reject 12.21
//! lrm-reject 12.23
//! lrm-reject 12.30
//! lrm-reject 12.35
//! lrm 12.2:1
//! lrm 12.2:3
//! lrm 12.2:4
//! lrm 12.2:5
//! lrm-reject 12.4:4
//! lrm-reject 12.5:6
//! design objects.v
//! stdout p02: p04_02_object_refusals checks=118

#include "p02_check.h"

static PLI_INT32 refuse(p_cb_data cb_data)
{
  vpiHandle top = p02_by_name("p04_objects");
  vpiHandle u   = p02_by_name("p04_objects.u");
  vpiHandle bus = p02_by_name("p04_objects.bus");
  vpiHandle r   = p02_by_name("p04_objects.r");
  vpiHandle i   = p02_by_name("p04_objects.i");
  vpiHandle mem = p02_by_name("p04_objects.mem");
  vpiHandle w   = p02_by_name("p04_objects.W");
  vpiHandle port, itr;
  s_vpi_value v;
  s_vpi_error_info a, b;

  (void)cb_data;

  /* 11.2.3 / 12.2: one refusal, read twice, then reset by a good call. */
  CHECK(vpi_get(vpiSize, top) == vpiUndefined, "11.6.1: a module has no vpiSize");
  CHECK(vpi_chk_error(&a) == vpiError, "11.2.3: the refusal is an error");
  CHECK(vpi_chk_error(&b) == vpiError, "12.2: vpi_chk_error() does not reset the status");
  CHECK(a.level == vpiError && b.level == vpiError, "12.2: level is the severity returned");
  CHECK(a.state == b.state && a.state == vpiPLI, "12.2: a routine's own error is vpiPLI");
  CHECK(a.message != NULL && a.message[0] != '\0', "12.2: the message says what failed");
  CHECK(vpi_chk_error(NULL) == vpiError, "12.2: NULL may be passed when the details are not needed");
  CHECK(vpi_get(vpiType, top) == vpiModule, "a good call");
  CHECK(vpi_chk_error(NULL) == 0, "12.2: ...resets the status to FALSE");

  /* Properties the diagrams do not list. */
  itr = vpi_iterate(vpiPort, u);
  port = vpi_scan(itr);
  CHECK(port != NULL, "u has a first port");
  vpi_free_object(itr);
  CHECK(vpi_get_str(vpiDefName, port) == NULL, "11.6.4: a port has no vpiDefName");
  expect_error("vpi_get_str(vpiDefName, port)");
  CHECK(vpi_get(vpiDirection, bus) == vpiUndefined, "11.6.8: a net has no vpiDirection");
  expect_error("vpi_get(vpiDirection, net)");
  CHECK(vpi_get(vpiDirection, r) == vpiUndefined, "11.6.9: a reg has no vpiDirection");
  expect_error("vpi_get(vpiDirection, reg)");
  CHECK(vpi_get(vpiDirection, i) == vpiUndefined, "11.6.10: an integer var has no vpiDirection");
  expect_error("vpi_get(vpiDirection, integer)");
  CHECK(vpi_get(9999, top) == vpiUndefined, "12.5: 9999 is no property");
  expect_error("vpi_get(9999)");
  CHECK(vpi_get_str(vpiSize, top) == NULL, "12.12: vpiSize is not a string property");
  expect_error("vpi_get_str(vpiSize)");

  /* 11.6.11 / 12.20: the words are 0..3. */
  CHECK(vpi_handle_by_index(mem, 2) != NULL, "word 2 exists");
  expect_no_error("vpi_handle_by_index(mem, 2)");
  CHECK(vpi_handle_by_index(mem, 4) == NULL, "11.6.11: mem has no word 4");
  expect_error("vpi_handle_by_index(mem, 4)");
  CHECK(vpi_handle_by_index(mem, -1) == NULL, "11.6.11: mem has no word -1");
  expect_error("vpi_handle_by_index(mem, -1)");

  /* 11.6.12 / 12.30: a parameter is not written. */
  v.format = vpiIntVal;
  v.value.integer = 99;
  CHECK(vpi_put_value(w, &v, NULL, vpiNoDelay) == NULL, "12.30: no event from a refused put");
  expect_error("vpi_put_value(parameter)");
  v.format = vpiIntVal;
  vpi_get_value(w, &v);
  CHECK(v.value.integer == 8, "11.6.12 NOTE 1: W is still 8, got %d", (int)v.value.integer);

  /* 11.3.1 / 12.21. */
  CHECK(vpi_handle_by_name((PLI_BYTE8 *)"p04_objects.nosuch", NULL) == NULL,
        "12.21: no object is named p04_objects.nosuch");
  expect_error("vpi_handle_by_name(nosuch)");
  CHECK(vpi_handle_by_name((PLI_BYTE8 *)"nosuch", u) == NULL,
        "12.21: nor is one found from u's scope upward");
  expect_error("vpi_handle_by_name(nosuch, u)");
  CHECK(vpi_handle_by_name(NULL, NULL) == NULL, "12.21: a NULL name names nothing");
  expect_error("vpi_handle_by_name(NULL)");

  /* 11.2.2: only the instantiated design is accessible. */
  CHECK(vpi_handle_by_name((PLI_BYTE8 *)"p04_leaf.a", NULL) == NULL,
        "11.2.2: the definition p04_leaf is not an instance, so p04_leaf.a names no object");
  expect_error("vpi_handle_by_name(p04_leaf.a)");
  CHECK(vpi_handle_by_name((PLI_BYTE8 *)"p04_leaf", NULL) == NULL,
        "11.2.2: nor is the definition itself an instantiated object");
  expect_error("vpi_handle_by_name(p04_leaf)");
  CHECK(vpi_handle_by_name((PLI_BYTE8 *)"p04_objects.u.a", NULL) != NULL,
        "11.2.2: the instance path to the same port is the object");
  expect_no_error("vpi_handle_by_name(p04_objects.u.a)");

  /* 12.19: a double arrow is not traversed by vpi_handle(). */
  CHECK(vpi_handle(vpiPort, top) == NULL, "12.19: module -> port is one-to-many");
  expect_error("vpi_handle(vpiPort, module)");

  /* 12.23: an empty set versus no such relationship. */
  CHECK(vpi_iterate(vpiReg, u) == NULL, "12.23: u declares no reg");
  expect_no_error("vpi_iterate(vpiReg, u) — an empty set is not an error");
  CHECK(vpi_iterate(vpiParameter, bus) == NULL, "12.23: a net has no parameters");
  expect_error("vpi_iterate(vpiParameter, net)");

  /* 12.35 / 12.4: a spent iterator. */
  itr = vpi_iterate(vpiNet, top);
  while (vpi_scan(itr) != NULL) {}
  expect_no_error("the scan that ends the iterator");
  CHECK(vpi_scan(itr) == NULL, "12.35: the spent iterator yields nothing");
  expect_error("vpi_scan(spent iterator)");
  CHECK(vpi_free_object(itr) == 0, "12.4: the spent iterator was already freed");
  expect_error("vpi_free_object(spent iterator)");
  CHECK(vpi_scan(top) == NULL, "12.35: a module handle is not an iterator");
  expect_error("vpi_scan(module)");
  CHECK(vpi_free_object(NULL) == 0, "12.4: freeing NULL fails");
  expect_error("vpi_free_object(NULL)");

  /* 12.3. */
  CHECK(vpi_compare_objects(top, top) == 1, "a handle is its own object");
  CHECK(vpi_compare_objects(top, NULL) == 0, "12.3: NULL is not the module");
  expect_error("vpi_compare_objects(top, NULL)");

  p02_done("p04_02_object_refusals");
  return 0;
}

static void setup_after_compile(void)
{
  static s_vpi_time t = { vpiSimTime, 0, 0, 0.0 };
  static s_cb_data cb;
  cb.reason = cbReadWriteSynch;
  cb.cb_rtn = refuse;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadWriteSynch(0) registration failed");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void setup(void)
{
  p02_defer(setup_after_compile);
}

void (*vlog_startup_routines[])(void) = { setup, 0 };
