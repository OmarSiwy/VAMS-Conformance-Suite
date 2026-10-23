// Verilog-AMS LRM 2.4 annex A.2.2.3:
//   "delay3 ::= # delay_value
//             | # ( mintypmax_expression [ , mintypmax_expression
//                 [ , mintypmax_expression ] ] )"
// The two-expression form of `delay3` on an A.6.1 `continuous_assign` is the
// rise/fall pair of 6.1.3 of IEEE Std 1364 Verilog, which A.6.1's `delay3`
// names: the FIRST value is the delay of a transition to 1, the SECOND the
// delay of a transition to 0, and a transition to x takes the SMALLER of the
// delays specified.
//
// §8.5.3.1 supplies the queueing rule the delay is measured from: the change
// of the expression "causes an active update event to be added to the event
// queue"; which of the two values is used is chosen by the DESTINATION value
// of that update, not by the source that triggered it.
//
//! lrm annex A.2.2.3
//! lrm annex A.6.1
//! lrm 8.5.3.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.3 7.14
//
// Hand derivation for `assign #(3, 7) y = a;`  (rise = 3, fall = 7):
//   t=0   a := 0.  Delivery is at most 7, so by t=10 y has settled -> y = 0
//   t=20  a := 1   -> destination 1 -> RISE -> delivery 20 + 3 = 23
//         t=22 -> y = 0   t=23 -> y = 1
//   t=40  a := 0   -> destination 0 -> FALL -> delivery 40 + 7 = 47
//         t=46 -> y = 1   t=47 -> y = 0
//   t=50  a := x   -> destination x -> min(3,7) = 3 -> delivery 50 + 3 = 53
//         t=52 -> y = 0   t=53 -> y = x
// Each pair brackets the delivery to a single time unit: the earlier read is
// in the inactive region of t-1 (all active updates of t-1 already drained,
// value still old) and the later read in the inactive region of t.

`timescale 1ns/1ns
module assign_delay_rise_fall;
  reg a;
  wire y;

  assign #(3, 7) y = a;

  initial begin
    a = 1'b0;
    #10 #0 $display("t10 y=%b", y);
    #10 a = 1'b1;
    #2 #0 $display("t22 y=%b", y);
    #1 #0 $display("t23 y=%b", y);
    #17 a = 1'b0;
    #6 #0 $display("t46 y=%b", y);
    #1 #0 $display("t47 y=%b", y);
    #3 a = 1'bx;
    #2 #0 $display("t52 y=%b", y);
    #1 #0 $display("t53 y=%b", y);
    $finish(0);
  end
endmodule
