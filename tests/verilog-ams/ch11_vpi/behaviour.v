// The digital design behaviour_objects.c walks: one of each
// behavioural object of LRM 11.6.3 and 11.6.16-11.6.24, in a shape that is
// derivable by reading this file. No directives: every number about it is
// asserted from C, through the object model.
//
//   p04_behaviour
//     event go                          11.6.10 named event
//     task bump (input [3:0] by)        11.6.3 task with one io decl
//     function [7:0] twice (input [7:0] v)  11.6.3 function
//     assign #(2,3) w = a & b;          11.6.17, delays rise 2, fall 3
//     process 1: initial begin : main ... end   (the walk below)
//     process 2: always @(posedge clk) q <= {2{a[1:0]}};
//
// The initial block, statement by statement (11.6.21's vpiStmt order):
//   0  a = 4'd9;                        blocking assignment
//   1  b = #1 a;                        assignment with an intra delay
//   2  #2 c = a + b;                    delay control over an assignment
//   3  if (a == 4'd9) c = 1; else c = 2;      if else
//   4  if (c) d = 0;                    if, no else
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
//  17  $display("p04_behaviour: d=%0d", d);
//  18  disable main;
//
// THE TRANSCRIPT the run prints: d is 5 after statement 9 (mem[1] = 5),
// bump adds 1 (6), twice doubles it (12). So one line, "d=12", at t=3 (the
// #1 of statement 1 and the #2 of statement 2). $finish(0) at t=10.

`timescale 1ns/1ns

module p04_behaviour;
  reg  [3:0] a, b, c, d, e, i;
  reg        clk;
  reg  [3:0] mem [0:1];
  reg  [3:0] q;
  wire [3:0] w;
  event go;

  assign #(2,3) w = a & b;

  task bump(input [3:0] by);
    d = d + by;
  endtask

  function [7:0] twice(input [7:0] v);
    twice = v * 2;
  endfunction

  initial begin
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
    $display("p04_behaviour: d=%0d", d);
    disable main;
  end

  always @(posedge clk) q <= {2{a[1:0]}};

  initial #10 $finish(0);
endmodule
