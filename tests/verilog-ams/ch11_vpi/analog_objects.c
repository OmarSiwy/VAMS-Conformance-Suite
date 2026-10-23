/* p04 06 — the analog object diagrams, 11.6.2 (nature, discipline), 11.6.5
 * (nodes), 11.6.6 (branches) and 11.6.7 (quantities), walked over
 * analog_object_relations.va.
 *
 * The §11.5.3 key: a single arrow is vpi_handle(), a double arrow
 * vpi_iterate(), a circled arrow is traversed "using NULL instead of ref_h".
 * The edges this application follows, diagram by diagram:
 *
 *   11.6.2   o->> discipline, o->> nature (circled);
 *            discipline -> nature tagged vpiFlowNature / vpiPotentialNature;
 *            nature -> nature tagged vpiParent; nature ->> nature tagged
 *            vpiChild; nature ->> discipline; both carry vpiName/vpiFullName.
 *   11.6.5   module <->> node; node -> discipline; node <->> nets;
 *            vpiScalar/vpiSize/vpiVector ("NOTE 1—Properties scalar and vector
 *            shall indicate if the node is 1 bit or more than 1 bit").
 *   11.6.6   module <->> branch; branch -> nodes tagged vpiPosNode/vpiNegNode;
 *            branch -> Discipline; branch -> Quantity tagged vpiFlow/
 *            vpiPotential; vpiName/vpiFullName, vpiScalar/vpiSize.
 *   11.6.7   Quantity -> Branches tagged vpiBranch; Quantity -> Nature;
 *            vpiScalar/vpiSize.
 *
 * ------------------------------------------------------------------ DERIVATION
 *
 * From analog_object_relations.va's declarations alone:
 *
 *   natures      p04_volt, p04_amp, p04_fine_volt — in that order. They are
 *                not the only ones: VerA compiles every file after Annex D's
 *                standard definitions (the disciplines.vams prelude, whose
 *                `Voltage` is checked for), and 11.6.2's circled arrow reaches
 *                every declared nature. So the file's three are found by name,
 *                each exactly once, and their relative order is asserted.
 *                p04_fine_volt is `: p04_volt` (§3.6.1.1), so its vpiParent is
 *                p04_volt and p04_volt's vpiChild set is {p04_fine_volt}. The
 *                two base natures have no parent: NULL, and not an error —
 *                the §11.5.3 "no such object" answer.
 *   disciplines  p04_elec (potential p04_volt, flow p04_amp) and p04_fine
 *                (potential p04_fine_volt, flow p04_amp). So the disciplines
 *                binding p04_amp are both, in order; binding p04_volt, only
 *                p04_elec — p04_fine binds the DERIVED nature, not its parent.
 *   nodes        p, n, mid (p04_elec) and f (p04_fine): four, each scalar.
 *                Each node's net set is its own net, which leads back to it.
 *   branches     b1 = (p, mid), b2 = (mid, n): vpiPosNode is the first
 *                terminal, vpiNegNode the second (§3.12's `branch (hi, lo)`).
 *                A branch between p04_elec nodes is of discipline p04_elec, so
 *                its flow quantity's nature is p04_amp and its potential
 *                quantity's p04_volt. A branch declared without a range is
 *                one bit: scalar, size 1 — and so are its quantities.
 *
 * REFUSALS, each an edge or property the diagram of that class does not draw:
 *   11.6.2   a nature has no vpiFlowNature (that is a discipline's edge), and
 *            a discipline has no vpiSize
 *   11.6.5   a node has no vpiPosNode (a branch's) and no vpiDirection
 *   11.6.6   a branch draws no nature arrow (its QUANTITIES do), and no
 *            branch ->> net relationship
 *   11.6.7   a quantity lists no name, and no module arrow leaves it
 * each returning NULL / vpiUndefined with vpi_chk_error() set (12.2).
 *
 * This is a compile of the design and not an analysis, so nothing here reads
 * a value; §11.6.7's "real value / imaginary value" are vpi_get_analog_value(),
 * which needs a solution this process does not compute. What 12.10 does fix
 * without one is what the routine accepts: "the simulation value of VPI
 * analog vpiFlow or vpiPotential (node or branch) quantity objects ...
 * placed in an s_vpi_analog_value structure, which has been allocated by
 * the user" — so a net, NULL, and a quantity with no structure are refused.
 */

