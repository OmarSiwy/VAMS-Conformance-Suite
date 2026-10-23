// IEEE 1364-2005 §5.2.1, p. 56: "A constant part-select of a vector reg or
// net is given with the following syntax: vect[msb_expr:lsb_expr] Both
// msb_expr and lsb_expr shall be constant integer expressions."
//
// i is an integer variable, so v[i:0] is not a constant part-select (a
// run-time base needs the indexed form, v[i -: 4]). Legal neighbour: v[3:0]
// in bit_part_select_addressing.v.
//! inherited IEEE 1364-2005 5.2.1
//! reject E1100
//! reject a constant expression is required here
//! neighbour bit_part_select_addressing.v
module b_5_2_1_variable_part_select_rejected;
  reg [7:0] v;
  integer i;
  initial begin
    v = 8'hA5;
    i = 3;
    $display("%b", v[i:0]);
  end
endmodule
