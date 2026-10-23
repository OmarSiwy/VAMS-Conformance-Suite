// IEEE 1364-2005 §19, p. 349: "The scope of a compiler directive extends from
// the point where it is processed, across all files processed, to the point
// where another compiler directive supersedes it or the processing
// completes." §19.3.1, p. 350: "After a text macro is defined, it can be used
// in the source description by using the (`) character, followed by the
// macro name."
//
// `late is used on the line before its `define is processed, so at the use
// it names no macro. Legal neighbour: text_macros.v defines every
// macro before its first use.
//! inherited IEEE 1364-2005 19 19.3.1
//! reject E0115
//! reject undefined macro
//! neighbour text_macros.v
module b_19_use_before_define_rejected;
  initial $display("%0d", `late);
endmodule
`define late 3