//! lrm 11.6.2
//! lrm-reject 11.6.2
//! lrm 11.6.5
//! lrm-reject 11.6.5
//! lrm 11.6.6
//! lrm-reject 11.6.6
//! lrm 11.6.7
//! lrm-reject 11.6.7
//! lrm-reject 12.10
//! lrm 12.19
//! lrm 12.23
//! lrm 12.33.2
//! lrm C.13
//! lrm-reject C.13
//! lrm 11.6.2:1000
//! lrm 11.6.7:1000
//! lrm 12.23:3
//! design analog_object_relations.va
//! stdout p02: p04_06_analog_objects checks=139

#include "p02_check.h"

static int scan_all(vpiHandle itr, vpiHandle *out, int max)
{
  int n = 0;
  vpiHandle h;
  if (itr == NULL) return 0;
  while ((h = vpi_scan(itr)) != NULL) {
    if (n < max) out[n] = h;
    n++;
  }
  return n;
}

static int named(vpiHandle h, const char *name)
{
  return h != NULL && strcmp(vpi_get_str(vpiName, h), name) == 0;
}

/* The one handle in `hs` named `name`; a failed CHECK if there is not
 * exactly one. */
static vpiHandle find(vpiHandle *hs, int n, const char *name)
{
  vpiHandle hit = NULL;
  int k, count = 0;
  for (k = 0; k < n; k++) if (named(hs[k], name)) { hit = hs[k]; count++; }
  CHECK(count == 1, "exactly one `%s`, got %d", name, count);
  return hit;
}

static int index_of(vpiHandle *hs, int n, vpiHandle h)
{
  int k;
  for (k = 0; k < n; k++) if (vpi_compare_objects(hs[k], h)) return k;
  return -1;
}

static void natures_and_disciplines(void)
{
  vpiHandle nat[64], dis[64], got[8];
  vpiHandle volt, amp, fine_volt, elec, fine;
  int n;

  n = scan_all(vpi_iterate(vpiNature, NULL), nat, 64);
  CHECK(n <= 64, "at most 64 natures, got %d", n);
  volt = find(nat, n, "p04_volt");
  amp = find(nat, n, "p04_amp");
  fine_volt = find(nat, n, "p04_fine_volt");
  CHECK(index_of(nat, n, volt) < index_of(nat, n, amp) && index_of(nat, n, amp) < index_of(nat, n, fine_volt),
        "the file's natures, in declaration order");
  CHECK(vpi_get(vpiType, volt) == vpiNature, "a nature's type is vpiNature");
  CHECK(strcmp(vpi_get_str(vpiFullName, volt), "p04_volt") == 0, "a nature's full name is its name");
  CHECK(find(nat, n, "Voltage") != NULL, "Annex D's natures are declared in every compilation too");

  n = scan_all(vpi_iterate(vpiDiscipline, NULL), dis, 64);
  CHECK(n <= 64, "at most 64 disciplines, got %d", n);
  elec = find(dis, n, "p04_elec");
  fine = find(dis, n, "p04_fine");
  CHECK(index_of(dis, n, elec) < index_of(dis, n, fine), "the file's disciplines, in declaration order");
  CHECK(vpi_get(vpiType, elec) == vpiDiscipline, "a discipline's type is vpiDiscipline");
  CHECK(strcmp(vpi_get_str(vpiFullName, fine), "p04_fine") == 0, "a discipline's full name is its name");

  /* discipline -> nature */
  CHECK(vpi_compare_objects(vpi_handle(vpiPotentialNature, elec), volt), "p04_elec's potential is p04_volt");
  CHECK(vpi_compare_objects(vpi_handle(vpiFlowNature, elec), amp), "p04_elec's flow is p04_amp");
  CHECK(vpi_compare_objects(vpi_handle(vpiPotentialNature, fine), fine_volt), "p04_fine's potential is p04_fine_volt");
  CHECK(vpi_compare_objects(vpi_handle(vpiFlowNature, fine), amp), "p04_fine's flow is p04_amp");

  /* nature -> vpiParent, nature ->> vpiChild */
  CHECK(vpi_compare_objects(vpi_handle(vpiParent, fine_volt), volt), "p04_fine_volt : p04_volt");
  CHECK(vpi_handle(vpiParent, volt) == NULL, "a base nature has no parent");
  expect_no_error("vpi_handle(vpiParent, base nature) — no such object is not an error");
  n = scan_all(vpi_iterate(vpiChild, volt), got, 8);
  CHECK(n == 1 && vpi_compare_objects(got[0], fine_volt), "p04_volt's one child is p04_fine_volt");
  CHECK(vpi_iterate(vpiChild, amp) == NULL, "p04_amp has no derived nature");
  expect_no_error("vpi_iterate(vpiChild, amp) — an empty set is not an error");

  /* nature ->> discipline */
  n = scan_all(vpi_iterate(vpiDiscipline, amp), got, 8);
  CHECK(n == 2 && vpi_compare_objects(got[0], elec) && vpi_compare_objects(got[1], fine),
        "both disciplines bind p04_amp, got %d", n);
  n = scan_all(vpi_iterate(vpiDiscipline, volt), got, 8);
  CHECK(n == 1 && vpi_compare_objects(got[0], elec), "only p04_elec binds p04_volt itself, got %d", n);

  /* refusals */
  CHECK(vpi_handle(vpiFlowNature, volt) == NULL, "11.6.2: a nature has no vpiFlowNature");
  expect_error("vpi_handle(vpiFlowNature, nature)");
  CHECK(vpi_get(vpiSize, elec) == vpiUndefined, "11.6.2: a discipline has no vpiSize");
  expect_error("vpi_get(vpiSize, discipline)");
}

