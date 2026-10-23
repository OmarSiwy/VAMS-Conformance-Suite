// IEEE 1364-2005 §12.2, p. 168: "There are two ways to alter nonlocal parameter
// values: the defparam statement ... and the module instance parameter value
// assignment". The clause's generic_fifo (p. 167): "localparam FIFO_MSB =
// DEPTH*MSB; ... // These parameters are local, and cannot be overridden."
// §12.2.2.1, p. 171: "Local parameters cannot be overridden". The rule's own
// clause, §4.10.2, p. 37: "Verilog HDL local parameters are identical to
// parameters except that they cannot directly be modified by defparam
// statements (see 12.2.1) or module instance parameter value assignments (see
// 12.2.2)."
//
// The defparam targets leaf's localparam LP. Legal neighbour:
// defparam_last_wins.v (defparams of parameters).
//! inherited IEEE 1364-2005 12.2 4.10.2
//! reject E1100
//! reject local parameter
//! neighbour defparam_last_wins.v
module leaf;
  localparam LP = 1;
  initial $display("%0d", LP);
endmodule
module b_12_2_localparam_override_rejected;
  leaf u();
  defparam u.LP = 5;
endmodule
