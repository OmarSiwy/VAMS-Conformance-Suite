// IEEE 1364-2005 §8.5, p. 112: "Delays are not permitted in a UDP initial
// statement."
// Syntax 8-1, p. 106: "udp_initial_statement ::= initial
// output_port_identifier = init_val ;"
//
// The initial statement carries #1. Legal neighbour:
// initial_values.v, the same statement without a delay.
//! inherited IEEE 1364-2005 8.5
//! reject E0208
//! reject found `#`
//! neighbour initial_values.v
`timescale 1ns/1ns
primitive delayed_init(q, g, d);
  output q;
  reg q;
  input g, d;
  initial #1 q = 1;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module b_8_5_initial_delay_rejected;
  initial $finish(0);
endmodule
