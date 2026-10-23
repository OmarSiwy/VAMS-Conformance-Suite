// IEEE 1364-2005 §13.3.1, p. 203, Syntax 13-4: "config_declaration ::=
// config config_identifier ; design_statement {config_rule_statement}
// endconfig".
//
// The configuration below is never closed: the file ends before `endconfig`,
// so the text derives no config_declaration. Legal neighbour:
// every_rule_form.v.
//! inherited IEEE 1364-2005 13.3.1
//! reject E0207
//! reject no `endconfig` closes the configuration
//! neighbour every_rule_form.v
module top;
  initial $display("top");
endmodule
config cfg;
  design work.top;
  default liblist work;
