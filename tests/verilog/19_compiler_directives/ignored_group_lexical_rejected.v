// IEEE 1364-2005 §19.4, p. 354: "Any group of lines that the compiler ignores
// shall still follow the Verilog HDL lexical conventions for white space,
// comments, numbers, strings, identifiers, keywords, and operators." §3.6,
// p. 12: "A string is a sequence of characters enclosed by double quotes
// ("") and contained on a single line."
//
// never_defined is not defined, so the `ifdef group is ignored; its one line
// opens a string that the line does not close, which breaks the string
// convention. Legal neighbour: conditional_compilation.v, whose
// ignored groups are all lexically well formed.
//! inherited IEEE 1364-2005 19.4
//! reject E0138
//! reject a string literal may not span lines
//! neighbour conditional_compilation.v
`ifdef never_defined
  initial $display("unterminated);
`endif
module b_19_4_ignored_group_lexical_rejected;
  initial $display("accepted");
endmodule
