//! inherited IEEE 1364-2005 12.3.3
//! reject-only differs from its port declaration's
// A port and its redeclaration must have identical ranges:
// output [3:0] x; reg [7:0] x; (module_nonansi_vec_fail1), the §12.3.3
// range-identity check. VerA compares net declarations only, so it accepts the
// variable; the fixture is expected to FAIL, verifying the vera-bug claim.
module triage_nonansi_port_reg_range_mismatch_rejected(x);
  output [3:0] x;
  reg [7:0] x;
endmodule
