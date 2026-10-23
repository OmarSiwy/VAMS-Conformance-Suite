// IEEE 1364-2005 §13.7.1, p. 209: "In the absence of a configuration, it shall
// be necessary for all compliant tools to provide a mechanism of specifying a
// library search order on the command line that overrides the default order
// from the library map file. This mechanism shall include specification of
// library names only, with the definitions of these libraries to be taken
// from the library map file." "NOTE—It is recommended all compliant tools use
// "-L <library_name>" to specify this search order."
//
// The §13.5 libraries (ex13_5/) searched gateLib, then rtlLib, instead of the
// map's rtlLib aLib gateLib: adder and foo both come from gateLib. top is the
// uninstantiated module (§12.1.1), found by no search.
//   t=0 top rtlLib.top; t=1,2 top.a1/a2 gateLib.adder;
//   t=11,12,21,22 top.a1.f1 .. top.a2.f2 gateLib.foo.
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//@ liblist gateLib
//@ liblist rtlLib
//! inherited IEEE 1364-2005 13.7.1
`timescale 1ns/1ns
