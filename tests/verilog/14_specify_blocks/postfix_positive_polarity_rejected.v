// IEEE 1364-2005 §14.2.7.2, p. 221: "A module path with positive polarity
// shall be specified by prefixing the + polarity operator to => or *>."
// Syntax 14-3 (p. 213) puts the operator before the arrow:
//   ( specify_input_terminal_descriptor [ polarity_operator ] =>
//     specify_output_terminal_descriptor )
//
// (In1 =>+ q) writes + after the arrow, where the destination belongs.
// Legal neighbour: polarity.v's (In1 +=> qp).
//! inherited IEEE 1364-2005 14.2.7.2
//! reject E0208
//! reject expected an identifier: found `+`
//! neighbour polarity.v
`timescale 1ns/1ns
module b_14_2_7_2_postfix_positive_polarity_rejected(In1, q);
  input In1;
  output q;
  assign q = In1;
  specify
    (In1 =>+ q) = 3;
  endspecify
endmodule
