//! inherited IEEE 1364-2005 19.2
// `default_nettype trireg is legal: the implicit net below is a trireg and
// carries its continuous driver's value.
`default_nettype trireg
module triage_default_nettype_trireg;
  assign treg_net = 1'b1;

  initial #1 if (treg_net === 1'b1) $display("PASSED"); else $display("FAILED %b", treg_net);
endmodule
