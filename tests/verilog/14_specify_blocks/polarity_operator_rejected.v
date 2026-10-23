// IEEE 1364-2005 §14.2.7, p. 220: "Module paths may specify any of three
// polarities: — Unknown polarity — Positive polarity — Negative polarity"
// and Syntax 14-3 (p. 213): polarity_operator ::= + | -
//
// (In1 ~=> q) writes ~ where a polarity operator goes. Legal neighbour:
// polarity.v, with no operator, + and -.
//! inherited IEEE 1364-2005 14.2.7
//! reject E0207
//! reject `=>` or `*>`
//! neighbour polarity.v
`timescale 1ns/1ns
module b_14_2_7_polarity_operator_rejected(In1, q);
  input In1;
  output q;
  assign q = ~In1;
  specify
    (In1 ~=> q) = 3;
  endspecify
endmodule
