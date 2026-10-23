// IEEE 1364-2005 §13.5.5, p. 208: "config cfg5; design aLib.adder; default
// liblist gateLib aLib; instance adder.f1 liblist rtlLib; endconfig. To use
// this configuration cfg5 for the top.a2 instance of adder and take the full
// default aLib adder for the top.a1 instance, use the following config:
// config cfg6; design rtlLib.top; default liblist aLib rtlLib; instance
// top.a2 use work.cfg5:config ; endconfig. ... It is the design statement in
// config cfg5 that defines the exact binding for the top.a2 instance itself.
// The rest of cfg5 defines the rules to bind the descendants of top.a2. Notice
// the instance clause in cfg5 is relative to its own top-level module, adder."
// §13.3.2, p. 205: "The design statement in lib1.foo:config shall specify the
// actual binding for the instance top.a1.foo, and the rules specified in the
// config shall determine the configuration of all other subinstances".
//
// Both configs are in this file, which maps to work, so work.cfg5 is cfg5;
// cfg6 is the one no use clause names, so it configures the design. The §13.5
// libraries (ex13_5/):
//   t=0 top rtlLib.top; t=1 top.a1 aLib.adder (cfg6's list);
//   t=2 top.a2 aLib.adder (cfg5's design statement);
//   t=11,12 top.a1.f1/f2 aLib.foo (cfg6's list, inherited);
//   t=21 top.a2.f1 rtlLib.foo (cfg5's adder.f1 clause);
//   t=22 top.a2.f2 gateLib.foo (cfg5's default list).
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//! inherited IEEE 1364-2005 13.5.5 13.3.2 13.3.1.6 13.1.1
`timescale 1ns/1ns
config cfg5;
    design aLib.adder;
    default liblist gateLib aLib;
    instance adder.f1 liblist rtlLib;
endconfig
config cfg6;
    design rtlLib.top;
    default liblist aLib rtlLib;
    instance top.a2 use work.cfg5:config ;
endconfig
