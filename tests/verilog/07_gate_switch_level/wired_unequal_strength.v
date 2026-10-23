// Verilog-AMS LRM 2.4 annex A.2.2.1 gives `wand`/`wor` as net types and annex
// A.2.2.2 the drive strengths; §1.1 makes IEEE Std 1364 clause 7 the
// resolution. IEEE 1364-2005 7.10.1: "If two or more signals of unequal
// strength combine in a wired net configuration, the stronger signal shall
// dominate all the weaker drivers and determine the result." 7.10.4: the
// wired net types "resolve conflicts when multiple drivers have the same
// strength" — only then.
//
// Each wired net below has a conflict the and/or table would decide one way
// and the stronger driver decides the other, so a resolver that applies the
// table across strengths prints a different line.
//
//! lrm annex A.2.2.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 7.10.1 7.10.4
//
// HAND DERIVATION  Levels: St = 6, Pu = 5, We = 3.
//   wa : wand, drivers (pull1, pull0) a and (strong1, strong0) b
//   wo : wor,  the same two drivers
//   w3 : wand, drivers (weak1, weak0) c, (weak1, weak0) d, (pull1, pull0) a
//   o3 : wor,  the same three drivers
//
//   t=1  a=1 b=0 c=0 d=1
//        wa: St0 dominates Pu1 -> 0     wo: St0 dominates Pu1 -> 0 (table: 1)
//        w3: We0 & We1 = We0, then Pu1 dominates We0 -> 1 (table: 0)
//        o3: We0 | We1 = We1, Pu1 agrees -> 1
//   t=2  a=0 b=1 c=0 d=1
//        wa: St1 dominates Pu0 -> 1 (table: 0)     wo: 1
//        w3: We0, Pu0 agrees -> 0
//        o3: We1, then Pu0 dominates We1 -> 0 (table: 1)
//   t=3  a=z b=z c=0 d=1
//        wa, wo: no driver asserts anything -> z z
//        w3: We0 & We1 -> 0             o3: We0 | We1 -> 1

`timescale 1ns/1ns
module d03_wired_unequal_strength;
  reg a, b, c, d;
  wand wa, w3;
  wor wo, o3;

  assign (pull1, pull0) wa = a, wo = a, w3 = a, o3 = a;
  assign (strong1, strong0) wa = b, wo = b;
  assign (weak1, weak0) w3 = c, o3 = c;
  assign (weak1, weak0) w3 = d, o3 = d;

  initial begin
    a = 1'b1; b = 1'b0; c = 1'b0; d = 1'b1;
    #1 $display("pull_one_strong_zero %b %b %b %b", wa, wo, w3, o3);
    a = 1'b0; b = 1'b1;
    #1 $display("pull_zero_strong_one %b %b %b %b", wa, wo, w3, o3);
    a = 1'bz; b = 1'bz;
    #1 $display("weak_only %b %b %b %b", wa, wo, w3, o3);
    $finish(0);
  end
endmodule
