// IEEE 1364-2005 §13.3.1.4, p. 204: "The cell selection clause names the cell
// to which it applies." Syntax 13-4 (§13.3.1, p. 203) admits a cell_clause
// only as "cell_clause liblist_clause ;" or "cell_clause use_clause ;".
//
// `cell leaf;` has no expansion clause. Legal neighbour:
// 13_configuration/config_cell_liblist.v.
//! inherited IEEE 1364-2005 13.3.1.4
//! reject E0207
//! reject a cell pairs with `liblist` or `use`
//! neighbour config_cell_liblist.v
config cfg;
  design work.top;
  cell leaf;
endconfig
module leaf;
  initial $display("leaf");
endmodule
module top;
  leaf u();
endmodule
