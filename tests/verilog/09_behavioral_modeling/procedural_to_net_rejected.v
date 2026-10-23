// IEEE 1364-2005 §9.2, p. 117: "The right-hand side of a procedural assignment
// can be any expression that evaluates to a value. The left-hand side shall be
// a variable that receives the assignment from the right-hand side."
// §9.2.1, p. 118 (Syntax 9-1): "blocking_assignment ::= variable_lvalue = [
// delay_or_event_control ] expression" ... "In this syntax, variable_lvalue is
// a data type that is valid for a procedural assignment statement".
//
// w is a net, not a variable, and is the target of a blocking assignment.
// Legal neighbour: lvalue_forms.v assigns every variable form §9.2
// lists.
//! inherited IEEE 1364-2005 9.2 9.2.1
//! reject E1100
//! reject there is no procedural assignment to a net
//! neighbour lvalue_forms.v
module b_9_2_procedural_to_net_rejected;
  wire w;
  initial w = 1'b1;
endmodule
