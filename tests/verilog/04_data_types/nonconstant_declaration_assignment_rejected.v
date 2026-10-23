// IEEE 1364-2005 §4.2.2, Syntax 4-2, p. 23:
//   variable_type ::= variable_identifier { dimension }
//                   | variable_identifier = constant_expression
// and §6.2.1, p. 72, which §4.2.2 points to: "The assignment shall be to a
// constant expression."
//
// b's declaration assignment reads the variable a, which is not a constant
// expression (§5: "The operands of a constant expression consist of constant
// numbers, strings, parameters, ..."). Legal neighbour:
// variable_initial_values.v's `reg [3:0] d = 4'h4`.
//! inherited IEEE 1364-2005 4.2.2
//! reject E1100
//! reject a constant expression is required here
//! neighbour variable_initial_values.v
module b_4_2_2_nonconstant_declaration_assignment_rejected;
  reg a;
  reg b = a;
  initial $display("%b", b);
endmodule
