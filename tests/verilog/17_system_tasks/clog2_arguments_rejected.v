// IEEE 1364-2005 §17.11.1, p. 323: "The system function $clog2 shall return
// the ceiling of the log base 2 of the argument (the log rounded up to an
// integer value). The argument can be an integer or an arbitrary sized vector
// value." One argument; the example is "result = $clog2(n);".
//
// $clog2(4, 2) passes two. Legal neighbour: clog2.v.
//! inherited IEEE 1364-2005 17.11.1
//! reject E1100
//! reject $clog2 takes exactly one argument
//! neighbour clog2.v
`timescale 1 ns / 1 ns
module b_17_11_1_clog2_arguments_rejected;
  integer r;
  initial r = $clog2(4, 2);
endmodule
