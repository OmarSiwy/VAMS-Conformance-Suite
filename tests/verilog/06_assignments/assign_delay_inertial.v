// Verilog-AMS LRM 2.4 §8.5.3.1:
//   "A continuous assignment statement (6.1 of IEEE Std 1364 Verilog)
//    corresponds to a process, sensitive to the source elements in the
//    expression. When the value of the expression changes, it causes an active
//    update event to be added to the event queue, using current values to
//    determine the target."
//
// A continuous assignment has ONE driver of its net (annex A.6.1:
// "net_assignment ::= net_lvalue = expression", one per driver). A driver
// carries one value. IEEE 1364-2005 §6.1.3(b) cancels pending propagation
// when the new RHS differs from the pending value; an unchanged pending RHS
// retains its deadline (assignment_pending_same_value.v). Step(c)
// schedules nothing when the new RHS equals the current LHS. Together these
// suppress the narrow pulse exercised here.
//
//! lrm 8.5.3.1
//! lrm annex A.6.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.3 11.6.1
//
// Hand derivation for `assign #5 y = a;`:
//   t=0   a := 0.  Delivered at t=5                             -> y = 0
//   t=9   settled                                               -> y = 0
//   NARROW PULSE, width 2 < 5:
//   t=10  a := 1 -> update y=1 queued for t=15
//   t=12  a := 0 -> cancel y=1@15; current y is already0, so schedule nothing.
//   t=14 -> y = 0    t=15 -> y = 0 (NO glitch)    t=17 -> y = 0
//         No y=0@17 event is required by the source.
//   WIDE PULSE, width 10 > 5:
//   t=20  a := 1 -> update y=1 queued for t=25; nothing outstanding
//         t=24 -> y = 0    t=25 -> y = 1
//   t=30  a := 0 -> update y=0 queued for t=35; the t=25 event already fired
//         t=34 -> y = 1    t=35 -> y = 0
//
// The three reads at t=14, t=15 and t=17 are what make this an INERTIAL pin
// rather than a transport-delay pin: a transport-delay implementation would
// show y = 1 at t=15 and y = 0 again at t=17.

`timescale 1ns/1ns
module assign_delay_inertial;
  reg a;
  wire y;

  assign #5 y = a;

  initial begin
    a = 1'b0;
    #9 #0 $display("t9 y=%b", y);
    #1 a = 1'b1;
    #2 a = 1'b0;
    #2 #0 $display("t14 y=%b", y);
    #1 #0 $display("t15 y=%b", y);
    #2 #0 $display("t17 y=%b", y);
    #3 a = 1'b1;
    #4 #0 $display("t24 y=%b", y);
    #1 #0 $display("t25 y=%b", y);
    #5 a = 1'b0;
    #4 #0 $display("t34 y=%b", y);
    #1 #0 $display("t35 y=%b", y);
    $finish(0);
  end
endmodule
