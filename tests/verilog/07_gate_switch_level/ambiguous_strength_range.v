// Verilog-AMS LRM 2.4 annex A.2.2.2 (drive_strength) with §1.1's "complete IEEE
// Std 1364 Verilog specification": clause 7 distinguishes an UNAMBIGUOUS signal
// (one value at one strength) from an AMBIGUOUS one (a range of possible
// levels). A driver whose value is x at strength S is ambiguous: it asserts
// level S on the 0 side AND level S on the 1 side at once.
//
// The rule this fixture pins is the one that decides between them: an
// unambiguous signal STRONGER than the whole ambiguous range replaces it; a
// signal weaker than the range disappears into it. The x of a pull-strength
// driver is therefore not sticky — a strong driver resolves it to a known
// value, which no value-only conflict rule can ever do.
//
//! lrm annex A.6.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.4 7.10.3
//
// HAND DERIVATION — `a` drives BOTH nets through a (pull1, pull0) driver;
// `w` additionally has a (strong1, strong0) driver `b`, and `v` additionally
// has a (weak1, weak0) driver `c`. Levels: strong = 6, pull = 5, weak = 3.
//
//   t=1  a=x -> s0=5, s1=5 on both nets. b=z, c=z contribute nothing.
//        w: 5 == 5 -> x            v: 5 == 5 -> x
//   t=2  b=1 -> s1=6 on w; c=1 -> s1=3 on v.
//        w: s1 = max(5,6) = 6 > s0 = 5           -> 1
//        v: s1 = max(5,3) = 5 == s0 = 5          -> x
//   t=3  b=0 -> s0=6 on w; c=0 -> s0=3 on v.
//        w: s0 = max(5,6) = 6 > s1 = 5           -> 0
//        v: s0 = max(5,3) = 5 == s1 = 5          -> x
//   t=4  a=1 -> s1=5, s0=0 on both (the range collapses to one level).
//        w: s1 = 5 against b's s0 = 6            -> 0
//        v: s1 = 5 against c's s0 = 3            -> 1
//
// Line 4 is the same pull-strength 1 losing on one net and winning on the
// other, with nothing changed but the opponent's strength.
//
// Today: every line reads "x x".

`timescale 1ns/1ns
module d03_ambiguous_strength_range;
  reg a, b, c;
  wire w, v;

  assign (pull1, pull0) w = a;
  assign (strong1, strong0) w = b;
  assign (pull1, pull0) v = a;
  assign (weak1, weak0) v = c;

  initial begin
    a = 1'bx; b = 1'bz; c = 1'bz;
    #1 $display("ambiguous_alone %b %b", w, v);
    b = 1'b1; c = 1'b1;
    #1 $display("one_over_range %b %b", w, v);
    b = 1'b0; c = 1'b0;
    #1 $display("zero_over_range %b %b", w, v);
    a = 1'b1;
    #1 $display("pull_one_against_each %b %b", w, v);
    $finish(0);
  end
endmodule
