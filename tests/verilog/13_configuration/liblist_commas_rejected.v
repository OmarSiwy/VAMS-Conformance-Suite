// IEEE 1364-2005 §13.3.1.5, p. 204: "liblist_clause ::= liblist {
// library_identifier }" (Syntax 13-8).
//
// The library names in a liblist are separated by white space alone; the
// comma below is derivable from no production. Legal neighbour:
// empty_liblist_parent_library.v and
// 13_configuration/config_default_liblist.v.
//! inherited IEEE 1364-2005 13.3.1.5
//! reject E0208
//! reject expected an identifier: found `,`
//! neighbour config_default_liblist.v
//! neighbour empty_liblist_parent_library.v
config cfg;
  design work.top;
  default liblist work, work;
endconfig
module top;
  initial $display("top");
endmodule
