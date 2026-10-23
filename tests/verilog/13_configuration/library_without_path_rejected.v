// IEEE 1364-2005 §13.2.1, p. 201, Syntax 13-2: "library_declaration ::=
// library library_identifier file_path_spec [ { , file_path_spec } ] [ -incdir
// file_path_spec { , file_path_spec } ] ;" (the braces of the first optional
// list are the clause's). One file_path_spec is required.
//
// libmap/bad/no_spec.map writes `library lib1;`. Legal neighbour:
// default_search_order.v, whose ex13_5/lib.map gives each library
// one specification.
//@ libmap libmap/bad/no_spec.map
//! inherited IEEE 1364-2005 13.2.1
//! reject E0244
//! reject needs a file_path_spec
//! neighbour default_search_order.v
module top;
endmodule
