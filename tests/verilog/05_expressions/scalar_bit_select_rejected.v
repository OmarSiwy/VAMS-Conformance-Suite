// IEEE 1364-2005 §5.2.1, p. 56: "A bit-select or part-select of a scalar, or
// of a variable or parameter of type real or realtime, shall be illegal."
//
// s is a scalar reg (§4.3: "A net or reg declaration without a range
// specification shall be considered 1 bit wide and is known as a scalar"), so
// s[0] is illegal even though index 0 would name its only bit. Legal
// neighbour: bit_part_select_addressing.v bit-selects vectors.
//! inherited IEEE 1364-2005 5.2.1
//! reject E1100
//! reject a scalar has no bits to select
//! neighbour bit_part_select_addressing.v
module b_5_2_1_scalar_bit_select_rejected;
  reg s;
  initial begin
    s = 1'b1;
    $display("%b", s[0]);
  end
endmodule
