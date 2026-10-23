// IEEE 1364-2005 §17.10.2, p. 321, the clause heading: "$value$plusargs
// (user_string, variable)". "If the prefix of one of the supplied plusargs
// matches all characters in the provided string, the function returns a
// nonzero integer, the remainder of the string is converted to the type
// specified in the user_string, and the resulting value is stored in the
// variable provided."
//
// The call passes the user_string alone, with no variable to store into.
// Legal neighbour: value_plusargs_absent.v passes both.
//! inherited IEEE 1364-2005 17.10.2
//! reject E1100
//! reject $value$plusargs (format, variable)
//! neighbour value_plusargs_absent.v
`timescale 1 ns / 1 ns
module b_17_10_2_value_plusargs_arguments_rejected;
  integer r;
  initial r = $value$plusargs("N=%d");
endmodule
