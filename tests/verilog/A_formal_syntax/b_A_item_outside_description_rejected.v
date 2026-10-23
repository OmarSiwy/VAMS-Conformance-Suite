// IEEE 1364-2005 Annex A, p. 487: "The syntax of Verilog HDL source is derived
// from the starting symbol source_text." A.1.2, p. 487:
//   source_text ::= { description }
//   description ::= module_declaration | udp_declaration | config_declaration
//
// A net declaration before any module is none of the three descriptions, so
// the file derives no source_text. Legal neighbour: b_A_source_text.v, whose
// declarations all sit inside a module_declaration.
//! inherited IEEE 1364-2005 A
//! reject E0201
//! reject `wire`
//! neighbour b_A_source_text.v
wire stray;
module b_A_item_outside_description_rejected;
  initial $display("unreachable");
endmodule
