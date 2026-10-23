// IEEE 1364-2005 §15.2.1, Table 15-1 (p. 241): $setup's data_event is the
// "Timestamp event", its reference_event the "Timecheck event", and
//   "(beginning of time window) = (timecheck time) - limit
//    (end of time window) = (timecheck time)
//    The $setup timing check reports a timing violation in the following case:
//    (beginning of time window) < (timestamp time) < (end of time window)
//    The end points of the time window are not part of the violation region.
//    When the limit is zero, the $setup check shall never issue a violation."
// §15.2: "Report a timing violation if the data signal transitions within the
// time window." §15.5 Table 15-13: a violation takes the notifier 0 -> 1 and
// 1 -> 0. §15.4: "posedge clr is equivalent to ... edge[01, 0x, x1] clr".
//
// The cell: $setup(d, posedge clk, 5, ntfr) and $setup(d, posedge clk, 0, n0).
// ntfr and n0 start at 0 at t=1; `always @(ntfr)` prints each value ntfr takes.
//
// DERIVATION (t in ns; the window of a reference event at T is (T-5, T), open
// at both ends; the timestamp is the latest data event before T):
//   t=0   clk x -> 0 is a negedge (x0), no reference event; d x -> 0 is a data
//         event.
//   t=1   ntfr = 0: prints "t=1 ntfr=0".
//   t=10  d 0 -> 1: data event.
//   t=12  clk rises: (7, 12) holds 10: VIOLATION, ntfr 0 -> 1, "t=12 ntfr=1".
//   t=20  d 1 -> 0: data event.
//   t=25  clk rises: (20, 25) does not hold 20, its open start: none.
//   t=35  d 0 -> 1, then clk rises, at once: 35 is (30, 35)'s open end, and the
//         data event before it, at 20, is outside: none.
//   t=52  d 1 -> 0: data event.
//   t=55  d 0 -> 1, then clk rises, at once: the data event at 55 is outside
//         (50, 55); the one at 52 inside: VIOLATION, ntfr 1 -> 0,
//         "t=55 ntfr=0".
//   t=60  n0's limit is zero, so it never toggled: "t=60 n0=0".
// W1199 reports a check once, at its first violation (a diagnostic is
// reported once per site, VD-105); the later ones show in the notifier's
// transcript lines above.
//! inherited IEEE 1364-2005 15.2 15.2.1 15.5
`timescale 1ns/1ns
module b_15_2_1_setup_ff(clk, d);
  input clk, d;
  reg ntfr, n0;
  initial #1 begin
    ntfr = 1'b0;
    n0 = 1'b0;
  end
  always @(ntfr) $display("t=%0d ntfr=%b", $time, ntfr);
  specify
    $setup(d, posedge clk, 5, ntfr);
    $setup(d, posedge clk, 0, n0);
  endspecify
endmodule

module b_15_2_1_setup;
  reg clk, d;
  b_15_2_1_setup_ff u(clk, d);
  initial begin
    clk = 0; d = 0;
    #10 d = 1;
    #2 clk = 1;
    #3 clk = 0;
    #5 d = 0;
    #5 clk = 1;
    #5 clk = 0;
    #5 d = 1; clk = 1;
    #5 clk = 0;
    #12 d = 0;
    #3 d = 1; clk = 1;
    #5 $display("t=%0d n0=%b", $time, u.n0);
    $finish(0);
  end
endmodule
