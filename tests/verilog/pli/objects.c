/* b 27 objects — the object routines of Clause 27 and their failure values,
 * over ch11_vpi/objects.v, read from a cbReadOnlySynch at t=0.
 *
 * IEEE 1364-2005:
 *
 * §27, p. 418: "All arguments shall be considered mandatory unless
 * specifically noted in the definition of the PLI routine."
 *
 * §26.2.3, p. 376: "The vpi_chk_error() routine shall return a nonzero value
 * if an error occurred in the previously called VPI routine."
 *
 * §27.1, p. 418-419: "The VPI routine vpi_chk_error() shall return an integer
 * constant representing an error severity level if the previous call to a VPI
 * routine resulted in an error. ... If the previous call to a VPI routine did
 * not result in an error, then vpi_chk_error() shall return 0 (false). The
 * error status shall be reset by any VPI routine call except vpi_chk_error().
 * Calling vpi_chk_error() shall have no effect on the error status." "If the
 * error information is not needed, a NULL can be passed to the routine."
 *
 * §27.2, p. 420: "The VPI routine vpi_compare_objects() shall return 1 (true)
 * if the two handles refer to the same object. Otherwise, 0 (false) shall be
 * returned. Handle equivalence cannot be determined with a C '==' comparison."
 *
 * §27.5, p. 421: "The iterator object shall automatically be freed when
 * vpi_scan() returns NULL ... The routine shall return 1 (true) on success
 * and 0 (false) on failure."
 *
 * §27.6, p. 422: "Boolean properties shall have a value of 1 for TRUE and 0
 * for FALSE. For integer object properties such as vpiSize, any integer shall
 * be returned. ... Should an error occur, vpi_get() shall return
 * vpiUndefined."
 *
 * §27.10, p. 426: "The VPI routine vpi_get_str() shall return string property
 * values. The string shall be placed in a temporary buffer that shall be used
 * by every call to this routine. ... A different string buffer shall be used
 * for string values returned through the s_vpi_value structure."
 *
 * §27.15, p. 435-436: "The routine shall return 1 (true) on success and 0
 * (false) on failure." "There shall be argc entries in the argv array. The
 * value in entry zero shall be the tool's name."
 *
 * §27.16, p. 436: "The VPI routine vpi_handle() shall return the object of
 * type type associated with object ref. ... The one-to-one relationships that
 * are traversed with this routine are indicated as single arrows in the data
 * model diagrams."
 *
 * §27.17, p. 437: "The reference object shall be an object that has the access
 * by index property. ... If the selection represented by the index number does
 * not lead to the construction of a legal Verilog index select expression, the
 * routine shall return a null handle."
 *
 * §27.19, p. 438-439: "The VPI routine vpi_handle_by_name() shall return a
 * handle to an object with a specific name. ... The name can be hierarchical
 * or simple. If scope is NULL, then name shall be searched for from the top
 * level of hierarchy. If a scope object is provided, then search within that
 * scope only."
 *
 * §27.20, p. 439: "The VPI routine vpi_handle_multi() can be used to return a
 * handle to an object of type vpiInterModPath associated with a list of output
 * port and input port reference objects."
 *
 * §27.21, p. 439-440: "The vpi_iterate() routine shall return a handle to an
 * iterator, whose type shall be vpiIterator ... If there are no objects of
 * type type associated with the reference handle ref, then the vpi_iterate()
 * routine shall return NULL."
 *
 * §27.36, p. 465: "Once vpi_scan() returns NULL, the iterator handle is no
 * longer valid and cannot be used again."
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * objects.v at the end of t=0: W = 8; bus is `wire [7:0]` = {4'b0000, r}
 * = 8'h09; lsb, lsb2 scalar wires; r = 4'd9; mem[0:3] of 8 bits = 00 11 22 33;
 * u and v are p04_leaf instances with ports a [7:0] and y.
 *
 *   §27.1   vpi_get(9999, top): 9999 is no property -> vpiUndefined and an
 *           error; vpi_chk_error() answers a level in vpiNotice..vpiInternal,
 *           the same level twice (it does not reset), the structure's level
 *           is the one returned, and after the good call vpi_get(vpiType, top)
 *           it answers 0. §27's "unless specifically noted": vpi_chk_error's
 *           structure may be NULL, and is accepted; vpi_get_value's value_p is
 *           not noted, so vpi_get_value(r, NULL) is an error.
 *   §27.2   r by name and r found by scanning vpiReg of top are one object: 1;
 *           r against i: 0; r against NULL, no object: 0.
 *   §27.5   an iterator over top's three nets, abandoned after one scan, frees:
 *           1. NULL, no object: 0. (A spent iterator is not used again:
 *           §27.36 makes it invalid, so any use of it is outside the API.)
 *   §27.6   vpiVector(bus) 1, vpiScalar(bus) 0, vpiScalar(lsb) 1, vpiSize bus
 *           8, r 4; property 9999 and a NULL object -> vpiUndefined.
 *   §27.10  vpiName r "r", vpiFullName "p04_objects.r", vpiDefName u
 *           "p04_leaf". The pointer from vpi_get_str(vpiName, r) still reads
 *           "r" after vpi_get_value(bus, vpiBinStrVal) returned "00001001":
 *           two buffers. vpiSize is no string property -> NULL and an error.
 *   §27.15  TRUE; argc >= 1, argv[0] the tool's name, argv[0..argc-1] all
 *           strings; product and version present. NULL -> 0.
 *   §27.16  vpi_handle(vpiModule, bus) is top. module ->> port is a double
 *           arrow, so vpi_handle(vpiPort, top) -> NULL and an error.
 *   §27.17  mem has access by index: index 2 is the word reading 8'h22, of
 *           vpiSize 8. Index 4 is past [0:3]: no word mem[4] exists, and
 *           that is read as "does not lead to the construction of a legal
 *           Verilog index select expression" -> NULL. (mem[4] is legal
 *           SYNTAX, reading x in the HDL; the reading taken is that no
 *           object is selected.) A module has no access by index -> NULL.
 *   §27.19  "p04_objects.u.a" from the top; "a" in scope u is the same object,
 *           and so is "u.a" in scope top; "bus" in scope u -> NULL and an
 *           error ("search within that scope only": bus is top's, not u's);
 *           "nosuch" -> NULL. Verilog-AMS §12.21 searches upward instead; this
 *           design runs as IEEE 1364, whose rule this is.
 *   §27.20  9999 is not vpiInterModPath -> NULL and an error.
 *   §27.21  top ->> net: an iterator of vpiType vpiIterator, three nets. u
 *           declares no reg: NULL with no error. 9999 is no object type:
 *           NULL and an error.
 *   §27.36  scanning ends in NULL; a module is no iterator: NULL.
 */

