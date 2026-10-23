// IEEE 1364-2005 A.4.1, p. 495:
//   list_of_port_connections ::= ordered_port_connection { , ordered_port_connection }
//     | named_port_connection { , named_port_connection }
// One instance's connections are all ordered or all named; §12.3.6, p. 177
// (quoted for context): "The two types of module port connections shall not
// be mixed; connections to the ports of a particular module instance shall be
// all by order or all by name."
//
// `u (4'd1, .y(4'd0), .s(s))` starts ordered and continues by name, which
// neither alternative derives. Legal neighbour:
// b_A_4_1_module_instantiation.v (u1 ordered, u2 named).
// VerA refuses it at elaboration (E1100), naming §12.3.6's rule.
//! inherited IEEE 1364-2005 A.4.1
//! reject E1100
//! reject mixes ordered and named port connections
//! neighbour b_A_4_1_module_instantiation.v
module b_A_4_1_leaf (x, y, s);
  input [3:0] x, y;
  output [3:0] s;
  assign s = x + y;
endmodule
module b_A_4_1_mixed_port_connections_rejected;
  wire [3:0] s;
  b_A_4_1_leaf u (4'd1, .y(4'd0), .s(s));
  initial $display("unreachable");
endmodule
