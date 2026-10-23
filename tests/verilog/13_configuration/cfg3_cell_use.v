// IEEE 1364-2005 §13.5.3, p. 207: "To modify the config to use the rtl view of
// adder and the gate-level representation of foo from gateLib, use the
// following: config cfg3; design rtlLib.top ; default liblist aLib rtlLib;
// cell foo use gateLib.foo; endconfig. The cell clause selects all cells named
// foo and explicitly binds them to the gate representation in gateLib."
// §13.3.1.4, p. 204: "The cell selection clause names the cell to which it
// applies." §13.3.1.6, p. 204: "It specifies the exact library and cell to
// which a selected cell or instance is bound."
//
// The §13.5 libraries (ex13_5/). adder by the default list (aLib), every foo
// by the cell clause (gateLib):
//   t=0 top rtlLib.top; t=1,2 top.a1/a2 aLib.adder;
//   t=11,12,21,22 top.a1.f1 .. top.a2.f2 gateLib.foo.
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//! inherited IEEE 1364-2005 13.5.3 13.3.1.4 13.3.1.6 13.3.1.2
`timescale 1ns/1ns
config cfg3;
     design rtlLib.top ;
     default liblist aLib rtlLib;
cell foo use gateLib.foo;
endconfig
