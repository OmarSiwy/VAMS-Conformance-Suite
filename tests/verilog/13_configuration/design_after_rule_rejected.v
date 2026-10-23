// IEEE 1364-2005 §13.3.1.1, p. 202: "The design statement shall appear before
// any config rule statements in the config."
//
// cfg puts a default rule first. Legal neighbour:
// 13_configuration/config_default_liblist.v, the same two statements in
// the required order.
//! inherited IEEE 1364-2005 13.3.1.1
//! reject E0207
//! reject a config_declaration begins with its `design` statement
//! neighbour config_default_liblist.v
config cfg;
  default liblist work;
  design work.top;
endconfig
module top;
  initial $display("top");
endmodule
