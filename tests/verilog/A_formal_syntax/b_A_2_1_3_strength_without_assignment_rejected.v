// IEEE 1364-2005 A.2.1.3, p. 490: the net_declaration alternatives that
// carry a drive_strength all end in list_of_net_decl_assignments:
//     net_type [ drive_strength ] [ signed ] [ delay3 ] list_of_net_decl_assignments ;
// while the ones ending in list_of_net_identifiers have no drive_strength:
//     net_type [ signed ] [ delay3 ] list_of_net_identifiers ;
//
// `wire (strong0, strong1) w;` gives a drive strength to a net with no
// assignment, which no alternative derives. Legal neighbour:
// b_A_2_1_3_type_declarations.v (`wire (strong0, strong1) signed n2 = 1'b0;`).
//! inherited IEEE 1364-2005 A.2.1.3
//! reject E0207
//! reject a drive strength is only legal on a net declaration assignment
//! neighbour b_A_2_1_3_type_declarations.v
module b_A_2_1_3_strength_without_assignment_rejected;
  wire (strong0, strong1) w;
  initial $display("unreachable");
endmodule
