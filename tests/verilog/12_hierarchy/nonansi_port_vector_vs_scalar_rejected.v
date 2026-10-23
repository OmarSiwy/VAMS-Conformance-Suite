//! inherited IEEE 1364-2005 12.3.3
//! reject-only differs from its port declaration's
// A vector port redeclared as a scalar has a different range
// (module_nonansi_vec_fail3), the §12.3.3 range-identity check. VerA compares
// net declarations only, so it accepts the variable; the fixture is expected
// to FAIL, verifying the vera-bug claim.
module triage_nonansi_port_vector_vs_scalar_rejected(x);
  output [7:0] x;
  reg x;
endmodule
