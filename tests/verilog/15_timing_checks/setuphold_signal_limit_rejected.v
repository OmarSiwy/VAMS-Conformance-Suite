// IEEE 1364-2005 §15.2.3, Table 15-3 (p. 243): $setuphold's setup_limit and
// hold_limit are each a "Constant expression"; §15.1: "timing check limit
// values are constant expressions that can include specparams".
//
// $setuphold(posedge clk, d, lim, 2, ntfr) reads the reg `lim` as its setup
// limit. Legal neighbour: setuphold.v, the limits 4 and 2.
//! inherited IEEE 1364-2005 15.2.3
//! reject-only E1148
//! neighbour setuphold.v
`timescale 1ns/1ns
module b_15_2_3_setuphold_signal_limit_rejected(clk, d);
  input clk, d;
  reg ntfr;
  reg [3:0] lim;
  specify
    $setuphold(posedge clk, d, lim, 2, ntfr);
  endspecify
endmodule
