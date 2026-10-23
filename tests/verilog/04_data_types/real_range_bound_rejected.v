// IEEE 1364-2005 §4.3.1, p. 24: "Both the msb constant expression and the lsb
// constant expression shall be constant integer expressions."
//
// 3.5 is a real constant, not an integer expression. Legal neighbour:
// vector_ranges.v's integer bounds, including negative ones.
//! inherited IEEE 1364-2005 4.3.1
//! reject E1100
//! reject constant integer expression
//! neighbour vector_ranges.v
module b_4_3_1_real_range_bound_rejected;
  reg [3.5:0] v;
  initial $display("%b", v);
endmodule
