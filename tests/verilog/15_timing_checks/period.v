// IEEE 1364-2005 §15.3.5, Table 15-11 (pp. 256-257): "data event = reference
// event signal with the same edge", and "The $period timing check reports a
// violation in the following case: (timecheck time) - (timestamp time) <
// limit", between one reference edge and the next. §15.4: posedge is
// edge[01, 0x, x1]; edge[10] names the 1 -> 0 transition only. §15.5 Table
// 15-13: each violation toggles the notifier.
//
// The cell: $period(posedge clk, 10, ntfr) and $period(edge[10] clk, 10, n2).
// Both notifiers start at 0 at t=1; `always @(ntfr)` prints ntfr's values.
//
// DERIVATION (t in ns; clk falls at 0, 15, 25, 30 and rises at 10, 20, 28,
// 40):
//   posedges 10, 20, 28, 40: periods 10 (not below 10), 8 (VIOLATION,
//     "t=28 ntfr=1"), 12 (none). The first posedge has no period before it.
//   1 -> 0 edges 15, 25, 30 (clk's x -> 0 at 0 is x0, not 10): periods 10
//     (none), 5 (VIOLATION: n2 0 -> 1). "t=45 n2=1".
//! inherited IEEE 1364-2005 15.3 15.3.5 15.4 15.5
`timescale 1ns/1ns
module b_15_3_5_period_ff(clk);
  input clk;
  reg ntfr, n2;
  initial #1 begin
    ntfr = 1'b0;
    n2 = 1'b0;
  end
  always @(ntfr) $display("t=%0d ntfr=%b", $time, ntfr);
  specify
    $period(posedge clk, 10, ntfr);
    $period(edge[10] clk, 10, n2);
  endspecify
endmodule

module b_15_3_5_period;
  reg clk;
  b_15_3_5_period_ff u(clk);
  initial begin
    clk = 0;
    #10 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 clk = 0;
    #3 clk = 1;
    #2 clk = 0;
    #10 clk = 1;
    #5 $display("t=%0d n2=%b", $time, u.n2);
    $finish(0);
  end
endmodule
