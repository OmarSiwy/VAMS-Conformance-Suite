// IEEE 1364-2005 §15.2.6, Table 15-6 (p. 247): $recrem's recovery_limit and
// removal_limit are each a "Constant expression"; §15.1: "timing check limit
// values are constant expressions that can include specparams".
//
// $recrem(posedge clr, posedge clk, 3, lim, ntfr) reads the reg `lim` as its
// removal limit. Legal neighbour: recrem.v, the limits 3 and 2.
//! inherited IEEE 1364-2005 15.2.6
//! reject-only E1148
//! neighbour recrem.v
`timescale 1ns/1ns
module b_15_2_6_recrem_signal_limit_rejected(clr, clk);
  input clr, clk;
  reg ntfr;
  reg [3:0] lim;
  specify
    $recrem(posedge clr, posedge clk, 3, lim, ntfr);
  endspecify
endmodule
