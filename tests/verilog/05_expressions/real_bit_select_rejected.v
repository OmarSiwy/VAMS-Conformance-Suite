// IEEE 1364-2005 §5.2.1, p. 56: "A bit-select or part-select of a scalar, or
// of a variable or parameter of type real or realtime, shall be illegal."
// §4.8.1, p. 33, lists among the prohibited uses of reals: "Bit-select or
// part-select references of variables declared as real".
//
// r[0] bit-selects a realtime variable (§4.8: realtime is treated
// synonymously with real). Legal neighbour: operand_forms.v bit-selects
// an integer and a time variable.
//! inherited IEEE 1364-2005 5.2.1 4.8.1
//! reject E1100
//! reject a real has no bits to select
//! neighbour operand_forms.v
module b_5_2_1_real_bit_select_rejected;
  realtime r;
  initial begin
    r = 5.0;
    $display("%b", r[0]);
  end
endmodule
