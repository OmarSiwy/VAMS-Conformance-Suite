// IEEE 1364-2005 §5.2.1 requires an indexed part-select's width to be a
// positive constant integer. Zero is not positive. native_indexed_selects.v
// is the legal neighbour with constant widths and runtime bases.
//! inherited IEEE 1364-2005 5.2.1
//! reject E1100
//! reject an indexed part-select's width is a positive constant
//! neighbour native_indexed_selects.v
module native_select_zero_width_rejected;
  reg [7:0] v;
  initial $display("%b", v[0 +: 0]);
endmodule
