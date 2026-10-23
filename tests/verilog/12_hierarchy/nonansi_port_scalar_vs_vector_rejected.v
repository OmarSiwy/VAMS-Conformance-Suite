//! inherited IEEE 1364-2005 12.3.3
//! reject-only differs from its port declaration's
// A scalar port redeclared as a vector has a different range
// (module_nonansi_vec_fail2), the §12.3.3 range-identity check. VerA compares
// net declarations only, so it accepts the variable; the fixture is expected
// to FAIL, verifying the vera-bug claim.
module triage_nonansi_port_scalar_vs_vector_rejected(x);
  output x;
  reg [7:0] x;
endmodule
