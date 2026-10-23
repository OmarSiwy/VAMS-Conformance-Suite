// IEEE 1364-2005 §19.3.1, p. 351: "The text specified for macro text shall not
// be split across the following lexical tokens: — Comments — Numbers —
// Strings — Identifiers — Keywords — Operators" ... "The following is illegal
// syntax because it is split across a string:" and pp. 351-352 give
//     `define first_half "start of string
//     $display(`first_half end of string");
//
// That example, verbatim, inside a module. Legal neighbour:
// text_macros.v, whose macro texts hold whole tokens.
//! inherited IEEE 1364-2005 19.3.1
//! reject E0145
//! reject macro text splits a string literal
//! neighbour text_macros.v
`define first_half "start of string
module b_19_3_1_split_string_rejected;
  initial $display(`first_half end of string");
endmodule
