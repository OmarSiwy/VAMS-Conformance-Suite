// IEEE 1364-2005 A.1.5, p. 489:
//   config_declaration ::= config config_identifier ; design_statement
//     {config_rule_statement} endconfig
// The design_statement is not optional: it stands between the config header
// and the rules, with no brackets around it.
//
// This config opens straight into a default rule, so it derives no
// config_declaration. Legal neighbour: b_A_1_5_configuration.v.
//! inherited IEEE 1364-2005 A.1.5
//! reject E0207
//! reject begins with its `design` statement
//! neighbour b_A_1_5_configuration.v
config b_A_1_5_nodesign;
  default liblist work;
endconfig
module b_A_1_5_missing_design_rejected;
  initial $display("unreachable");
endmodule
