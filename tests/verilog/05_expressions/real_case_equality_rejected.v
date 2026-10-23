// IEEE 1364-2005 §5.1.1, p. 42: "The operators shown in Table 5-2 shall be
// legal when applied to real operands. All other operators shall be
// considered illegal when used with real operands." Table 5-3 (p. 43),
// "Operators not allowed for real expressions", lists === !== (Case
// equality).
//
// r === 5.0 applies === to reals; == on the same operands is Table 5-2's and
// legal (real_operand_results.v).
//! inherited IEEE 1364-2005 5.1.1
//! reject E1100
//! reject this operator does not take a real operand
//! neighbour real_operand_results.v
module b_5_1_1_real_case_equality_rejected;
  real r;
  initial begin
    r = 5.0;
    $display("%b", r === 5.0);
  end
endmodule
