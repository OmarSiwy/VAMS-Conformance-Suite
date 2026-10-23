// IEEE 1364-2005 §19.2, p. 349: "The directive `default_nettype controls the
// net type created for implicit net declarations (see 4.5). It can be used
// only outside of module definitions. Multiple `default_nettype directives
// are allowed. The latest occurrence of this directive in the source controls
// the type of nets that will be implicitly declared." ... "When no
// `default_nettype directive is present or if the `resetall directive is
// specified, implicit nets are of type wire."
// §4.5, p. 26: "If an identifier is used in the terminal list of a
// primitive instance or a module instance, and that identifier has not been
// declared previously in the scope where the instantiation appears ... then
// an implicit scalar net of default net type shall be assumed."
//
// Each parent below connects two child outputs, one driving 1 and one 0, to
// an identifier it never declares (or, for p_tri1, one child input only):
//   p_wire  (no directive yet: wire)  wire: 1 vs 0 -> x
//   p_wand  (`default_nettype wand)   wired AND: 1 & 0 -> 0
//   p_wor   (`default_nettype wor)    wired OR: 1 | 0 -> 1
//   p_tri1  (`default_nettype tri1)   no driver at all: tri1 pulls up -> 1
//   p_reset (`resetall, then only `timescale): wire again, 1 vs 0 -> x
// Read at time 1 in each parent, printed in order by distinct delays.
//! inherited IEEE 1364-2005 19.2 19.6
`timescale 1ns/1ns
module b_19_2_one(output o); assign o = 1'b1; endmodule
module b_19_2_zero(output o); assign o = 1'b0; endmodule
module b_19_2_sink(input i); endmodule
module b_19_2_p_wire;
  b_19_2_one a(n); b_19_2_zero b(n);
  initial #1 $display("wire %b", n);
endmodule
`default_nettype wand
module b_19_2_p_wand;
  b_19_2_one a(n); b_19_2_zero b(n);
  initial #2 $display("wand %b", n);
endmodule
`default_nettype wor
module b_19_2_p_wor;
  b_19_2_one a(n); b_19_2_zero b(n);
  initial #3 $display("wor %b", n);
endmodule
`default_nettype tri1
module b_19_2_p_tri1;
  b_19_2_sink s(n);
  initial #4 $display("tri1 %b", n);
endmodule
`resetall
`timescale 1ns/1ns
module b_19_2_p_reset;
  b_19_2_one a(n); b_19_2_zero b(n);
  initial #5 $display("reset %b", n);
endmodule
module b_19_2_implicit_net_types;
  b_19_2_p_wire pw();
  b_19_2_p_wand pa();
  b_19_2_p_wor po();
  b_19_2_p_tri1 pt();
  b_19_2_p_reset pr();
endmodule
