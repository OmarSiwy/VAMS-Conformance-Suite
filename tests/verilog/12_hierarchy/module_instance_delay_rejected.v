//! inherited IEEE 1364-2005 A.4.1
//! reject module instance
//! reject delay
// A.4.1.1's parameter_value_assignment is #( ... ); `sub #1 u(w)` is the
// UDP/gate delay form and is illegal on a module instance (pr3194155). The
// connection is a net lvalue so the UDP-shaped parse has a terminal to read;
// VerA then resolves `sub` as a module and accepts the delay. The fixture is
// expected to FAIL, verifying that the rule is not implemented. Upstream's
// refusal of the same construct comes from its constant port (`1'b0`), which
// the UDP output-terminal grammar rejects, not from A.4.1.1.
module triage_module_instance_delay_rejected;
  wire w;
  sub #1 u(w);
endmodule

module sub(input x);
endmodule
