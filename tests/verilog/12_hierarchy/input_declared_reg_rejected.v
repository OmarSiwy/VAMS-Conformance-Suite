// IEEE 1364-2005 §12.3.9, p. 179: "The rules in 12.3.9.1 through 12.3.9.3 shall
// govern the way module ports are declared and the way they are
// interconnected." §12.3.9.1: "An input or inout port shall be of type net."
//
// m's input a is declared reg. Legal neighbour:
// structural_sinks_and_expression_sources.v (input and inout nets).
//! inherited IEEE 1364-2005 12.3.9 12.3.9.1
//! reject E1100
//! reject only an output port may be declared as a variable
//! neighbour structural_sinks_and_expression_sources.v
module m(a, y);
  input a;
  reg a;
  output y;
endmodule
module b_12_3_9_1_input_declared_reg_rejected;
  wire p, q;
  m u(p, q);
endmodule
