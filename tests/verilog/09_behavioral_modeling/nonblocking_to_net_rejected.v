// IEEE 1364-2005 §9.2, p. 117: "The left-hand side shall be a variable that
// receives the assignment from the right-hand side."
// §9.2.2, p. 119 (Syntax 9-2): "nonblocking_assignment ::= variable_lvalue <=
// [ delay_or_event_control ] expression" ... "In this syntax, variable_lvalue
// is a data type that is valid for a procedural assignment statement".
//
// w is a net, not a variable, and is the target of a nonblocking assignment.
// Legal neighbour: nonblocking_scheduling.v, whose nonblocking
// targets are all regs.
//! inherited IEEE 1364-2005 9.2 9.2.2
//! reject E1100
//! reject there is no procedural assignment to a net
//! neighbour nonblocking_scheduling.v
module b_9_2_2_nonblocking_to_net_rejected;
  wire w;
  initial w <= 1'b1;
endmodule
