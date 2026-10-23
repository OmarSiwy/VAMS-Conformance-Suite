// IEEE 1364-2005 §15.4, Syntax 15-15, p. 258:
//   edge_control_specifier ::= edge [ edge_descriptor { , edge_descriptor } ]
//   edge_descriptor ::= 01 | 10 | z_or_x zero_or_one | zero_or_one z_or_x
//   zero_or_one ::= 0 | 1
//   z_or_x ::= x | X | z | Z
// and p. 259: "Edge-control specifiers contain the keyword edge followed by
// a square-bracketed list of from one to six pairs of edge transitions
// between 0, 1, and x".
//
// edge[00] names 0 -> 0, which is no transition and no edge_descriptor.
// Legal neighbour: timing_check_forms.v's edge[01, 0x, x1],
// edge[10, x0, 1x] and edge[01, 10, 0z, z1].
//! inherited IEEE 1364-2005 15.4
//! reject edge descriptor
//! neighbour timing_check_forms.v
`timescale 1ns/1ns
module b_15_4_edge_descriptor_rejected(clk, d);
  input clk, d;
  specify
    $setup(d, edge[00] clk, 2);
  endspecify
endmodule