//! lrm 12.21
//! lrm 12.21:3
//! inherited IEEE 1364-2005 27
//! inherited-reject IEEE 1364-2005 27
//! inherited IEEE 1364-2005 26.2.3
//! inherited IEEE 1364-2005 27.1
//! inherited IEEE 1364-2005 27.2
//! inherited-reject IEEE 1364-2005 27.2
//! inherited IEEE 1364-2005 27.5
//! inherited-reject IEEE 1364-2005 27.5
//! inherited IEEE 1364-2005 27.6
//! inherited-reject IEEE 1364-2005 27.6
//! inherited IEEE 1364-2005 27.10
//! inherited-reject IEEE 1364-2005 27.10
//! inherited IEEE 1364-2005 27.15
//! inherited-reject IEEE 1364-2005 27.15
//! inherited IEEE 1364-2005 27.16
//! inherited-reject IEEE 1364-2005 27.16
//! inherited IEEE 1364-2005 27.17
//! inherited-reject IEEE 1364-2005 27.17
//! inherited IEEE 1364-2005 27.19
//! inherited-reject IEEE 1364-2005 27.19
//! inherited-reject IEEE 1364-2005 27.20
//! inherited IEEE 1364-2005 27.21
//! inherited-reject IEEE 1364-2005 27.21
//! inherited IEEE 1364-2005 27.36
//! inherited-reject IEEE 1364-2005 27.36
//! design ../../verilog-ams/ch11_vpi/objects.v
//! stdout p02: b_27_objects checks=83

#include "b_check.h"

