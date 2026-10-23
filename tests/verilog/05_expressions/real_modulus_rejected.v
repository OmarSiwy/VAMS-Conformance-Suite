// IEEE 1364-2005 §5.1.1, p. 42: "The operators shown in Table 5-2 shall be
// legal when applied to real operands. All other operators shall be
// considered illegal when used with real operands." Table 5-3 (p. 43),
// "Operators not allowed for real expressions", lists % (Modulus).
//
// r % 2.0 applies % to a real. Legal neighbour: real_operand_results.v
// applies every Table 5-2 operator to the same kind of operand.
//! inherited IEEE 1364-2005 5.1.1
//! reject E1100
//! reject this operator does not take a real operand
//! neighbour real_operand_results.v
module b_5_1_1_real_modulus_rejected;
  real r;
  initial begin
    r = 5.0;
    $display("%f", r % 2.0);
  end
endmodule
