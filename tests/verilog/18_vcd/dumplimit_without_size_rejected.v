// IEEE 1364-2005 §18.1.5, p. 328, Syntax 18-6:
//   dumplimit_task ::= $dumplimit ( filesize ) ;
// "The filesize argument specifies the maximum size of the VCD file in
// bytes." The production has no form without it, so a bare `$dumplimit;`
// sets no limit and is no dumplimit_task. Legal neighbour:
// dumplimit_stops_with_comment.v's `$dumplimit(4000)`.
//! inherited IEEE 1364-2005 18.1.5
//! reject E1100
//! reject $dumplimit takes one file size
//! neighbour dumplimit_stops_with_comment.v
`timescale 1ns/1ns
module b_18_1_5_dumplimit_without_size_rejected;
  reg a;
  reg [7:0] v;
  initial begin
    $dumpvars(0, b_18_1_5_dumplimit_without_size_rejected);
    $dumplimit;
    a = 1'b0;
    v = 8'h00;
    #1 a = 1'b1;
  end
endmodule
