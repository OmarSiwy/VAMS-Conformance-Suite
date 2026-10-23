// IEEE 1364-2005 §15.2.2, Table 15-2 (p. 242): $hold's reference_event is
// the "Timestamp event", its data_event the "Timecheck event", and
//   "(beginning of time window) = (timestamp time)
//    (end of time window) = (timestamp time) + limit
//    The $hold timing check reports a timing violation in the following case:
//    (beginning of time window) <= (timecheck time) < (end of time window)
//    Only the end of the time window is not part of the violation region.
//    When the limit is zero, the $hold check shall never issue a violation."
// So a data event at the time of the reference event violates whichever of
// the two the time step happens to process first. §15.5 Table 15-13: a
// violation takes the notifier 0 -> 1 and 1 -> 0.
//
// The cell: $hold(posedge clk, d, 3, ntfr) and $hold(posedge clk, d, 0, n0).
// Both notifiers start at 0 at t=1; `always @(ntfr)` prints ntfr's values.
//
// DERIVATION (t in ns; a reference event at T opens [T, T+3)):
//   t=0   clk x -> 0 (a negedge) and d x -> 0 (a data event, no reference
//         event yet): nothing.
//   t=1   "t=1 ntfr=0".
//   t=10  clk rises, then d rises, at once: 10 is in [10, 13): VIOLATION,
//         ntfr 0 -> 1, "t=10 ntfr=1".
//   t=20  d falls, then clk rises, at once: the same pair, written the other
//         way round: 20 is in [20, 23): VIOLATION, ntfr 1 -> 0,
//         "t=20 ntfr=0". (Against the reference at 10, 20 is outside
//         [10, 13); one data event is one violation.)
//   t=21  d rises: in [20, 23): VIOLATION, ntfr 0 -> 1, "t=21 ntfr=1".
//   t=23  d falls: 23 is [20, 23)'s open end: none.
//   t=28  n0's limit is zero, so it never toggled: "t=28 n0=0".
// W1199 reports a check once, at its first violation (a diagnostic is
// reported once per site, VD-105); the later ones show in the notifier's
// transcript lines above.
//! inherited IEEE 1364-2005 15.2 15.2.2 15.5
`timescale 1ns/1ns
module b_15_2_2_hold_ff(clk, d);
  input clk, d;
  reg ntfr, n0;
  initial #1 begin
    ntfr = 1'b0;
    n0 = 1'b0;
  end
  always @(ntfr) $display("t=%0d ntfr=%b", $time, ntfr);
  specify
    $hold(posedge clk, d, 3, ntfr);
    $hold(posedge clk, d, 0, n0);
  endspecify
endmodule

module b_15_2_2_hold;
  reg clk, d;
  b_15_2_2_hold_ff u(clk, d);
  initial begin
    clk = 0; d = 0;
    #10 clk = 1; d = 1;
    #5 clk = 0;
    #5 d = 0; clk = 1;
    #1 d = 1;
    #2 d = 0;
    #5 $display("t=%0d n0=%b", $time, u.n0);
    $finish(0);
  end
endmodule
