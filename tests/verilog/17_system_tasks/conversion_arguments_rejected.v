// IEEE 1364-2005 §17.8, p. 310: "The following functions handle real values:
//   integer $rtoi(real_val) ;  real $itor(int_val) ;
//   [63:0] $realtobits(real_val) ;  real $bitstoreal(bit_val) ;"
// Each takes exactly one value to convert.
//
// $rtoi(1.5, 2.5) passes two. Legal neighbour: conversions.v's
// $rtoi(123.45).
//! inherited IEEE 1364-2005 17.8
//! reject E1100
//! reject a §17.8 conversion takes exactly one argument
//! neighbour conversions.v
`timescale 1 ns / 1 ns
module b_17_8_conversion_arguments_rejected;
  integer i;
  initial i = $rtoi(1.5, 2.5);
endmodule