static PLI_INT32 walk(p_cb_data cb_data)
{
  vpiHandle top = p02_by_name("p04_objects");
  vpiHandle u   = p02_by_name("p04_objects.u");
  vpiHandle bus = p02_by_name("p04_objects.bus");
  vpiHandle lsb = p02_by_name("p04_objects.lsb");
  vpiHandle r   = p02_by_name("p04_objects.r");
  vpiHandle i   = p02_by_name("p04_objects.i");
  vpiHandle mem = p02_by_name("p04_objects.mem");
  vpiHandle ua  = p02_by_name("p04_objects.u.a");
  vpiHandle itr, h, found = NULL, word;
  s_vpi_error_info a, b;
  s_vpi_vlog_info info;
  s_vpi_value v;
  PLI_BYTE8 *name;
  int n, k, lvl;

  (void)cb_data;

  /* §27.1 / §26.2.3 */
  CHECK(vpi_get(9999, top) == vpiUndefined, "27.6: 9999 is no property");
  lvl = vpi_chk_error(&a);
  CHECK(lvl != 0, "26.2.3: nonzero after an error");
  CHECK(lvl >= vpiNotice && lvl <= vpiInternal, "27.1: a Table 27-1 severity, got %d", lvl);
  CHECK(vpi_chk_error(&b) == lvl, "27.1: vpi_chk_error() has no effect on the status");
  CHECK(a.level == lvl && b.level == lvl, "27.1: the structure carries the level returned");
  CHECK(a.message != NULL, "27.1: the structure is filled");
  CHECK(vpi_chk_error(NULL) == lvl, "27.1/27: NULL may be passed");
  CHECK(vpi_get(vpiType, top) == vpiModule, "a good call");
  CHECK(vpi_chk_error(NULL) == 0, "27.1: ...resets the status to 0");

  /* §27: value_p is not noted optional. */
  vpi_get_value(r, NULL);
  expect_refusal("vpi_get_value(r, NULL)");

  /* §27.2 */
  itr = vpi_iterate(vpiReg, top);
  while ((h = vpi_scan(itr)) != NULL)
    if (strcmp(vpi_get_str(vpiName, h), "r") == 0) found = h;
  CHECK(found != NULL, "top ->> reg reaches r");
  CHECK(vpi_compare_objects(r, found) == 1, "27.2: two handles, one object");
  CHECK(vpi_compare_objects(r, i) == 0, "27.2: r and i differ");
  CHECK(vpi_compare_objects(r, NULL) == 0, "27.2: NULL refers to no object");

  /* §27.21 / §27.5 / §27.36 */
  itr = vpi_iterate(vpiNet, top);
  expect_no_error("vpi_iterate(vpiNet, top)");
  CHECK(itr != NULL && vpi_get(vpiType, itr) == vpiIterator, "27.21: an iterator of type vpiIterator");
  CHECK(vpi_scan(itr) != NULL, "a first net");
  CHECK(vpi_free_object(itr) == 1, "27.5: an abandoned iterator frees");
  expect_no_error("vpi_free_object(abandoned)");
  itr = vpi_iterate(vpiNet, top);
  for (n = 0; (h = vpi_scan(itr)) != NULL; n++)
    CHECK(vpi_get(vpiType, h) == vpiNet, "27.21: every object is of the type asked");
  CHECK(n == 3, "27.21: bus, lsb, lsb2, got %d", n);
  CHECK(vpi_free_object(NULL) == 0, "27.5: NULL is no object");
  CHECK(vpi_scan(top) == NULL, "27.36: a module is no iterator");
  expect_refusal("vpi_scan(module)");
  CHECK(vpi_iterate(vpiReg, u) == NULL, "27.21: u declares no reg");
  expect_no_error("vpi_iterate(vpiReg, u)");
  CHECK(vpi_iterate(9999, top) == NULL, "27.21: 9999 is no object type");
  expect_refusal("vpi_iterate(9999, top)");

  /* §27.6 */
  CHECK(vpi_get(vpiVector, bus) == 1 && vpi_get(vpiScalar, bus) == 0, "27.6: booleans are 1 and 0");
  CHECK(vpi_get(vpiScalar, lsb) == 1, "27.6: lsb is scalar");
  CHECK(vpi_get(vpiSize, bus) == 8 && vpi_get(vpiSize, r) == 4, "27.6: sizes 8 and 4");
  CHECK(vpi_get(vpiSize, NULL) == vpiUndefined, "27.6: no object");
  expect_refusal("vpi_get(vpiSize, NULL)");

  /* §27.10 */
  CHECK(strcmp(vpi_get_str(vpiFullName, r), "p04_objects.r") == 0, "27.10: full name");
  CHECK(strcmp(vpi_get_str(vpiDefName, u), "p04_leaf") == 0, "27.10: definition name");
  name = vpi_get_str(vpiName, r);
  CHECK(name != NULL && strcmp(name, "r") == 0, "27.10: name");
  v.format = vpiBinStrVal;
  vpi_get_value(bus, &v);
  CHECK(strcmp(v.value.str, "00001001") == 0, "bus reads 8'h09, got %s", v.value.str);
  CHECK(strcmp(name, "r") == 0, "27.10: vpi_get_value did not use vpi_get_str's buffer");
  CHECK(vpi_get_str(vpiSize, r) == NULL, "27.10: vpiSize is not a string property");
  expect_refusal("vpi_get_str(vpiSize)");

  /* §27.16 */
  CHECK(vpi_compare_objects(vpi_handle(vpiModule, bus), top) == 1, "27.16: bus -> module is top");
  CHECK(vpi_handle(vpiPort, top) == NULL, "27.16: module ->> port is no single arrow");
  expect_refusal("vpi_handle(vpiPort, module)");

  /* §27.17 */
  word = vpi_handle_by_index(mem, 2);
  expect_no_error("vpi_handle_by_index(mem, 2)");
  CHECK(word != NULL && vpi_get(vpiSize, word) == 8, "27.17: mem[2] is an 8-bit word");
  v.format = vpiIntVal;
  vpi_get_value(word, &v);
  CHECK(v.value.integer == 0x22, "27.17: mem[2] reads 8'h22, got %d", (int)v.value.integer);
  CHECK(vpi_handle_by_index(mem, 4) == NULL, "27.17: mem[4] is no legal select");
  CHECK(vpi_handle_by_index(top, 0) == NULL, "27.17: a module has no access by index");
  expect_refusal("vpi_handle_by_index(module, 0)");

  /* §27.19 */
  h = vpi_handle_by_name((PLI_BYTE8 *)"a", u);
  CHECK(h != NULL && vpi_compare_objects(h, ua) == 1, "27.19: a simple name in scope u");
  CHECK(vpi_handle_by_name((PLI_BYTE8 *)"bus", u) == NULL, "27.19: bus is top's, and scope u is searched alone");
  expect_refusal("vpi_handle_by_name(\"bus\", u)");
  h = vpi_handle_by_name((PLI_BYTE8 *)"u.a", top);
  CHECK(h != NULL && vpi_compare_objects(h, ua) == 1, "27.19: a hierarchical name within scope top");
  CHECK(vpi_handle_by_name((PLI_BYTE8 *)"p04_objects.nosuch", NULL) == NULL, "27.19: no such name");

  /* §27.20 */
  CHECK(vpi_handle_multi(9999, ua, lsb) == NULL, "27.20: 9999 is no many-to-one type");
  expect_refusal("vpi_handle_multi(9999)");

  /* §27.15 */
  memset(&info, 0, sizeof info);
  CHECK(vpi_get_vlog_info(&info) == 1, "27.15: TRUE on success");
  CHECK(info.argc >= 1 && info.argv != NULL && info.argv[0] != NULL && info.argv[0][0] != '\0',
        "27.15: entry zero is the tool's name");
  for (k = 0; k < info.argc; k++) CHECK(info.argv[k] != NULL, "27.15: argc entries");
  CHECK(info.product != NULL && info.version != NULL, "27.15: product and version");
  CHECK(vpi_get_vlog_info(NULL) == 0, "27.15: FALSE with no structure");
  expect_refusal("vpi_get_vlog_info(NULL)");

  p02_done("b_27_objects");
  return 0;
}

static PLI_INT32 start(p_cb_data d)
{
  static s_vpi_time t;
  static s_cb_data cb;
  (void)d;
  t.type = vpiSimTime;
  cb.reason = cbReadOnlySynch;
  cb.cb_rtn = walk;
  cb.time = &t;
  CHECK(vpi_register_cb(&cb) != NULL, "cbReadOnlySynch at t=0");
  return 0;
}

static void startup(void)
{
  static s_cb_data cb;
  cb.reason = cbStartOfSimulation;
  cb.cb_rtn = start;
  CHECK(vpi_register_cb(&cb) != NULL, "cbStartOfSimulation");
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
