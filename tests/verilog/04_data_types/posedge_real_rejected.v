// IEEE 1364-2005 §4.8.1, p. 33: "Real number constants and real variables
// are also prohibited in the following cases: — Edge descriptors (posedge,
// negedge) applied to real variables"
//
// @(posedge r) applies an edge descriptor to a real. Legal neighbour:
// reg_holds_between_assignments.v's @(posedge clk) on a reg.
//! inherited IEEE 1364-2005 4.8.1
//! reject E1100
//! reject posedge
//! neighbour reg_holds_between_assignments.v
module b_4_8_1_posedge_real_rejected;
  real r;
  always @(posedge r) $display("edge");
  initial #1 r = 1.0;
endmodule
