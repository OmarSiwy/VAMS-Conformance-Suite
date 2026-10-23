// IEEE 1364-2005 A.3.3, p. 494:
//   output_terminal ::= net_lvalue
// A.8.5, p. 506: net_lvalue ::= hierarchical_net_identifier
//   [ { [ constant_expression ] } [ constant_range_expression ] ]
//   | { net_lvalue { , net_lvalue } }
// An input terminal may be any expression; an output terminal is a net
// lvalue, which an operator expression is not.
//
// `and (a & b, c, d);` puts the expression a & b where the output terminal
// stands. Legal neighbour: b_A_3_3_primitive_terminals.v
// (`and (y2, a & ~b, a | b);`).
//! inherited IEEE 1364-2005 A.3.3
//! reject E0207
//! reject a gate's output terminal is a net_lvalue
//! neighbour b_A_3_3_primitive_terminals.v
module b_A_3_3_expression_output_terminal_rejected;
  wire a, b, c, d;
  and (a & b, c, d);
  initial $display("unreachable");
endmodule
