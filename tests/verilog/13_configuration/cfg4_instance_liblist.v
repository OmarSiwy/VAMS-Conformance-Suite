// IEEE 1364-2005 §13.5.4, p. 208: "To modify the config so the top.a1 adder
// (and its descendants) use the gate representation and the top.a2 adder (and
// its descendants), use the rtl representation from aLib: config cfg4 design
// rtlLib.top ; default liblist gateLib rtlLib; instance top.a2 liblist aLib;
// endconfig. Because the liblist is inherited, all of the descendants of
// top.a2 inherit its liblist from the instance selection clause."
// §13.3.1.3, p. 203: "The instance name associated with the instance clause is
// a Verilog hierarchical name, starting at the top-level module of the config".
// §13.3.1.5, p. 204: "liblists are inherited hierarchically downward".
//
// The clause's text omits the ; after "config cfg4", which A.1.5 requires;
// it is written here. The §13.5 libraries (ex13_5/):
//   t=0 top rtlLib.top; t=1 top.a1 gateLib.adder; t=2 top.a2 aLib.adder;
//   t=11,12 top.a1.f1/f2 gateLib.foo (the default list);
//   t=21,22 top.a2.f1/f2 aLib.foo (top.a2's list, inherited).
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//! inherited IEEE 1364-2005 13.5.4 13.3.1.3 13.3.1.5
`timescale 1ns/1ns
config cfg4;
    design rtlLib.top ;
    default liblist gateLib rtlLib;
    instance top.a2 liblist aLib;
endconfig
