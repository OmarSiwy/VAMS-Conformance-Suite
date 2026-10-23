// IEEE 1364-2005 §13.5.2, p. 207: "To use the gate-level representations of
// adder and foo, add to the config as follows: config cfg2; design
// rtlLib.top ; default liblist gateLib aLib rtlLib; endconfig. This shall
// cause the gate representation always to be taken before the rtl
// representation, using the module definitions for adder and foo from
// adder.vg. The rtl view of top shall be taken because there is no gate
// representation available." §13.3.1.5, p. 204: "the specified library list
// is searched in the specified order."
//
// The §13.5 libraries (ex13_5/). gateLib holds adder and foo, so both come
// from adder.vg:
//   t=0 top rtlLib.top; t=1,2 top.a1/a2 gateLib.adder;
//   t=11,12,21,22 top.a1.f1 .. top.a2.f2 gateLib.foo.
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//! inherited IEEE 1364-2005 13.5.2 13.3.1.5 13.3.1.1
`timescale 1ns/1ns
config cfg2;
  design rtlLib.top ;
  default liblist gateLib aLib rtlLib;
endconfig
