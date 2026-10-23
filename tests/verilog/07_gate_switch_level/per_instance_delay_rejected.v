// IEEE 1364-2005 §7.1, p. 74: "Multiple instances of the one type of gate or
// switch primitive can be declared as a comma-separated list. All such
// instances shall have the same drive strength and delay specification."
// Syntax 7-1 places [delay2] once, after the gate type, before the first
// instance; n_input_gate_instance has no delay of its own.
//
// Here the second instance of the list carries its own #2. Legal neighbour:
// instance_list_shared_spec.v (one delay for the whole list).
//! inherited IEEE 1364-2005 7.1
//! reject E0207
//! reject unexpected token: found `#`
//! neighbour instance_list_shared_spec.v
module b_7_1_per_instance_delay_rejected;
  reg a, b;
  wire o1, o2;
  and #1 g1(o1, a, b), #2 g2(o2, a, b);
  initial $finish(0);
endmodule
