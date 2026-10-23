// IEEE 1364-2005 §13.3.1.5, p. 204: "If no library list clause is selected or
// if the selected library list is empty, then the library list contains the
// single name that is the library in which the cell containing the unbound
// instance is found (i.e., the parent cell's library)." §13.4.4, p. 206: "In
// the case where the config includes a design statement, then the specified
// cell shall be the top-level module, regardless of the presence of any
// uninstantiated cells in the rest of the source files."
//
// The §13.5 libraries (ex13_5/). cfg has no liblist at all. Its design cell
// aLib.adder is the top (top, uninstantiated, is not). adder's f1 and f2 are
// searched for in adder's library, aLib, so both are aLib.foo, where the
// map's order with no config would give rtlLib.foo
// (default_search_order.v). adder's D is 0:
//   t=0 adder aLib.adder; t=1,2 adder.f1/f2 aLib.foo.
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//! inherited IEEE 1364-2005 13.3.1.5 13.4.4
`timescale 1ns/1ns
config cfg;
  design aLib.adder;
endconfig
