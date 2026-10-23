// IEEE 1364-2005 §9.3, p. 122: "The left-hand side of the assignment in the
// assign statement shall be a variable reference or a concatenation of
// variables." §9.3.1, p. 123: "The assign procedural continuous assignment
// statement shall override all procedural assignments to a variable."
// §9.3.2, p. 124, by contrast: "a force can be applied to nets as well as to
// variables."
//
// A procedural assign to the net w. Legal neighbours: the same statement with
// `force` (assignment_force_release.v forces the net netvalue), and
// procedural assign to a variable (assignment_assign_deassign.v).
//! inherited IEEE 1364-2005 9.3.1
//! reject E1100
//! reject assign/deassign take a variable
//! neighbour assignment_assign_deassign.v
//! neighbour assignment_force_release.v
module b_9_3_1_assign_to_net_rejected;
  wire w;
  initial assign w = 1'b1;
endmodule
