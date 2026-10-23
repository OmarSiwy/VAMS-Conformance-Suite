// IEEE 1364-2005 §13.2.2, p. 202: "The syntax of a lib.map file is limited to
// library specifications, include statements, and standard Verilog comment
// syntax." Against it, A.1.1 / Syntax 13-2 derive `library_description ::=
// ... | config_declaration`. The prose is the specific statement about map
// files; the grammar box also serves library_text in general, and §13.3
// places configs in source text (Vague_Decisions VD-039).
//
// libmap/bad/config_in_map.map declares a library and then a config. Legal
// neighbours: include_map.v (a map of an include statement and a
// comment) and config_design_select.v (the same config in source text).
//@ libmap libmap/bad/config_in_map.map
//! inherited IEEE 1364-2005 13.2.2
//! reject E0244
//! reject found `config`
//! neighbour config_design_select.v
//! neighbour include_map.v
module top;
endmodule
