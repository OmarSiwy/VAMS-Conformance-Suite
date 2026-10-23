//! inherited IEEE 1364-2005 11.3 11.4.1 11.6.4
`timescale 1ns/1ps
module scheduling;
  reg [3:0] a, b, captured;
  reg [7:0] wide;
  initial begin
    $display("initial %b", a);
    a = 4'b0001;
    b <= a;
    b <= 4'b0011;
    captured <= a;
    wide <= 4'b1111 + 4'b0001;
    a = 4'b0010;
    #0 $display("inactive %b %b", a, b);
    #1 $display("after %b %b %b %b", a, b, captured, wide);
    $finish(0);
  end
  initial begin
    // A single #0 would put this display in the same inactive batch as the
    // other block's `#0 $display`, and 11.3 lets a batch run in any order;
    // the second #0 orders it after "inactive", still before the NBA region.
    #0 #0 $display("peer %b", a);
    #2 $display("unreachable after finish");
  end
endmodule
