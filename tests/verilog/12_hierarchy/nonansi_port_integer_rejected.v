//! inherited IEEE 1364-2005 12.3.3
//! reject-only differs from its port declaration's
// output [31:0] x; integer x; gives the port a different type and range
// (module_nonansi_integer_fail), the §12.3.3 range-identity check. VerA
// compares net declarations only, so it accepts the variable; the fixture is
// expected to FAIL, verifying the vera-bug claim.
module triage_nonansi_port_integer_rejected(x);
  output [31:0] x;
  integer x;
endmodule
