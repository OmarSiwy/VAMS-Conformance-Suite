// Verilog-AMS LRM 2.4 annex A.2.2.1 gives `triand`/`trior` as net types and
// annex A.2.2.2 the drive strengths; §1.1 makes IEEE Std 1364 clause 7 the
// resolution. IEEE 1364-2005 7.10.4: "The net types triand, wand, trior, and
// wor shall resolve conflicts when multiple drivers have the same strength.
// These net types shall resolve signal values by treating signals as inputs of
// logic functions." 7.10.1: "The combination of signals with unlike values and
// the same strength can have three possible results. Two of the results occur
// in the presence of wired logic".
//
// This fixture is the half of 7.10.4 that strength does NOT change: both
// drivers are (pull1, pull0), so every conflict is between equal levels and
// the and/or tables decide it. d03_14 is the unequal half.
//
// An x driver is ambiguous (7.10.2): at pull strength it spans Pu0..Pu1, and
// 7.10.4 has "all combinations of each of the strength levels" taken.
//
//! lrm annex A.2.2.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 7.10.1 7.10.2 7.10.4
//
// HAND DERIVATION  ta : triand, to : trior, drivers (pull1, pull0) a and b.
//   Levels are Pu = 5; every pair below is Pu against Pu.
//
//   t=1  a=1 b=0  and(1,0) = 0     or(1,0) = 1
//   t=2  a=0 b=1  and(0,1) = 0     or(0,1) = 1
//   t=3  a=1 b=1  1                1
//   t=4  a=0 b=0  0                0
//   t=5  a=x b=1  a's levels Pu0 .. Pu1 against b's Pu1:
//                 Pu0 & Pu1 = Pu0, every weaker level loses to Pu1, Pu1 & Pu1
//                 = Pu1 -> the results span Pu0 .. Pu1 = x.
//                 trior: Pu0 | Pu1 = Pu1 and the rest Pu1 -> 1.
//   t=6  a=x b=0  triand: Pu1 & Pu0 = Pu0 and the rest Pu0 -> 0.
//                 trior: Pu1 | Pu0 = Pu1, Pu0 | Pu0 = Pu0 -> x.

`timescale 1ns/1ns
module d03_wired_equal_strength_table;
  reg a, b;
  triand ta;
  trior to;

  assign (pull1, pull0) ta = a, to = a;
  assign (pull1, pull0) ta = b, to = b;

  initial begin
    a = 1'b1; b = 1'b0;
    #1 $display("one_zero %b %b", ta, to);
    a = 1'b0; b = 1'b1;
    #1 $display("zero_one %b %b", ta, to);
    a = 1'b1; b = 1'b1;
    #1 $display("one_one %b %b", ta, to);
    a = 1'b0; b = 1'b0;
    #1 $display("zero_zero %b %b", ta, to);
    a = 1'bx; b = 1'b1;
    #1 $display("x_one %b %b", ta, to);
    a = 1'bx; b = 1'b0;
    #1 $display("x_zero %b %b", ta, to);
    $finish(0);
  end
endmodule
