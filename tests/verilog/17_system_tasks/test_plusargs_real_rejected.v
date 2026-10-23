// IEEE 1364-2005 §17.10.1, p. 320: "The string is specified in the argument
// to the system function as either a string or a nonreal variable that is
// interpreted as a string."
//
// q is a real variable: neither a string nor a nonreal variable. Legal
// neighbour: plusargs_variable_query.v queries with a reg.
//! inherited IEEE 1364-2005 17.10.1
//! reject E1100
//! reject nonreal
//! neighbour plusargs_variable_query.v
`timescale 1 ns / 1 ns
module b_17_10_1_test_plusargs_real_rejected;
  real q;
  integer r;
  initial begin
    q = 1.0;
    r = $test$plusargs(q);
    $display("%0d", r);
  end
endmodule
