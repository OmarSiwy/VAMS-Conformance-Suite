// IEEE 1364-2005 §13.5.1, p. 207: "With no configuration, the libraries are
// searched according to the library declaration order in the library map
// file. In other words, all instances of module adder shall use aLib.adder
// (because aLib is the first library specified that contains a cell named
// adder), and all instances of module foo shall use rtlLib.foo (because rtlLib
// is the first library that contains foo)."
// §13.2.3, p. 202: "The cell is mapped into the library whose file path
// specification matches the source file name." §13.2.1.1, p. 201: a file
// path specification that ends with an explicit filename is resolved before
// one that ends with a wildcarded filename.
//
// ex13_5/ holds §13.5's top.v, adder.v, adder.vg and lib.map (rtlLib top.v;
// aLib adder.*; gateLib adder.vg). adder.vg matches aLib's adder.* and
// gateLib's explicit adder.vg; the explicit one wins, so the library
// structure is §13.5's: rtlLib.top, rtlLib.foo, aLib.adder, aLib.foo,
// gateLib.adder, gateLib.foo. This file matches nothing: work (§13.2.1).
// Search order rtlLib aLib gateLib work. Each instance prints at its time:
//   t=0 top rtlLib.top; t=1,2 top.a1/a2 aLib.adder;
//   t=11,12,21,22 top.a1.f1 .. top.a2.f2 rtlLib.foo.
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//! inherited IEEE 1364-2005 13.5.1 13.2.1 13.2.1.1 13.2.3 13.6
`timescale 1ns/1ns
