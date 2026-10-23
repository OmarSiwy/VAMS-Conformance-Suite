// IEEE 1364-2005 A.2.3, p. 491:
//   list_of_net_identifiers ::= net_identifier { dimension }
//     { , net_identifier { dimension } }
// Every comma in the list is followed by a net_identifier.
//
// `wire a, ;` ends the list with a comma and no identifier, so it derives no
// list_of_net_identifiers. Legal neighbour: b_A_2_3_declaration_lists.v
// (`wire [1:0] na [0:1], nb;`).
//! inherited IEEE 1364-2005 A.2.3
//! reject E0208
//! neighbour b_A_2_3_declaration_lists.v
module b_A_2_3_trailing_comma_rejected;
  wire a, ;
  initial $display("unreachable");
endmodule
