// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection. It can appear as a suffix to an
// operator or a Verilog function name in an expression."
// Annex A.8.3 expression ::= primary | unary_operator { attribute_instance }
// primary | expression binary_operator { attribute_instance } expression |
// conditional_expression: an attribute follows an operator, never begins an
// operand.
//
// In a = (* x *) b the attribute follows `=`, which is not an operator of
// the expression, and prefixes the primary b. Legal neighbour:
// examples.v, whose b + (* mode = "cla" *) c suffixes the +.
//! inherited IEEE 1364-2005 3.8
//! reject E0209
//! reject expected an expression: found `(*`
//! neighbour examples.v
module b_3_8_operand_prefix_rejected;
  reg [3:0] a, b;
  initial begin
    b = 1;
    a = (* x *) b;
    $display("%0d", a);
  end
endmodule
