// Verilog-AMS LRM 2.4 annex A.6.1:
//   "continuous_assign ::= assign [ drive_strength ] [ delay3 ]
//    list_of_net_assignments ;"
// annex A.2.2.3:
//   "delay3 ::= # delay_value
//             | # ( mintypmax_expression [ , mintypmax_expression
//                 [ , mintypmax_expression ] ] )"
// §8.5.3.1: the continuous assignment "corresponds to a process, sensitive to
// the source elements in the expression. When the value of the expression
// changes, it causes an active update event to be added to the event queue"
// — the `delay3` is how far in the future that update event is placed
// (6.1.3 of IEEE Std 1364 Verilog, the clause A.6.1's `delay3` belongs to).
//
// A SINGLE delay value is used for every transition direction. This fixture
// pins the delivery INSTANT, not merely "some delay happened": the `#0` reads
// sample the inactive region (§8.5.3.3 "If the delay is 0, the process is
// scheduled as an inactive event for the current time"), which is drained
// AFTER every active update of that same time. So a read at t showing the old
// value and a read at t+1 showing the new value bracket the delivery to
// exactly t+1.
//
//! lrm annex A.6.1
//! lrm annex A.2.2.3
//! lrm 8.5.3.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.3 11.6.1
//
// Hand derivation for `assign #5 y = a;`:
//   t=0   a := 0.  The x->0 change queues an update of y for t=0+5=5.
//   t=9   sampled after that delivery                       -> y = 0
//   t=10  a := 1   -> update of y queued for 10+5 = 15
//   t=14  inactive region, delivery is at 15, not yet done   -> y = 0
//   t=15  inactive region, delivery of this time is drained  -> y = 1
//   t=20  a := 0   -> update of y queued for 20+5 = 25
//   t=24                                                     -> y = 1
//   t=25                                                     -> y = 0
//
// t<5 is deliberately not sampled: whether an undelivered net reads z (net
// default) or x (first driver evaluation) is not decided by the clauses above.

`timescale 1ns/1ns
module assign_delay_single;
  reg a;
  wire y;

  assign #5 y = a;

  initial begin
    a = 1'b0;
    #9 #0 $display("t9 y=%b", y);
    #1 a = 1'b1;
    #4 #0 $display("t14 y=%b", y);
    #1 #0 $display("t15 y=%b", y);
    #5 a = 1'b0;
    #4 #0 $display("t24 y=%b", y);
    #1 #0 $display("t25 y=%b", y);
    $finish(0);
  end
endmodule
