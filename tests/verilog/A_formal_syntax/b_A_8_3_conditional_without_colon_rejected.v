// IEEE 1364-2005 A.8.3, p. 504:
//   conditional_expression ::= expression1 ? { attribute_instance } expression2 : expression3
// The `: expression3` arm is not optional.
//
// `(a ? b)` has no third operand. Legal neighbour: b_A_8_3_expressions.v
// (`(i > 1) ? v[7:4] : v[3:0]`).
//! inherited IEEE 1364-2005 A.8.3
//! reject E0207
//! reject unexpected token: found `)`
//! neighbour b_A_8_3_expressions.v
module b_A_8_3_conditional_without_colon_rejected;
  reg a, b, c;
  initial begin
    a = 1;
    b = 0;
    c = (a ? b);
    $display("unreachable");
  end
endmodule
