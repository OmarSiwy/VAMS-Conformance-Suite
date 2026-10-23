// IEEE 1364-2005 §5.1.1, p. 42: "The operators shown in Table 5-2 shall be
// legal when applied to real operands. All other operators shall be
// considered illegal when used with real operands." Table 5-3 (p. 43) lists
// `~` among the bitwise operators "not allowed for real expressions".
//
// ~r applies bitwise negation to a real. The refusal cites the clause by its
// IEEE 1364-2005 number, §5.1.1; §4.1.1 is where IEEE 1364-1995 put it.
// Legal neighbour: real_operand_results.v's unary minus of a real.
//! inherited IEEE 1364-2005 5.1.1
//! reject E1100
//! reject §5.1.1: this operator does not take a real operand
//! neighbour real_operand_results.v
module b_5_1_1_real_operand_diagnostic_clause_rejected;
  real r;
  reg b;
  initial begin
    r = 1.0;
    b = ~r;
    $display("%b", b);
  end
endmodule
