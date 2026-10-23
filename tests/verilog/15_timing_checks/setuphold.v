// IEEE 1364-2005 §15.2.3 (pp. 243-244): "$setuphold( posedge clk, data, tSU,
// tHLD ); is equivalent in functionality to the following, if tSU and tHLD
// are not negative: $setup( data, posedge clk, tSU ); $hold( posedge clk,
// data, tHLD );". With both limits positive, "When ... the data event occurs
// first ... (beginning of time window) < (timestamp time) <= (end of time
// window)", the window (timecheck - tSU, timecheck]; when it "occurs second
// ... (beginning of time window) <= (timecheck time) < (end of time window)",
// the window [timestamp, timestamp + tHLD). "The $setuphold check shall
// report a timing violation when the reference and data events occur
// simultaneously." "When both limits are zero, the $setuphold check shall
// never issue a violation."
//
// The cell: $setuphold(posedge clk, d, 4, 2, ntfr) and
// $setuphold(posedge clk, d, 0, 0, n0). Both notifiers start at 0 at t=1;
// `always @(ntfr)` prints ntfr's values.
//
// DERIVATION (t in ns):
//   t=0   clk x -> 0 (a negedge), d x -> 0 (a data event): nothing.
//   t=1   "t=1 ntfr=0".
//   t=10  d rises.
//   t=12  clk rises: the data event at 10 is in (8, 12]: VIOLATION (setup),
//         "t=12 ntfr=1".
//   t=13  d falls: in [12, 14): VIOLATION (hold), "t=13 ntfr=0".
//   t=20  clk rises: the last data event, 13, is outside (16, 20]: none.
//   t=22  d rises: 22 is [20, 22)'s open end: none.
//   t=30  d falls, then clk rises, at once: simultaneous: VIOLATION,
//         "t=30 ntfr=1" (the data event before it, 22, is outside (26, 30]).
//   t=40  clk rises, then d rises, at once: simultaneous again, the other
//         order: VIOLATION, "t=40 ntfr=0".
//   t=45  both of n0's limits are zero: "t=45 n0=0".
// W1199 reports a check once, at its first violation (a diagnostic is
// reported once per site, VD-105); the later ones show in the notifier's
// transcript lines above.
//! inherited IEEE 1364-2005 15.2 15.2.3 15.5
`timescale 1ns/1ns
module b_15_2_3_setuphold_ff(clk, d);
  input clk, d;
  reg ntfr, n0;
  initial #1 begin
    ntfr = 1'b0;
    n0 = 1'b0;
  end
  always @(ntfr) $display("t=%0d ntfr=%b", $time, ntfr);
  specify
    $setuphold(posedge clk, d, 4, 2, ntfr);
    $setuphold(posedge clk, d, 0, 0, n0);
  endspecify
endmodule

module b_15_2_3_setuphold;
  reg clk, d;
  b_15_2_3_setuphold_ff u(clk, d);
  initial begin
    clk = 0; d = 0;
    #10 d = 1;
    #2 clk = 1;
    #1 d = 0;
    #2 clk = 0;
    #5 clk = 1;
    #2 d = 1;
    #3 clk = 0;
    #5 d = 0; clk = 1;
    #5 clk = 0;
    #5 clk = 1; d = 1;
    #5 $display("t=%0d n0=%b", $time, u.n0);
    $finish(0);
  end
endmodule
