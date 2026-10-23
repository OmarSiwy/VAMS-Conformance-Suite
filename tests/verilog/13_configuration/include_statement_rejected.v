// IEEE 1364-2005 §13.2.2, p. 202: "In addition to specifying library mapping
// information, a lib.map file can also include references to other lib.map
// files. The include command is used to insert the entire contents of a
// library map file in another file during parsing." Syntax 13-3:
// "include_statement ::= (From A.1.1) include file_path_spec ;". Annex A,
// p. 487: "The syntax of a library map file is derived from the starting
// symbol library_text."
//
// The bare include_statement (not §19.5's `include directive) is library map
// text, derivable from library_text alone; A.1.2's source_text derives no
// include_statement, so A.1.2 is the cite. §13.2.2 is quoted for context and
// not cited: its obligation is map files including map files, which VerA does
// not read, and this refusal is not evidence for it. Legal neighbour:
// 13_configuration/config_binding_display.v.
//! inherited IEEE 1364-2005 A.1.2
//! reject E0232
//! reject `include` is a library_description
//! neighbour config_binding_display.v
include "other.map";
module top;
  initial $display("top");
endmodule
