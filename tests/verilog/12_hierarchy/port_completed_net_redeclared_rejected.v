//! inherited IEEE 1364-2005 12.3.3 4.11
//! reject-only duplicate digital variable
// The first wire x completes the port; the second declares x again
// (module_nonansi_fail2), which the engine's duplicate-binding check owns.
// VerA accepts the duplicate silently; the fixture is expected to FAIL,
// verifying the vera-bug claim.
module triage_port_completed_net_redeclared_rejected(x);
  input x;
  wire x;
  wire x;
endmodule
