// IEEE 1364-2005 A.6.5, p. 498:
//   delay_control ::= # delay_value | # ( mintypmax_expression )
// A.8.3, p. 505: mintypmax_expression ::= expression | expression : expression : expression
// §5.3, p. 61 (quoted for context): "This is intended to represent minimum,
// typical, and maximum values—in that order."
//
// A procedural delay control in its parenthesised form, holding a triple.
// §5.3 names no default corner, so nothing below depends on which of 1, 2, 3
// the tool picks for `#(1:2:3) r = 1;`. r = 0 at t = 0 and becomes 1 at t = 1,
// 2 or 3: read at t = 0 (after #0, once the first initial block has
// suspended) it is 0; at t = 10 every corner has elapsed and it is 1.
// Output: "0: 0" then "10: 1".
//! inherited IEEE 1364-2005 A.6.5
`timescale 1ns/1ns
module b_A_6_5_mintypmax_delay_control;
  reg r;
  initial begin
    r = 0;
    #(1:2:3) r = 1;
  end
  initial begin
    #0 $display("%0d: %b", $time, r);
    #10 $display("%0d: %b", $time, r);
    $finish(0);
  end
endmodule
