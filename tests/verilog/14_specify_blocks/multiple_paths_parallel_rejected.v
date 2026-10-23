// IEEE 1364-2005 §14.2.6, p. 220: "Multiple module paths may be described in
// a single statement by using the symbol *> to connect a comma-separated list
// of sources to a comma-separated list of destinations." ... "The connection
// in a multiple module path declaration is always a full connection."
//
// (a, b, c => q1, q2) joins the two lists with =>. Legal neighbour:
// module_paths.v's (a, b, c *> q1, q2) = 10, the clause's example.
//! inherited IEEE 1364-2005 14.2.6
//! reject E0207
//! reject a parallel path
//! neighbour module_paths.v
`timescale 1ns/1ns
module b_14_2_6_multiple_paths_parallel_rejected(a, b, c, q1, q2);
  input a, b, c;
  output q1, q2;
  assign q1 = a & b & c;
  assign q2 = a | b | c;
  specify
    (a, b, c => q1, q2) = 10;
  endspecify
endmodule
