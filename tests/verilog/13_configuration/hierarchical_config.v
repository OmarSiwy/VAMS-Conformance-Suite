// IEEE 1364-2005 §13.3.2, p. 205: "For situations where it is desirable to
// specify a special set of configuration rules for a subsection of a design,
// it is possible to bind a particular instance directly to a configuration
// using the binding clause" ... "The design statement in lib1.foo:config
// shall specify the actual binding for the instance top.a1.foo, and the rules
// specified in the config shall determine the configuration of all other
// subinstances under top.a1.foo."
//
// The file holds two configs, and §13.4.4 names no rule for choosing the one
// that configures the design. This fixture takes the config no other config
// references (cfg), as §12.1.1 takes an uninstantiated module as a top;
// sub is reached only through cfg's use clause.
//
// top instantiates rtl as u. cfg binds top.u to the configuration sub, whose
// design statement names work.gate, so top.u is bound to gate. It prints its
// %m and %l (§13.6): "gate top.u work.gate". top finishes at t=1.
//! inherited IEEE 1364-2005 13.3.2
`timescale 1ns/1ns
config sub;
  design work.gate;
endconfig
config cfg;
  design work.top;
  instance top.u use work.sub:config;
endconfig
module rtl;
  initial $display("rtl %m %l");
endmodule
module gate;
  initial $display("gate %m %l");
endmodule
module top;
  rtl u();
  initial #1 $finish(0);
endmodule
