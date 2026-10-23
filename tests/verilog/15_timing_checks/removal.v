// IEEE 1364-2005 §15.2.4, Table 15-4 (p. 245): $removal's reference_event is
// the "Timecheck event", its data_event the "Timestamp event", and
//   "(beginning of time window) = (timecheck time) - limit
//    (end of time window) = (timecheck time)
//    The $removal timing check reports a timing violation in the following
//    case: (beginning of time window) < (timestamp time) < (end of time
//    window) The end points of the time window are not part of the
//    violation region."
// "The reference event is usually a control signal like clear, reset, or
// set, while the data event is usually a clock signal." §15.5 Table 15-13: a
// violation takes the notifier 0 -> 1.
//
// The cell: $removal(posedge clr, posedge clk, 3, ntfr). ntfr starts at 0 at
// t=1; `always @(ntfr)` prints its values.
//
// DERIVATION (t in ns; a reference event at T has the window (T-3, T)):
//   t=0   clr x -> 0, clk x -> 0: negedges, no event of the check.
//   t=1   "t=1 ntfr=0".
//   t=10  clk rises: a data event.
//   t=12  clr rises: (9, 12) holds 10: VIOLATION, "t=12 ntfr=1".
//   t=20  clk rises.
//   t=23  clr rises: (20, 23) does not hold 20, its open start: none.
//   t=30  clk rises, then clr rises, at once: 30 is (27, 30)'s open end, and
//         the data event before it, at 20, is outside: none.
//   t=35  "t=35 ntfr=1".
//! inherited IEEE 1364-2005 15.2 15.2.4 15.5
`timescale 1ns/1ns
module b_15_2_4_removal_ff(clr, clk);
  input clr, clk;
  reg ntfr;
  initial #1 ntfr = 1'b0;
  always @(ntfr) $display("t=%0d ntfr=%b", $time, ntfr);
  specify
    $removal(posedge clr, posedge clk, 3, ntfr);
  endspecify
endmodule

module b_15_2_4_removal;
  reg clr, clk;
  b_15_2_4_removal_ff u(clr, clk);
  initial begin
    clr = 0; clk = 0;
    #10 clk = 1;
    #2 clr = 1;
    #3 clk = 0; clr = 0;
    #5 clk = 1;
    #3 clr = 1;
    #2 clr = 0; clk = 0;
    #5 clk = 1; clr = 1;
    #5 $display("t=%0d ntfr=%b", $time, u.ntfr);
    $finish(0);
  end
endmodule
