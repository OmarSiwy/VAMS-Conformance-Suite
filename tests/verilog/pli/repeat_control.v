// repeat_control.c's design: an intra-assignment repeat event
// control (IEEE 1364-2005 §9.7.7, A.6.5 `repeat ( expression )
// event_control`).
`timescale 1ns/1ns
module b26_repeat_control;
  reg [3:0] b, c;
  reg clk;
  initial begin
    b = 4'd7;
    clk = 0;
    c = repeat (2) @(posedge clk) b;
  end
  initial begin
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 $finish(0);
  end
endmodule
