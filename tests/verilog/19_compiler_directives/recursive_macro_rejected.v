// IEEE 1364-2005 §19.3.1, p. 352: "The macro text can contain usages of other
// text macros. Such usages shall be substituted after the original macro is
// substituted, not when it is defined. It shall be an error for a macro to
// expand directly or indirectly to text containing another usage of itself (a
// recursive macro)."
//
// `ping expands to text using `pong, whose text uses `ping again: `ping is
// indirectly recursive. Legal neighbour: text_macros.v, where `outer
// uses `inner and `inner uses nothing.
//! inherited IEEE 1364-2005 19.3.1
//! reject E0118
//! reject recursive macro expansion
//! neighbour text_macros.v
`define ping (1 + `pong)
`define pong (2 + `ping)
module b_19_3_1_recursive_macro_rejected;
  initial $display("%0d", `ping);
endmodule
