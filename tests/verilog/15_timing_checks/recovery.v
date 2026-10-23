// IEEE 1364-2005 §15.2.5, Table 15-5 (p. 246): $recovery's reference_event is
// the "Timestamp event", its data_event the "Timecheck event", and
//   "(beginning of time window) = (timestamp time)
//    (end of time window) = (timestamp time) + limit
//    The $recovery timing check reports a timing violation in the following
//    case: (beginning of time window) <= (timecheck time) < (end of time
//    window) Only the end of the time window is not part of the violation
//    region."
// So a data event at the time of the reference event violates, whichever of
// the two is processed first. §15.5 Table 15-13: a violation takes the
// notifier 0 -> 1 and 1 -> 0.
//
// The cell: $recovery(posedge clr, posedge clk, 3, ntfr). ntfr starts at 0 at
// t=1; `always @(ntfr)` prints its values.
//
// DERIVATION (t in ns; a reference event at T opens [T, T+3)):
//   t=0   clr x -> 0, clk x -> 0: negedges, no event of the check.
//   t=1   "t=1 ntfr=0".
//   t=10  clr rises: a reference event.
//   t=12  clk rises: in [10, 13): VIOLATION, "t=12 ntfr=1".
//   t=20  clr rises.
//   t=23  clk rises: 23 is [20, 23)'s open end: none.
//   t=30  clk rises, then clr rises, at once: 30 is in [30, 33): VIOLATION,
//         "t=30 ntfr=0" (against the reference at 20 it is outside [20, 23)).
//   t=35  "t=35 ntfr=0".
// W1199 reports a check once, at its first violation (a diagnostic is
// reported once per site, VD-105); the later ones show in the notifier's
// transcript lines above.
//! inherited IEEE 1364-2005 15.2 15.2.5 15.5
`timescale 1ns/1ns
module b_15_2_5_recovery_ff(clr, clk);
  input clr, clk;
  reg ntfr;
  initial #1 ntfr = 1'b0;
  always @(ntfr) $display("t=%0d ntfr=%b", $time, ntfr);
  specify
    $recovery(posedge clr, posedge clk, 3, ntfr);
  endspecify
endmodule

module b_15_2_5_recovery;
  reg clr, clk;
  b_15_2_5_recovery_ff u(clr, clk);
  initial begin
    clr = 0; clk = 0;
    #10 clr = 1;
    #2 clk = 1;
    #3 clk = 0; clr = 0;
    #5 clr = 1;
    #3 clk = 1;
    #2 clr = 0; clk = 0;
    #5 clk = 1; clr = 1;
    #5 $display("t=%0d ntfr=%b", $time, u.ntfr);
    $finish(0);
  end
endmodule
