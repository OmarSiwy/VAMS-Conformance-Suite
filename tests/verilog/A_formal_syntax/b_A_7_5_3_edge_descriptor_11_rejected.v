// IEEE 1364-2005 A.7.5.3, p. 503:
//   edge_control_specifier ::= edge [ edge_descriptor { , edge_descriptor } ]
//   edge_descriptor ::= 01 | 10 | z_or_x zero_or_one | zero_or_one z_or_x
//   zero_or_one ::= 0 | 1
//   z_or_x ::= x | X | z | Z
// An edge descriptor is a transition between two different values; 11 is
// none of the four shapes.
//
// `$period(edge [11] clk, 10);` names no edge. Legal neighbour:
// b_A_7_5_system_timing_checks.v (`$period(edge [01, 10] clk, 10);`).
//! inherited IEEE 1364-2005 A.7.5.3
//! reject E0207
//! neighbour b_A_7_5_system_timing_checks.v
module b_A_7_5_3_edge_descriptor_11_rejected (clk, d, y);
  input clk, d;
  output y;
  reg ntfr;
  assign y = d;
  specify
    $period(edge [11] clk, 10);
  endspecify
endmodule
