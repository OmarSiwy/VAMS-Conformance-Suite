// IEEE 1364-2005 §19.3.1, p. 351: "To use a macro defined with arguments, the
// name of the text macro shall be followed by a list of actual arguments in
// parentheses, separated by commas. White space shall be allowed between the
// text macro name and the left parenthesis. The number of actual arguments
// shall match the number of formal arguments."
//
// `add has two formal arguments (a, b); `add(1) supplies one. Legal
// neighbour: text_macros.v calls the two-argument `max with two.
//! inherited IEEE 1364-2005 19.3.1
//! reject E0117
//! reject macro argument count mismatch
//! neighbour text_macros.v
`define add(a,b) ((a)+(b))
module b_19_3_1_argument_count_rejected;
  initial $display("%0d", `add(1));
endmodule
