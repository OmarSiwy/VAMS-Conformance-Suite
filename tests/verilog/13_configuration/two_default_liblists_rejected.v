// IEEE 1364-2005 §13.3.1.2, p. 203: "The default clause selects all instances
// that do not match a more specific selection clause. The use expansion clause
// (see 13.3.1.6) cannot be used with a default selection clause. For other
// expansion clauses, there cannot be more than one default clause that
// specifies the expansion clause."
//
// liblist is the only other expansion clause, and cfg gives two default
// clauses that both specify it. Legal neighbour:
// 13_configuration/config_default_liblist.v, one default liblist.
//! inherited IEEE 1364-2005 13.3.1.2
//! reject more than one default
//! reject E0243
//! neighbour config_default_liblist.v
config cfg;
  design work.top;
  default liblist work;
  default liblist work;
endconfig
module top;
  initial $display("top");
endmodule
