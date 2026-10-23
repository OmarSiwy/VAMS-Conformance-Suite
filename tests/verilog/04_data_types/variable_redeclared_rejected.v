// IEEE 1364-2005 §4.2.2, p. 23: "It is illegal to redeclare a name already
// declared by a net, parameter, or variable declaration."
//
// a is declared as a reg and again as an integer. Legal neighbour:
// variable_initial_values.v declares each variable once.
//! lrm 2.8
//! lrm 2.8:1
//! inherited IEEE 1364-2005 4.2.2
//! reject E1100
//! reject duplicate digital variable
//! neighbour variable_initial_values.v
module b_4_2_2_variable_redeclared_rejected;
  reg a;
  integer a;
  initial $display("%b", a);
endmodule
