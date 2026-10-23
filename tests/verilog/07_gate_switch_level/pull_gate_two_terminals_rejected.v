//! inherited IEEE 1364-2005 A.3.1
//! reject unexpected token: found `,`
// A.3.1's pull_gate_instance has exactly one output_terminal; pulldown(a, b)
// is illegal (pr1787423).
module triage_pull_gate_two_terminals_rejected;
  wire a, b;

  pulldown (a, b);
endmodule