static vpiHandle node_of(const char *net_name)
{
  vpiHandle net = p02_by_name(net_name);
  vpiHandle node = vpi_handle(vpiNode, net);
  vpiHandle nets[2];
  CHECK(node != NULL, "%s has a node", net_name);
  CHECK(vpi_get(vpiType, node) == vpiNode, "its type is vpiNode");
  /* p and n are the module's PORTS: by name they denote the port (11.6.4's
   * port -> nodes arrow is the edge followed), and the model holds no
   * separate net object for them. mid and f are nets (11.6.8 net -> node),
   * and their node's nets lead back. */
  if (vpi_get(vpiType, net) == vpiNet)
    CHECK(scan_all(vpi_iterate(vpiNet, node), nets, 2) == 1 && vpi_compare_objects(nets[0], net),
          "node <->> net leads back to %s", net_name);
  else
    CHECK(vpi_get(vpiType, net) == vpiPort, "%s is a port", net_name);
  expect_no_error("node_of");
  return node;
}

static void nodes_and_branches(void)
{
  vpiHandle top = p02_by_name("p04_analog");
  vpiHandle got[8];
  vpiHandle p = node_of("p04_analog.p"), n = node_of("p04_analog.n");
  vpiHandle mid = node_of("p04_analog.mid"), f = node_of("p04_analog.f");
  vpiHandle b1, b2, qf, qp;
  int k, count;

  /* 11.6.5 */
  count = scan_all(vpi_iterate(vpiNode, top), got, 8);
  CHECK(count == 4, "the module has four nodes, got %d", count);
  for (k = 0; k < 4; k++) {
    CHECK(vpi_compare_objects(vpi_handle(vpiModule, got[k]), top), "node -> module is the module");
    CHECK(vpi_get(vpiScalar, got[k]) == 1 && vpi_get(vpiVector, got[k]) == 0 && vpi_get(vpiSize, got[k]) == 1,
          "NOTE 1: each node is one bit");
  }
  CHECK(strcmp(vpi_get_str(vpiName, mid), "mid") == 0, "the node of mid is named mid");
  CHECK(strcmp(vpi_get_str(vpiFullName, mid), "p04_analog.mid") == 0, "and its full name is the net's");
  CHECK(named(vpi_handle(vpiDiscipline, p), "p04_elec"), "p is p04_elec");
  CHECK(named(vpi_handle(vpiDiscipline, f), "p04_fine"), "f is p04_fine");
  CHECK(vpi_compare_objects(vpi_handle(vpiDiscipline, p02_by_name("p04_analog.mid")), vpi_handle(vpiDiscipline, mid)),
        "net -> discipline is its node's");

  /* 11.6.6 */
  /* Two branches are DECLARED, and a third exists: `Ip(f) <+ ...` names the
   * pair (f, ground), and 5.4.2 makes that "the unnamed branch" between them —
   * a branch like any other, which 11.6.6's module ->> branch edge reaches.
   * Declaration order first; the unnamed one has no name to report and its
   * negative terminal is the reference node, which no node object carries. */
  count = scan_all(vpi_iterate(vpiBranch, top), got, 8);
  CHECK(count == 3, "two declared branches and f's unnamed one, got %d", count);
  b1 = got[0]; b2 = got[1];
  CHECK(vpi_compare_objects(vpi_handle(vpiPosNode, got[2]), f), "5.4.2: the unnamed branch runs from f");
  CHECK(vpi_handle(vpiNegNode, got[2]) == NULL, "to the reference node");
  CHECK(strcmp(vpi_get_str(vpiName, got[2]), "") == 0, "and has no name");
  CHECK(vpi_get(vpiType, b1) == vpiBranch, "a branch's type is vpiBranch");
  CHECK(strcmp(vpi_get_str(vpiName, b1), "b1") == 0 && strcmp(vpi_get_str(vpiFullName, b1), "p04_analog.b1") == 0,
        "b1's names");
  CHECK(named(b2, "b2"), "b2 second");
  CHECK(vpi_compare_objects(vpi_handle(vpiModule, b1), top), "branch -> module");
  CHECK(vpi_compare_objects(vpi_handle(vpiPosNode, b1), p), "b1's positive node is p");
  CHECK(vpi_compare_objects(vpi_handle(vpiNegNode, b1), mid), "b1's negative node is mid");
  CHECK(vpi_compare_objects(vpi_handle(vpiPosNode, b2), mid), "b2's positive node is mid");
  CHECK(vpi_compare_objects(vpi_handle(vpiNegNode, b2), n), "b2's negative node is n");
  CHECK(named(vpi_handle(vpiDiscipline, b1), "p04_elec"), "b1 is p04_elec");
  CHECK(vpi_get(vpiScalar, b1) == 1 && vpi_get(vpiSize, b1) == 1, "b1 is one bit");
  CHECK(vpi_compare_objects(p02_by_name("p04_analog.b1"), b1), "12.21 finds a branch by its full name");

  /* 11.6.7 */
  qf = vpi_handle(vpiFlow, b1);
  qp = vpi_handle(vpiPotential, b1);
  CHECK(qf != NULL && qp != NULL, "b1 carries a flow and a potential quantity");
  CHECK(vpi_get(vpiType, qf) == vpiQuantity && vpi_get(vpiType, qp) == vpiQuantity, "both are vpiQuantity");
  CHECK(!vpi_compare_objects(qf, qp), "and they are two objects");
  CHECK(vpi_compare_objects(vpi_handle(vpiBranch, qf), b1), "flow -> vpiBranch is b1");
  CHECK(vpi_compare_objects(vpi_handle(vpiBranch, qp), b1), "potential -> vpiBranch is b1");
  CHECK(named(vpi_handle(vpiNature, qf), "p04_amp"), "the flow quantity's nature is p04_amp");
  CHECK(named(vpi_handle(vpiNature, qp), "p04_volt"), "the potential quantity's nature is p04_volt");
  CHECK(vpi_get(vpiScalar, qp) == 1 && vpi_get(vpiSize, qp) == 1, "the quantity is one bit");
  CHECK(!vpi_compare_objects(vpi_handle(vpiFlow, b2), qf), "b2's flow is its own");
  expect_no_error("the analog walk");

  /* refusals */
  CHECK(vpi_handle(vpiPosNode, mid) == NULL, "11.6.5: a node has no vpiPosNode");
  expect_error("vpi_handle(vpiPosNode, node)");
  CHECK(vpi_get(vpiDirection, mid) == vpiUndefined, "11.6.5: a node has no vpiDirection");
  expect_error("vpi_get(vpiDirection, node)");
  CHECK(vpi_handle(vpiNature, b1) == NULL, "11.6.6: a branch draws no nature arrow");
  expect_error("vpi_handle(vpiNature, branch)");
  CHECK(vpi_iterate(vpiNet, b1) == NULL, "11.6.6: a branch has no nets");
  expect_error("vpi_iterate(vpiNet, branch)");
  CHECK(vpi_get_str(vpiName, qf) == NULL, "11.6.7: a quantity lists no name");
  expect_error("vpi_get_str(vpiName, quantity)");
  CHECK(vpi_handle(vpiModule, qf) == NULL, "11.6.7: no module arrow leaves a quantity");
  expect_error("vpi_handle(vpiModule, quantity)");

  /* 12.10 */
  {
    s_vpi_analog_value av;
    av.format = vpiRealVal;
    vpi_get_analog_value(p02_by_name("p04_analog.mid"), &av);
    expect_error("vpi_get_analog_value(net)");
    vpi_get_analog_value(NULL, &av);
    expect_error("vpi_get_analog_value(NULL)");
    vpi_get_analog_value(qp, NULL);
    expect_error("vpi_get_analog_value(quantity, NULL)");
  }
}

static void after_compile(void)
{
  natures_and_disciplines();
  nodes_and_branches();
  p02_done("p04_06_analog_objects");
}

/* IEEE 1364-2005 26.2.4: a startup routine only registers; the work above
 * runs at cbEndOfCompile (p02_defer). */
static void startup(void)
{
  p02_defer(after_compile);
}

void (*vlog_startup_routines[])(void) = { startup, 0 };
