// IEEE 1364-2005 §4.3.1, p. 24: "Both the msb constant expression and the lsb
// constant expression shall be constant integer expressions."
//
// n is an integer variable, not a constant. Legal neighbour:
// vector_ranges.v's `reg [W:0] p` with W a parameter.
//! inherited IEEE 1364-2005 4.3.1
//! reject E1100
//! reject a constant expression is required here
//! neighbour vector_ranges.v
module b_4_3_1_variable_range_bound_rejected;
  integer n;
  reg [n:0] v;
  initial $display("%b", v);
endmodule
