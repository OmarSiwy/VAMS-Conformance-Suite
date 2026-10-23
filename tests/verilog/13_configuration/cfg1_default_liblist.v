// IEEE 1364-2005 §13.5.2, p. 207: "To always use the foo definition from file
// adder.v, use the following simple configuration: config cfg1; design
// rtlLib.top ; default liblist aLib rtlLib; endconfig. The default liblist
// statement overrides the library search order in the lib.map file;
// therefore, aLib is always searched before rtlLib." §13.3.1.2, p. 203: "The
// default clause selects all instances that do not match a more specific
// selection clause." §13.3.1.5, p. 204: "liblists are inherited hierarchically
// downward as instances are bound."
//
// The §13.5 libraries (ex13_5/, see default_search_order.v). cfg1's
// list aLib rtlLib finds adder and foo in aLib; top comes from the design
// statement. Each instance prints at its own time:
//   t=0 top rtlLib.top; t=1,2 top.a1/a2 aLib.adder;
//   t=11,12,21,22 top.a1.f1 .. top.a2.f2 aLib.foo.
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//! inherited IEEE 1364-2005 13.5.2 13.3.1.2 13.3.1.5 13.2.3
`timescale 1ns/1ns
config cfg1;
  design rtlLib.top ;
  default liblist aLib rtlLib;
endconfig
