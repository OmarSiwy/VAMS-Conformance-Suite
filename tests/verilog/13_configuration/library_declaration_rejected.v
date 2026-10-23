// IEEE 1364-2005 §13.2.1, p. 200: "When parsing a source description file (or
// files), the parser shall first read the library mapping information from a
// predefined file prior to reading any source files." Annex A, p. 487: "The
// syntax of Verilog HDL source is derived from the starting symbol
// source_text. The syntax of a library map file is derived from the starting
// symbol library_text." A.1.1 derives library_declaration from library_text
// alone; A.1.2's description is module_declaration | udp_declaration |
// config_declaration.
//
// A library_declaration in a source file is map text where only source text
// derives: the production it breaks is A.1.2's source_text, so that is the
// cite. §13.2.1 is quoted for context and not cited: its obligation is a
// mechanism to name library map files, which VerA does not have, and this
// refusal is not evidence for it. Legal neighbour: 13_configuration/config_binding_display.v,
// source text with no map, whose cells land in work.
//! inherited IEEE 1364-2005 A.1.2
//! reject E0232
//! reject `library` is a library_description
//! neighbour config_binding_display.v
library rtlLib "*.v";
module top;
  initial $display("top");
endmodule
