// IEEE 1364-2005 §15.3.5 (p. 257): "Because of the way the data event is
// derived for $period, an edge triggered event shall be passed as the
// reference event. A compilation error shall occur if the reference event is
// not an edge specification." A.7.5.1 opens $period with a
// controlled_reference_event, whose timing_check_event_control A.7.5.3 does
// not bracket.
//
// $period(clk, 10, ntfr) names clk with no edge. Legal neighbour:
// period.v's $period(posedge clk, 10, ntfr).
//! inherited IEEE 1364-2005 15.3.5
//! reject E0207
//! reject requires an event control
//! neighbour period.v
`timescale 1ns/1ns
module b_15_3_5_period_without_edge_rejected(clk);
  input clk;
  reg ntfr;
  specify
    $period(clk, 10, ntfr);
  endspecify
endmodule
