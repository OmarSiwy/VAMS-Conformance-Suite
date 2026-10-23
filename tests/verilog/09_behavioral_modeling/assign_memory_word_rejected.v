// IEEE 1364-2005 §9.3, p. 122: "The left-hand side of the assignment in the
// assign statement shall be a variable reference or a concatenation of
// variables. It shall not be a memory word (array reference) or a bit-select
// or a part-select of a variable."
//
// assign m[0] = ... takes a word of the memory m. Legal neighbour:
// assignment_assign_deassign.v assigns the whole variable `value`.
//! inherited IEEE 1364-2005 9.3
//! reject E1100
//! reject names one whole variable or net
//! neighbour assignment_assign_deassign.v
module b_9_3_assign_memory_word_rejected;
  reg [3:0] m [0:1];
  initial assign m[0] = 4'd1;
endmodule
