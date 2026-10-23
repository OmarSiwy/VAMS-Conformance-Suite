// IEEE 1364-2005 §13.3.1.1, p. 202: "The cell or cells identified cannot be
// configurations themselves. It is possible the design identified can have
// the same name as configs, however."
//
// cfg's design statement names work.cfg, and the only cell called cfg is the
// configuration itself; no module or primitive has that name. Legal
// neighbour: config_named_like_module.v, where the named cell is a
// module that shares a config's name. VerA refuses the cell as an undeclared
// module, which is this rule's outcome: no module is bound.
//! inherited IEEE 1364-2005 13.3.1.1
//! reject E1100
//! reject undeclared module in instantiation
//! neighbour config_named_like_module.v
config cfg;
  design work.cfg;
endconfig
module top;
  initial $display("top");
endmodule
