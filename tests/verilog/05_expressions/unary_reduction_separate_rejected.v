//! inherited IEEE 1364-2005 A.8.3
//! reject expected an expression: found `&`
// A unary operator's operand is a primary, so `~ &in` is a syntax error: ~
// applied to a separate reduction operator is not a primary (pr2794144).
module triage_unary_reduction_separate_rejected;
  reg [3:0] in;
  reg res;

  initial begin
    in = 4'b1110;
    res = ~ &in;
  end
endmodule
