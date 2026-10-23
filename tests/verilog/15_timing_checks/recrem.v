// IEEE 1364-2005 §15.2.6 (pp. 247-248): "$recrem( posedge clear, posedge
// clk, tREC, tREM ); is equivalent in functionality to the following, if
// tREC and tREM are not negative: $removal( posedge clear, posedge clk, tREM
// ); $recovery( posedge clear, posedge clk, tREC );". With both limits
// positive, when "the data event occurs first ... (beginning of time window)
// < (timestamp time) <= (end of time window)", the removal window (timecheck
// - tREM, timecheck]; when it "occurs second ... (beginning of time window)
// <= (timecheck time) < (end of time window)", the recovery window
// [timestamp, timestamp + tREC). "The $recrem check shall report a timing
// violation when the reference and data events occur simultaneously."
// §15.5 Table 15-13: each violation toggles the notifier.
//
// The cell: $recrem(posedge clr, posedge clk, 3, 2, ntfr): tREC = 3,
// tREM = 2. ntfr starts at 0 at t=1; `always @(ntfr)` prints its values.
//
// DERIVATION (t in ns):
//   t=0   clr x -> 0, clk x -> 0: negedges, no event of the check.
//   t=1   "t=1 ntfr=0".
//   t=10  clk rises: a data event.
//   t=11  clr rises: 10 is in (9, 11]: VIOLATION (removal), "t=11 ntfr=1".
//   t=20  clr rises: the data event at 10 is outside (18, 20]: none.
//   t=22  clk rises: in [20, 23): VIOLATION (recovery), "t=22 ntfr=0".
//   t=30  clr rises, then clk rises, at once: simultaneous: VIOLATION,
//         "t=30 ntfr=1" (the data event before, 22, is outside (28, 30]).
//   t=35  "t=35 ntfr=1".
// W1199 reports a check once, at its first violation (a diagnostic is
// reported once per site, VD-105); the later ones show in the notifier's
// transcript lines above.
//! inherited IEEE 1364-2005 15.2 15.2.6 15.5
`timescale 1ns/1ns
module b_15_2_6_recrem_ff(clr, clk);
  input clr, clk;
  reg ntfr;
  initial #1 ntfr = 1'b0;
  always @(ntfr) $display("t=%0d ntfr=%b", $time, ntfr);
  specify
    $recrem(posedge clr, posedge clk, 3, 2, ntfr);
  endspecify
endmodule

module b_15_2_6_recrem;
  reg clr, clk;
  b_15_2_6_recrem_ff u(clr, clk);
  initial begin
    clr = 0; clk = 0;
    #10 clk = 1;
    #1 clr = 1;
    #4 clr = 0; clk = 0;
    #5 clr = 1;
    #2 clk = 1;
    #3 clr = 0; clk = 0;
    #5 clr = 1; clk = 1;
    #5 $display("t=%0d ntfr=%b", $time, u.ntfr);
    $finish(0);
  end
endmodule
