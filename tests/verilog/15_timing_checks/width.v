// IEEE 1364-2005 §15.3.4, Table 15-10 (pp. 255-256): $width's reference
// event is the "Timestamp edge triggered event" and "data event = reference
// event signal with opposite edge", the "Timecheck edge triggered event".
// "The $width timing check reports a violation in the following case:
// threshold < (timecheck time) - (timestamp time) < limit". "The pulse width
// has to be greater than or equal to limit in order to avoid a timing
// violation, but no violation is reported for glitches smaller than the
// threshold." §15.4: posedge is edge[01, 0x, x1], negedge edge[10, x0, 1x].
// §15.5 Table 15-13: each violation toggles the notifier.
//
// The cell: $width(posedge clk, 5, 1, ntfr) (high pulses: violation when
// 1 < width < 5) and $width(negedge clk, 4, 0, n2) (low pulses: when
// 0 < width < 4). Both notifiers start at 0 at t=1; `always @(ntfr)` prints
// ntfr's values.
//
// DERIVATION (t in ns; clk falls at 0, 13, 21, 35, 42 and rises at 10, 20,
// 30, 40):
//   high pulses, rise to fall: [10, 13] 3: 1 < 3 < 5, VIOLATION,
//     "t=13 ntfr=1"; [20, 21] 1: not above the threshold 1, none; [30, 35]
//     5: not below the limit, none; [40, 42] 2: VIOLATION, "t=42 ntfr=0".
//     clk's x -> 0 at 0 is a negedge (x0) with no posedge before it, so no
//     pulse ends there.
//   low pulses, fall to rise: [0, 10] 10, [13, 20] 7, [21, 30] 9, [35, 40]
//     5: none below 4, so n2 stays 0: "t=45 n2=0".
// W1199 reports a check once, at its first violation (a diagnostic is
// reported once per site, VD-105); the later ones show in the notifier's
// transcript lines above.
//! inherited IEEE 1364-2005 15.3 15.3.4 15.5
`timescale 1ns/1ns
module b_15_3_4_width_ff(clk);
  input clk;
  reg ntfr, n2;
  initial #1 begin
    ntfr = 1'b0;
    n2 = 1'b0;
  end
  always @(ntfr) $display("t=%0d ntfr=%b", $time, ntfr);
  specify
    $width(posedge clk, 5, 1, ntfr);
    $width(negedge clk, 4, 0, n2);
  endspecify
endmodule

module b_15_3_4_width;
  reg clk;
  b_15_3_4_width_ff u(clk);
  initial begin
    clk = 0;
    #10 clk = 1;
    #3 clk = 0;
    #7 clk = 1;
    #1 clk = 0;
    #9 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #2 clk = 0;
    #3 $display("t=%0d n2=%b", $time, u.n2);
    $finish(0);
  end
endmodule
