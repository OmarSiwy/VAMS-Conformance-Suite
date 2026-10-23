// IEEE 1364-2005 §17.11.1, p. 323: "The system function $clog2 shall return
// the ceiling of the log base 2 of the argument (the log rounded up to an
// integer value). The argument can be an integer or an arbitrary sized vector
// value."
//
// 2.5 is a real, neither an integer nor a vector. Legal neighbour:
// clog2.v.
//! inherited IEEE 1364-2005 17.11.1
//! reject E1100
//! reject not a real
//! neighbour clog2.v
`timescale 1 ns / 1 ns
module b_17_11_1_clog2_real_rejected;
  integer r;
  initial r = $clog2(2.5);
endmodule
