// IEEE 1364-2005 §7.9, pp. 87-88: "Table 7-7 demonstrates the continuum of
// strengths. The left column lists the keywords used in specifying strengths.
// The right column gives correlated strength levels." Table 7-7: supply 7,
// strong 6, pull 5, large 4, weak 3, medium 2, small 1, highz 0.
// "In Table 7-7, there are four driving strengths: supply strong pull weak"
// "Signals with driving strengths shall propagate from gate outputs and
// continuous assignment outputs."
// §7.10.1, p. 88: "If two or more signals of unequal strength combine in a
// wired net configuration, the stronger signal shall dominate all the weaker
// drivers and determine the result."
//
// Each net has two continuous assignments of opposite value. The level order
// of Table 7-7 decides every contest:
//   a: Su1(7) vs St0(6) -> 1     b: St1(6) vs Pu0(5) -> 1
//   c: Pu1(5) vs We0(3) -> 1     d: We1(3) vs HiZ0(0) -> 1
//   e..h: equal levels, opposite values (Su, St, Pu, We) -> x (§7.10.2)
//   i: St0(6) vs Pu1(5) -> 0 (the same order on the 0 side)
//   j: gate output: buf (pull1, pull0) driving 1 vs (weak1, weak0) 0 -> 1;
//      k: the same buf driving 1 vs (strong1, strong0) 0 -> 0
// Line: "1111 xxxx 0 10".
//! inherited IEEE 1364-2005 7.9
`timescale 1ns/1ns
module b_7_9_strength_levels;
  reg one, zero;
  wire a, b, c, d, e, f, g, h, i, j, k;
  assign (supply1, supply0) a = one;  assign (strong1, strong0) a = zero;
  assign (strong1, strong0) b = one;  assign (pull1, pull0) b = zero;
  assign (pull1, pull0) c = one;      assign (weak1, weak0) c = zero;
  assign (weak1, weak0) d = one;      assign (weak1, highz0) d = zero;
  assign (supply1, supply0) e = zero; assign (supply1, supply0) e = one;
  assign (strong1, strong0) f = zero; assign (strong1, strong0) f = one;
  assign (pull1, pull0) g = zero;     assign (pull1, pull0) g = one;
  assign (weak1, weak0) h = zero;     assign (weak1, weak0) h = one;
  assign (strong1, strong0) i = zero; assign (pull1, pull0) i = one;
  buf (pull1, pull0) bj (j, one);     assign (weak1, weak0) j = zero;
  buf (pull1, pull0) bk (k, one);     assign (strong1, strong0) k = zero;
  initial begin
    one = 1; zero = 0;
    #1 $display("%b%b%b%b %b%b%b%b %b %b%b", a, b, c, d, e, f, g, h, i, j, k);
    $finish(0);
  end
endmodule
