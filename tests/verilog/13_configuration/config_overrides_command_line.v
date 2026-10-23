// IEEE 1364-2005 §13.7, p. 209: "In the absence of a configuration, it is
// possible to perform basic control of the library searching order when
// binding a design. When a config is used, the config overrides the rules
// specified in this subclause."
//
// The §13.5 libraries (ex13_5/) and cfg1 of §13.5.2 (cfg1_default_liblist.v),
// with the command line of command_line_search_order.v added: -L
// gateLib -L rtlLib. Without the config that order binds adder and foo from
// gateLib; with cfg1 its `default liblist aLib rtlLib` wins, so the
// transcript is cfg1's:
//   t=0 top rtlLib.top; t=1,2 top.a1/a2 aLib.adder;
//   t=11,12,21,22 top.a1.f1 .. top.a2.f2 aLib.foo.
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//@ liblist gateLib
//@ liblist rtlLib
//! inherited IEEE 1364-2005 13.7
`timescale 1ns/1ns
config cfg1;
  design rtlLib.top ;
  default liblist aLib rtlLib;
endconfig
