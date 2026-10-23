// Verilog-AMS LRM 2.4 §8.5.3.1:
//   "A continuous assignment statement (6.1 of IEEE Std 1364 Verilog)
//    corresponds to a process, sensitive to the source elements in the
//    expression. When the value of the expression changes, it causes an active
//    update event to be added to the event queue, using current values to
//    determine the target."
//
// Nothing in that clause is scoped to a module: EACH INSTANCE of `dly` gets
// its own process and its own driver, and §6.2.2 module instantiation is what
// gives the second instance a source element (`mid`) that the first instance
// drives. Delays therefore ACCUMULATE along a path rather than collapsing:
// the queueing of the second update cannot begin until the first one has been
// applied, because §8.5.3.1 keys the process on a CHANGE of its source.
//
//! lrm 8.5.3.1
//! lrm 6.2.2
//! lrm annex A.6.1
//! lrm annex A.2.2.3
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.3 11.6.6
//
// Hand derivation.  Two `assign #5` stages in series, u1: a -> mid,
// u2: mid -> y.
//   t=0   a := 0.  Both stages settle by t=10 (5 + 5)     -> mid = 0, y = 0
//   t=20  a := 1   -> u1 queues mid = 1 for 20 + 5 = 25
//         t=24 -> mid = 0, y = 0
//         t=25 -> mid = 1, y = 0   (u2 has only just SEEN its source change;
//                                   it queues y = 1 for 25 + 5 = 30)
//         t=29 -> mid = 1, y = 0
//         t=30 -> mid = 1, y = 1
// The total 10 ns is the load-bearing number: an implementation that flattened
// the hierarchy into one sensitivity list would deliver y at t=25.
//
// NOTE: this fixture is jointly blocked on D07 — digital execution currently
// accepts exactly one ordinary module, so it fails elaboration before it ever
// reaches the delay question. It is written now because the delay-composition
// semantics it pins belong to D06, not D07.

`timescale 1ns/1ns

module dly(input a, output y);
  assign #5 y = a;
endmodule

module hier_delay;
  reg a;
  wire mid, y;

  dly u1(a, mid);
  dly u2(mid, y);

  initial begin
    a = 1'b0;
    #15 #0 $display("t15 mid=%b y=%b", mid, y);
    #5 a = 1'b1;
    #4 #0 $display("t24 mid=%b y=%b", mid, y);
    #1 #0 $display("t25 mid=%b y=%b", mid, y);
    #4 #0 $display("t29 mid=%b y=%b", mid, y);
    #1 #0 $display("t30 mid=%b y=%b", mid, y);
    $finish(0);
  end
endmodule
