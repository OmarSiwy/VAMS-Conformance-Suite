// IEEE 1364-2005 §19.2, p. 349: "When the `default_nettype is set to none,
// all nets shall be explicitly declared. If a net is not explicitly
// declared, an error is generated."
//
// Under `default_nettype none, n appears only in the port connection of
// instance c, which (§4.5) would otherwise declare it implicitly. Legal
// neighbour: none_all_declared.v declares its net w under the same
// directive. (VerA refuses every implicit net, implicit_net_types.v;
// the refusal is required here whatever the default.)
//! inherited IEEE 1364-2005 19.2
//! reject E1100
//! reject undeclared digital variable
//! neighbour implicit_net_types.v
//! neighbour none_all_declared.v
`timescale 1ns/1ns
`default_nettype none
module b_19_2_child(output wire o);
  assign o = 1'b1;
endmodule
module b_19_2_none_implicit_net_rejected;
  b_19_2_child c(n);
  initial #1 $display("n=%b", n);
endmodule
`default_nettype wire
