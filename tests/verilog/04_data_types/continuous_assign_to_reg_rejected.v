// IEEE 1364-2005 §4.7, p. 32: "Assignments to a reg are made by procedural
// assignments (see 6.2 and 9.2)." §6.1, p. 68: "Continuous assignments shall
// drive values onto nets, both vector and scalar." Table 6-1 (p. 68) lists
// only nets as the left-hand side of a continuous assignment.
//
// r is a reg, so `assign r = 1'b1;` is illegal. Legal neighbour:
// reg_holds_between_assignments.v assigns its regs procedurally.
//! inherited IEEE 1364-2005 4.7 6.1
//! reject E1100
//! reject a continuous assignment can only drive a net
//! neighbour reg_holds_between_assignments.v
module b_4_7_continuous_assign_to_reg_rejected;
  reg r;
  assign r = 1'b1;
  initial #1 $display("%b", r);
endmodule
