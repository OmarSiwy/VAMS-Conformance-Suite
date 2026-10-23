// IEEE 1364-2005 §19.11, p. 365: "The next example is the same code as the
// previous example, except that it explicitly specifies that the IEEE Std
// 1364-2005 Verilog keywords should be used. This example shall result in an
// error because uwire is reserved as a keyword in this standard."
//     `begin_keywords "1364-2005"
//     module m2 (...);
//       wire [63:0] uwire; // ERROR: "uwire" is a keyword in 1364-2005
//
// That example with an empty port list. Legal neighbour:
// keyword_versions.v declares the same net under "1364-2001".
//! inherited IEEE 1364-2005 19.11
//! reject E0208
//! reject expected an identifier: found `uwire`
//! neighbour keyword_versions.v
`begin_keywords "1364-2005"
module b_19_11_uwire_in_2005_rejected;
  wire [63:0] uwire;
endmodule
`end_keywords
