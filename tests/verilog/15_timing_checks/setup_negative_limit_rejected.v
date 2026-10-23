// IEEE 1364-2005 §15.2.1, Table 15-1 (p. 241): $setup's limit is a
// "Non-negative constant expression". §15.8 lets only $setuphold and $recrem
// take negative values.
//
// $setup(d, posedge clk, -1, ntfr) gives $setup a limit of -1. Legal
// neighbour: setup.v, the same check with the limit 5.
//! inherited IEEE 1364-2005 15.2.1
//! reject-only E1148
//! neighbour setup.v
`timescale 1ns/1ns
module b_15_2_1_setup_negative_limit_rejected(clk, d);
  input clk, d;
  reg ntfr;
  specify
    $setup(d, posedge clk, -1, ntfr);
  endspecify
endmodule
