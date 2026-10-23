// IEEE 1364-2005 §17.10.1, p. 320: "The $test$plusarg system function
// searches the list of plusargs for a user specified plusarg_string. The
// string is specified in the argument to the system function as either a
// string or a nonreal variable that is interpreted as a string." The clause
// heading is $test$plusargs (string): one argument.
//
// The call passes none, so there is no string to search for. It is written
// without parentheses: A.8.2's system_function_call has no empty argument
// list, so `$test$plusargs()` would also be a syntax error. Legal
// neighbour: plusargs_variable_query.v passes one.
//! inherited IEEE 1364-2005 17.10.1
//! reject E1100
//! reject $test$plusargs takes (string)
//! neighbour plusargs_variable_query.v
`timescale 1 ns / 1 ns
module b_17_10_1_test_plusargs_arguments_rejected;
  integer r;
  initial r = $test$plusargs;
endmodule
