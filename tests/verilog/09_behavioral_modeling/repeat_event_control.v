// IEEE 1364-2005 §9.7.7, p. 136: "An intra-assignment delay or event control
// shall delay the assignment of the new value to the left-hand side, but the
// right-hand expression shall be evaluated before the delay, instead of after
// the delay."
// p. 137: "The intra-assignment delay and event control can be applied to both
// blocking assignments and nonblocking assignments. The repeat event control
// shall specify an intra-assignment delay of a specified number of occurrences
// of an event. If the repeat count literal, or signed reg holding the repeat
// count, is less than or equal to 0 at the time of evaluation, the assignment
// occurs as if there is no repeat construct." ... "repeat (a) @
// (event_expression) // if a is assigned -3, it will execute the
// event_expression // if a is declared as an unsigned reg, but not if a is
// signed"
//
// clk is 0 at t=0 and toggles every 1 ns: posedges at t = 1, 3, 5, 7, ...
//   t=0  b = 5; a = repeat(3) @(posedge clk) b: b is read now (5); the second
//        initial sets b = 7 at t=2; the third posedge is t=5 -> "5 5"
//   t=5  x = repeat(-3) @(posedge clk) 9: count <= 0, no wait -> "5 9"
//   t=5  s signed [3:0] = -3: y = repeat(s) ... 4: no wait -> "5 4"
//   t=5  u unsigned [3:0] = -3 = 4'b1101 = 13: z = repeat(u) ... 6 waits 13
//        posedges after t=5: 7, 9, ..., 7 + 2*12 = 31 -> "31 6"
//   t=31 d = 3; w <= repeat(2) @(posedge clk) d: d is read now (3); d = 8
//        right after; posedges 33 and 35, w = 3 from t=35; printed at t=36
//        -> "36 3"
//! inherited IEEE 1364-2005 9.7.7
`timescale 1ns/1ns
module b_9_7_7_repeat_event_control;
  reg clk;
  reg signed [3:0] s;
  reg [3:0] u;
  integer a, b, x, y, z, d, w;

  always #1 clk = ~clk;

  initial begin
    clk = 1'b0;
    b = 5;
    a = repeat (3) @(posedge clk) b;
    $display("%0d %0d", $time, a);
    x = repeat (-3) @(posedge clk) 9;
    $display("%0d %0d", $time, x);
    s = -3;
    y = repeat (s) @(posedge clk) 4;
    $display("%0d %0d", $time, y);
    u = -3;
    z = repeat (u) @(posedge clk) 6;
    $display("%0d %0d", $time, z);
    d = 3;
    w <= repeat (2) @(posedge clk) d;
    d = 8;
    #5 $display("%0d %0d", $time, w);
    $finish(0);
  end

  initial #2 b = 7;
endmodule
