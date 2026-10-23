// IEEE 1364-2005 §14.2.5, p. 219: "In a parallel connection, each bit in the
// source shall connect to one corresponding bit in the destination. Parallel
// module paths can be created only between sources and destinations that
// contain the same number of bits."
//
// (in1 => nib) connects the 8-bit in1 to the 4-bit nib in parallel. Legal
// neighbour: full_parallel_paths.v's (in1 *> nib), the same pair
// under the full connection the clause requires.
//! inherited IEEE 1364-2005 14.2.5
//! reject same number of bits
//! neighbour full_parallel_paths.v
`timescale 1ns/1ns
module b_14_2_5_parallel_width_mismatch_rejected(in1, nib);
  input [7:0] in1;
  output [3:0] nib;
  assign nib = in1[7:4];
  specify
    (in1 => nib) = 2;
  endspecify
endmodule
