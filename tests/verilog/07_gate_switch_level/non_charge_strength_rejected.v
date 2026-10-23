// IEEE 1364-2005 §7.13.2, p. 100: "The strength of the drive resulting from a
// trireg net that is in the charge storage state ... shall be one of these
// three strengths: large, medium, or small. The specific strength associated
// with a particular trireg net shall be specified by the user in the net
// declaration." A.2.2.2: charge_strength ::= ( small ) | ( medium ) | ( large ).
//
// (strong) names a driving strength, not a charge strength. Legal neighbour:
// trireg (large) / (small) / (medium) in charge_strength_sharing.v.
//! inherited IEEE 1364-2005 7.13.2
//! reject E0207
//! reject which is not a charge strength
//! neighbour charge_strength_sharing.v
module b_7_13_2_non_charge_strength_rejected;
  trireg (strong) t;
  initial $finish(0);
endmodule
