// IEEE 1364-2005 §13.3.1.1, p. 202: "There shall be one and only one design
// statement, but multiple top-level modules can be listed in the design
// statement."
//
// cfg carries two design statements. Legal neighbour:
// multiple_top_cells.v lists two cells in ONE statement.
//! inherited IEEE 1364-2005 13.3.1.1
//! reject E0207
//! reject begins no A.1.5 config_rule_statement
//! neighbour multiple_top_cells.v
config cfg;
  design work.top;
  design work.top;
endconfig
module top;
  initial $display("top");
endmodule
