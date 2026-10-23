// IEEE 1364-2005 §4.10.1, p. 36: "The list_of_param_assignments shall be a
// comma-separated list of assignments, where the right-hand side of the
// assignment shall be a constant expression, that is, an expression
// containing only constant numbers and previously defined parameters (see
// Clause 5)." §4.10.1: "Parameters represent constants".
//
// r is declared, as a reg, so P's value reads a variable: the refusal says
// that a parameter's value is a constant expression, not that r is
// undeclared. Legal neighbour: Q = P0 + 1 reads a previously defined
// parameter.
//! inherited IEEE 1364-2005 4.10.1
//! reject E1100
//! reject §4.10.1
module b_4_10_1_parameter_from_variable_rejected;
  reg [3:0] r;
  parameter P0 = 2;
  parameter Q = P0 + 1;
  parameter P = r;
  initial $display("%0d %0d", Q, P);
endmodule
