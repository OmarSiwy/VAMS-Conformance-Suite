// IEEE 1364-2005 §9.7.7, p. 137: "If the repeat count literal, or signed reg
// holding the repeat count, is less than or equal to 0 at the time of
// evaluation, the assignment occurs as if there is no repeat construct." ...
// "repeat (a) @ (event_expression) // if a is assigned -3, it will execute
// the event_expression // if a is declared as an unsigned reg, but not if a
// is signed": an unsigned count is never <= 0, however wide.
//
// u is an unsigned 64-bit reg holding 64'hffff_ffff_ffff_ffff = 2^64 - 1:
//   t=0  a = 0; a = repeat (u) @(e) 1 parks 1 and waits for 2^64 - 1
//        occurrences of e
//   t=1  e occurs once: 2^64 - 2 still to come, a keeps 0
//   t=2  "2 0", then $finish
// A count read as the signed 64-bit -1 would assign at once: "2 1".
//! inherited IEEE 1364-2005 9.7.7
`timescale 1ns/1ns
module b_9_7_7_repeat_unsigned_64bit_count;
  reg [63:0] u;
  reg a;
  event e;

  initial begin
    a = 1'b0;
    u = 64'hffff_ffff_ffff_ffff;
    a = repeat (u) @(e) 1'b1;
  end

  initial begin
    #1 -> e;
    #1 $display("%0d %b", $time, a);
    $finish(0);
  end
endmodule
