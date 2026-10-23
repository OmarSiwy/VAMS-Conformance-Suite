// IEEE 1364-2005 A.2.5, p. 492:
//   range ::= [ msb_constant_expression : lsb_constant_expression ]
// A declaration's range names both bounds, separated by a colon.
//
// `reg [7] r;` gives one bound, which derives no range. Legal neighbour:
// b_A_2_5_ranges.v (`reg [7:0] d;`).
//! inherited IEEE 1364-2005 A.2.5
//! reject E0207
//! reject unexpected token: found `]`
//! neighbour b_A_2_5_ranges.v
module b_A_2_5_single_bound_range_rejected;
  reg [7] r;
  initial $display("unreachable");
endmodule
