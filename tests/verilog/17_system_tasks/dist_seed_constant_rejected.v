// IEEE 1364-2005 §17.9.2, p. 312:
//   dist_functions ::= $dist_uniform ( seed , start , end ) | ...
// "For each system function, the seed argument is an inout argument; that
// is, a value is passed to the function, and a different value is returned."
//
// The seed here is the constant 5, which cannot receive the returned value.
// Legal neighbour: same_seed_same_value.v passes an integer variable.
//! inherited IEEE 1364-2005 17.9.2
//! reject E1100
//! reject the seed argument shall be a reg, integer or time variable
//! neighbour same_seed_same_value.v
`timescale 1 ns / 1 ns
module b_17_9_2_dist_seed_constant_rejected;
  integer r;
  initial r = $dist_uniform(5, 0, 10);
endmodule
