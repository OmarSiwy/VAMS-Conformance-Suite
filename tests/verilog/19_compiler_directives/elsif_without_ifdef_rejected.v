// IEEE 1364-2005 §19.4, p. 353: "If the `elsif directive exists (instead of
// the `else), the compiler checks for the definition of the text_macro_name.
// ... This directive shall be preceded by an `ifdef or `ifndef directive."
//
// The `elsif below opens the file: no `ifdef or `ifndef precedes it. Legal
// neighbour: conditional_compilation.v, whose every `elsif follows an
// `ifdef or `ifndef.
//! inherited IEEE 1364-2005 19.4
//! reject E0105
//! reject `elsif without `ifdef
//! neighbour conditional_compilation.v
`elsif some_macro
module b_19_4_elsif_without_ifdef_rejected;
  initial $display("accepted");
endmodule
`endif
