// IEEE 1364-2005 §9.7.1: "If the delay expression evaluates to a negative
// value, it shall be interpreted as a two's-complement unsigned integer of
// the same size as a time variable."
//
// d is a signed 8-bit reg holding -1. VerA's time variable is 64 bits, so
// #d is 2^64 - 1 units: the display after it is due long past t=300,
// where the second initial prints "300" and ends the run.
// Reading the 8 bits 1111_1111 as an unsigned 255 instead would print
// "255 late" first.
//! inherited IEEE 1364-2005 9.7.1
`timescale 1ns/1ns
module b_9_7_1_negative_signed_delay;
  reg signed [7:0] d;

  initial begin
    d = -1;
    #d $display("%0d late", $time);
  end

  initial #300 begin
    $display("%0d", $time);
    $finish(0);
  end
endmodule
