// IEEE1364-2005 §6.1.4 explicitly forbids the pair(highz1,highz0).
// Intended diagnostic contract; unrelated unsupported-feature errors cannot
// establish enforcement of this isolated strength-pair restriction.
//! inherited IEEE 1364-2005 6.1.4
//! reject both drive strengths cannot be high impedance
module audit_assignment_highz_pair_rejected;
  wire y;
  assign (highz1, highz0) y = 1'b0;
endmodule
