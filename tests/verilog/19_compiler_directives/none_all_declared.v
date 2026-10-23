// IEEE 1364-2005 §19.2, p. 349: "When the `default_nettype is set to none,
// all nets shall be explicitly declared." Syntax 19-1 (p. 350):
// default_nettype_value ::= wire | tri | tri0 | tri1 | wand | triand | wor |
// trior | trireg | uwire | none
//
// Under `default_nettype none every net here is declared (w explicitly, and
// the child's ports in its ANSI header), so nothing is implicit and the design
// is legal: w follows r through the child's continuous assignment. r = 1 at
// time 0 -> "w=1" at time 1. The first directive, `default_nettype tri, is
// superseded by the second ("Multiple `default_nettype directives are
// allowed"); neither changes a declared net. The final `default_nettype wire
// restores the default for whatever source follows.
//! inherited IEEE 1364-2005 19.2
`timescale 1ns/1ns
`default_nettype tri
`default_nettype none
module b_19_2_child(output wire o, input wire i);
  assign o = i;
endmodule
module b_19_2_none_all_declared;
  reg r;
  wire w;
  b_19_2_child c(w, r);
  initial begin
    r = 1'b1;
    #1 $display("w=%b", w);
    $finish(0);
  end
endmodule
`default_nettype wire
