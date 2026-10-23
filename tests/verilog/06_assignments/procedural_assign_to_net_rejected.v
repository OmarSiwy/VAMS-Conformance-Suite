// IEEE 1364-2005 §6, p. 68: "There are two basic forms of assignments: — The
// continuous assignment, which assigns values to nets — The procedural
// assignment, which assigns values to variables". Table 6-1 (p. 68) lists
// only variables, their selects and memory words as the left-hand side of a
// procedural assignment. §6.2, p. 72: "In contrast, procedural assignments
// put values in variables."
//
// w is a wire, so the blocking assignment `w = 1'b1;` in an initial block is
// illegal. Legal neighbour: variable_holds_value.v assigns only
// variables procedurally, and table_6_1_left_hand_forms.v drives its
// nets with continuous assignments.
//! inherited IEEE 1364-2005 6 6.2
//! reject E1100
//! reject there is no procedural assignment to a net
//! neighbour variable_holds_value.v
//! neighbour table_6_1_left_hand_forms.v
module b_6_procedural_assign_to_net_rejected;
  wire w;
  initial begin
    w = 1'b1;
    $display("%b", w);
  end
endmodule
