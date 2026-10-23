// IEEE 1364-2005 §4.10.2, p. 37: "Verilog HDL local parameters are identical
// to parameters except that they cannot directly be modified by defparam
// statements (see 12.2.1) or module instance parameter value assignments
// (see 12.2.2)." The refusal is the reading this suite takes of "cannot
// directly be modified" (as 12_hierarchy/localparam_override_rejected.v
// does for a defparam).
//
// The instance names leaf's localparam L in a named parameter value
// assignment. Legal neighbour: localparam_from_parameter.v (an
// ordered assignment to the parameters only).
//! inherited IEEE 1364-2005 4.10.2
//! reject E1100
//! reject local parameter
//! neighbour localparam_from_parameter.v
module b_4_10_2_leaf;
  localparam L = 1;
  initial $display("%0d", L);
endmodule
module b_4_10_2_named_localparam_override_rejected;
  b_4_10_2_leaf #(.L(2)) u();
endmodule
