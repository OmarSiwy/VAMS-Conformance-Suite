// IEEE 1364-2005 A.2.4, p. 491:
//   param_assignment ::= parameter_identifier = constant_mintypmax_expression
// The `=` and its constant expression are not optional: every parameter is
// declared with its value.
//
// `parameter P;` names a parameter with no param_assignment. Legal
// neighbour: b_A_2_4_declaration_assignments.v (`parameter P = 2 * 3;`).
//! inherited IEEE 1364-2005 A.2.4
//! reject E0207
//! reject unexpected token: found `;`
//! neighbour b_A_2_4_declaration_assignments.v
module b_A_2_4_parameter_without_value_rejected;
  parameter P;
  initial $display("unreachable");
endmodule
