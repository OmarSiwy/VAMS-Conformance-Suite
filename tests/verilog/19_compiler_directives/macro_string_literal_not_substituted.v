//! inherited IEEE 1364-2005 3.6 19.3.1
// A string literal is one token, so the x inside "Hello, x" is not a formal
// reference and is not substituted (22.5.1--define-expansion_24).
`define MSG(x) "Hello, x"
module triage_macro_string_literal_not_substituted;
  initial $display(`MSG(world));
endmodule
