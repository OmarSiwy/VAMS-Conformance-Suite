// The design behaviour.c walks: one or more of each behavioural object
// of IEEE 1364-2005 §26.6.3-§26.6.4, §26.6.18-§26.6.19 and §26.6.24-§26.6.41,
// in a shape derivable by reading this file. Every number about it is
// asserted from C, through the object model.
//
//   processes, in source order: initial (setup), initial : main, always,
//   initial #20 forever, initial #30 $finish.
//   continuous assignments: w (#(2,3)), w1 (#4), nd (net declaration).
//
// main's statements, in order (§26.6.27's block ->> stmt):
//   0  a = 4'd9;                     blocking assignment
//   1  b = #1 a;                     intra-assignment delay control
//   2  #2 c = a + b;                 delay control over an assignment
//   3  if (a == 4'd9) c = 1; else c = 2;
//   4  if (c) d = 0;
//   5  case (a) 4'd1, 4'd2: d = 1; default: d = 2; endcase
//   6  for (i = 0; i < 3; i = i + 1) d = d + 1;
//   7  while (i > 0) i = i - 1;
//   8  repeat (2) clk = ~clk;
//   9  wait (clk == 0) d = mem[1];
//  10  force w = 4'd0;
//  11  release w;
//  12  assign e = 4'd5;
//  13  deassign e;
//  14  -> go;
//  15  bump(4'd1);
//  16  d = twice(d);
//  17  q = @(posedge clk) a;         intra-assignment event control
//  18  fork : fk c = a[i +: 2]; p2 = {2{a[1:0]}}; join
//  19  $display("d=%0d c=%0d q=%0d p2=%b", d, c, q, p2);
//  20  disable main;
//
// THE RUN: a = 9 (t=0), b = 9 (t=1), c = 9 + 9 = 18 mod 16 = 2 (t=3), then
// c = 1 (a == 9), d = 0 (c is 1), d = 2 (case default), d = 5 and i = 3
// (for), i = 0 (while), clk 0 -> 1 -> 0 (repeat), d = mem[1] = 5 (wait: clk
// is 0), bump: d = 6, twice: d = 12. The forever starts at t=20 and raises
// clk at t=21, so q = a = 9 there; the fork gives c = a[1:0] = 2'b01 = 1 (i
// is 0) and p2 = {2'b01, 2'b01} = 4'b0101. One line: "d=12 c=1 q=9 p2=0101".
`timescale 1ns/1ns

module b26_behaviour;
  reg  [3:0] a, b, c, d, e, i, q, p, p2;
  reg        clk;
  reg  [3:0] mem [0:1];
  wire [3:0] w;
  wire       w1;
  wire [3:0] nd = 4'd3;
  event go;

  assign #(2,3) w = a & b;
  assign #4 w1 = a[0];

  task bump(input [3:0] by);
    d = d + by;
  endtask

  function [7:0] twice(input [7:0] v);
    twice = v * 2;
  endfunction

  initial begin
    $timeformat(-9, 0, " ns", 5);
    mem[0] = 4'd0;
    mem[1] = 4'd5;
    clk = 0;
  end

  initial begin : main
    a = 4'd9;
    b = #1 a;
    #2 c = a + b;
    if (a == 4'd9) c = 1; else c = 2;
    if (c) d = 0;
    case (a)
      4'd1, 4'd2: d = 1;
      default: d = 2;
    endcase
    for (i = 0; i < 3; i = i + 1) d = d + 1;
    while (i > 0) i = i - 1;
    repeat (2) clk = ~clk;
    wait (clk == 0) d = mem[1];
    force w = 4'd0;
    release w;
    assign e = 4'd5;
    deassign e;
    -> go;
    bump(4'd1);
    d = twice(d);
    q = @(posedge clk) a;
    fork : fk
      c = a[i +: 2];
      p2 = {2{a[1:0]}};
    join
    $display("d=%0d c=%0d q=%0d p2=%b", d, c, q, p2);
    disable main;
  end

  always @(posedge clk) p <= a;

  initial #20 forever #1 clk = ~clk;

  initial #30 $finish(0);
endmodule
