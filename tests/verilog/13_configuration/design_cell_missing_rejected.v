// IEEE 1364-2005 §13.4.4, p. 206: "In the case where the config includes a
// design statement, then the specified cell shall be the top-level module,
// regardless of the presence of any uninstantiated cells in the rest of the
// source files." §13.1, p. 199: the source descriptions "shall be located,
// and so on until every instance in the design is mapped to a source
// description."
//
// design names work.missing, which the source does not declare, so there is
// no cell to be the top-level module; the uninstantiated top does not stand
// in for it. Legal neighbour: 13_configuration/config_design_select.v.
//! inherited IEEE 1364-2005 13.4.4 13.3.1.1
//! reject E1100
//! reject undeclared module in instantiation
//! neighbour config_design_select.v
config cfg;
  design work.missing;
endconfig
module top;
  initial $display("top");
endmodule
