// IEEE 1364-2005 §17.11.2, pp. 323-324: "The system functions in Table 17-18
// shall accept real arguments and return a real result. Their behavior shall
// match the equivalent C language standard math library function indicated."
// Table 17-18 lists $sqrt(x) (C sqrt(x), one argument) and $pow(x,y) (C
// pow(x,y), two).
//
// $sqrt(1.0, 2.0) passes two arguments to a one-argument function. Legal
// neighbour: ieee_math_real_result.v.
//! inherited IEEE 1364-2005 17.11.2
//! reject E1100
//! reject wrong number of arguments to a §17.11.2 math function
//! neighbour ieee_math_real_result.v
`timescale 1 ns / 1 ns
module b_17_11_2_math_arguments_rejected;
  real r;
  initial r = $sqrt(1.0, 2.0);
endmodule
