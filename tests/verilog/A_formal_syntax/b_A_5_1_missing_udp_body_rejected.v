// IEEE 1364-2005 A.5.1, p. 496:
//   udp_declaration ::= { attribute_instance } primitive udp_identifier ( udp_port_list ) ;
//       udp_port_declaration { udp_port_declaration } udp_body endprimitive
//     | ...
// A.5.3, p. 496: udp_body ::= combinational_body | sequential_body, each of
// which contains a table. The udp_body is not optional.
//
// b_A_5_1_empty declares its ports and ends with no table. Legal neighbour:
// b_A_5_1_udp_declarations.v.
//! inherited IEEE 1364-2005 A.5.1
//! reject E0207
//! reject a udp_body is a `table
//! neighbour b_A_5_1_udp_declarations.v
primitive b_A_5_1_empty (y, a);
  output y;
  input a;
endprimitive
module b_A_5_1_missing_udp_body_rejected;
  initial $display("unreachable");
endmodule
