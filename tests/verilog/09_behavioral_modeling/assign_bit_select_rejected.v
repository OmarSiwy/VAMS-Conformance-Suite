// IEEE 1364-2005 §9.3, p. 122: "The left-hand side of the assignment in the
// assign statement shall be a variable reference or a concatenation of
// variables. It shall not be a memory word (array reference) or a bit-select
// or a part-select of a variable."
//
// assign r[0] = ... takes a bit-select of the variable r. Legal neighbour:
// ../09_behavioral_modeling/assignment_assign_deassign.v assigns the
// whole variable `value`.
//! inherited IEEE 1364-2005 9.3
//! reject E1100
//! reject names one whole variable or net
//! neighbour assignment_assign_deassign.v
module b_9_3_assign_bit_select_rejected;
  reg [3:0] r;
  initial assign r[0] = 1'b1;
endmodule
