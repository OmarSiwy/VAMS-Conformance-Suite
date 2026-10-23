// IEEE 1364-2005 §14.3, p. 222: "The delay values shall be constant
// expressions containing literals or specparams, and there may be a delay
// expression of the form min:typ:max."
//
// (a => q) = r takes its delay from r, a reg variable. Legal neighbour:
// path_delay_values.v, whose delays are literals and specparams.
//! inherited IEEE 1364-2005 14.3
//! reject constant
//! neighbour path_delay_values.v
`timescale 1ns/1ns
module b_14_3_variable_delay_rejected(a, q);
  input a;
  output q;
  reg [3:0] r;
  assign q = a;
  initial r = 4'd3;
  specify
    (a => q) = r;
  endspecify
endmodule
