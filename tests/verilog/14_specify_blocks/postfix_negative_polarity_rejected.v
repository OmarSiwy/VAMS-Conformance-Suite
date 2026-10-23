// IEEE 1364-2005 §14.2.7.3, p. 221: "A module path with negative polarity
// shall be specified by prefixing the - polarity operator to => or *>."
// Syntax 14-3 (p. 213) puts the operator before the arrow:
//   ( list_of_path_inputs [ polarity_operator ] *> list_of_path_outputs )
//
// (s *>- q) writes - after the arrow, where the destination belongs. Legal
// neighbour: polarity.v's (s -*> qn).
//! inherited IEEE 1364-2005 14.2.7.3
//! reject E0208
//! reject expected an identifier: found `-`
//! neighbour polarity.v
`timescale 1ns/1ns
module b_14_2_7_3_postfix_negative_polarity_rejected(s, q);
  input s;
  output q;
  assign q = ~s;
  specify
    (s *>- q) = 4;
  endspecify
endmodule
