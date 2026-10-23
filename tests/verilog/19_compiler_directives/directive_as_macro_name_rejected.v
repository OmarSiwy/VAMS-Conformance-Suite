// IEEE 1364-2005 §19.3.1, p. 350: "All compiler directives shall be
// considered predefined macro names; it shall be illegal to redefine a
// compiler directive as a macro name."
//
// `include is a compiler directive (§19.5), so `define include makes a macro
// of a directive name. Legal neighbour: text_macros.v defines nine
// macros whose names are not directives.
//! inherited IEEE 1364-2005 19.3.1
//! reject E0143
//! reject a compiler directive cannot be a macro name
//! neighbour text_macros.v
`define include 1
module b_19_3_1_directive_as_macro_name_rejected;
  initial $display("accepted");
endmodule
