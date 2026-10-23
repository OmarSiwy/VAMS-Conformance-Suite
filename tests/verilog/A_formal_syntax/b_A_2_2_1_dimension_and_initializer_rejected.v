// IEEE 1364-2005 A.2.2.1, p. 490:
//   variable_type ::= variable_identifier { dimension }
//     | variable_identifier = constant_expression
// A variable_type is either an array (dimensions) or an initialized
// variable, never both.
//
// `reg [3:0] m [0:1] = 4'd0;` gives m a dimension and an initializer, which
// neither alternative derives. Legal neighbour:
// b_A_2_2_1_net_and_variable_types.v (`reg [3:0] v = 4'd3, m [0:1];`).
//! inherited IEEE 1364-2005 A.2.2.1
//! reject E1100
//! reject an unpacked array declaration takes no initializer
//! neighbour b_A_2_2_1_net_and_variable_types.v
module b_A_2_2_1_dimension_and_initializer_rejected;
  reg [3:0] m [0:1] = 4'd0;
  initial $display("unreachable");
endmodule
