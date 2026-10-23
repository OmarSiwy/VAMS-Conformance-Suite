// IEEE 1364-2005 §5.2.1, p. 56: "A constant part-select of a vector reg or
// net is given with the following syntax: vect[msb_expr:lsb_expr] Both
// msb_expr and lsb_expr shall be constant integer expressions. The first
// expression has to address a more significant bit than the second
// expression."
//
// v is reg [7:0], so bit 0 is its least significant bit and v[0:3] names the
// less significant bit first. Legal neighbour: v[3:0] in
// bit_part_select_addressing.v.
//! inherited IEEE 1364-2005 5.2.1
//! reject E1100
//! reject part-select
//! neighbour bit_part_select_addressing.v
module b_5_2_1_reversed_part_select_rejected;
  reg [7:0] v;
  initial begin
    v = 8'hA5;
    $display("%b", v[0:3]);
  end
endmodule
