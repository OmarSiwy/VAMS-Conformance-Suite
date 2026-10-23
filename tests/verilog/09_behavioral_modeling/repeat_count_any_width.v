// IEEE 1364-2005 §9.6: "If the expression evaluates to unknown or high
// impedance, it shall be treated as zero, and no statement shall be
// executed." A negative count runs nothing either, as §9.7.7 says of the
// repeat event control: "less than or equal to 0 ... as if there is no
// repeat construct". Neither depends on the count's width.
//   repeat (-1), repeat (-65'sd1), a 70-bit signed reg at -1 -> "0" each
//   a 70-bit unsigned reg at 2 -> "2"; at all x, a signed one at all z -> "0"
//   b = repeat (sw = -2) @(e): no wait -> "0 b 1"
//   a = repeat (uw = 2) @(e): events at t=1 and 2 -> "2 a 1"
//   uw = 2^64: past 64 bits the count saturates; the first pass $finishes
//! inherited IEEE 1364-2005 9.6 9.7.7
// native-required
`timescale 1ns/1ns
module b_9_6_repeat_count_any_width;
  integer n;
  reg a, b;
  reg signed [69:0] sw;
  reg [69:0] uw;
  event e;

  initial begin
    n = 0; repeat (-1) n = n + 1; $display("%0d", n);
    n = 0; repeat (-65'sd1) n = n + 1; $display("%0d", n);
    sw = -1; n = 0; repeat (sw) n = n + 1; $display("%0d", n);
    uw = 2; n = 0; repeat (uw) n = n + 1; $display("%0d", n);
    uw = 70'bx; n = 0; repeat (uw) n = n + 1; $display("%0d", n);
    sw = 70'sbz; n = 0; repeat (sw) n = n + 1; $display("%0d", n);
    a = 0; b = 0; sw = -2; uw = 2;
    b = repeat (sw) @(e) 1'b1;
    $display("%0t b %b", $time, b);
    a = repeat (uw) @(e) 1'b1;
    $display("%0t a %b", $time, a);
    uw = 70'h1_0000_0000_0000_0000;
    repeat (uw) begin $display("first"); $finish(0); end
  end

  initial begin #1 -> e; #1 -> e; #1 -> e; end
endmodule
