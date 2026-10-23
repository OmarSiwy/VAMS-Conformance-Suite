// IEEE 1364-2005 §15.2.2, Table 15-2 (p. 242): $hold's limit is a
// "Non-negative constant expression".
//
// $hold(posedge clk, d, -2, ntfr) gives $hold a limit of -2. Legal
// neighbour: hold.v, the same check with the limit 3.
//! inherited IEEE 1364-2005 15.2.2
//! reject-only E1148
//! neighbour hold.v
`timescale 1ns/1ns
module b_15_2_2_hold_negative_limit_rejected(clk, d);
  input clk, d;
  reg ntfr;
  specify
    $hold(posedge clk, d, -2, ntfr);
  endspecify
endmodule
