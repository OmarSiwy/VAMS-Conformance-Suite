// IEEE 1364-2005 §13.3.1.4, p. 204: "If the optional library name is
// specified, then the selection rule applies to any instance that is bound or
// is under consideration for being bound to the selected library and cell. It
// is an error if a library name is included in a cell selection clause and
// the corresponding expansion clause is a library list expansion clause."
//
// `cell work.top liblist work;` names library work in the cell clause and
// pairs it with a liblist. Legal neighbour:
// 13_configuration/config_cell_liblist.v, the unqualified
// `cell config_host liblist work;`.
//! inherited IEEE 1364-2005 13.3.1.4
//! reject library name
//! reject E0243
//! neighbour config_cell_liblist.v
config cfg;
  design work.top;
  cell work.top liblist work;
endconfig
module top;
  initial $display("top");
endmodule
