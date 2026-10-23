// Verilog-AMS LRM 2.4 annex A.2.2.1:
//   "net_type ::= supply0 | supply1 | tri | triand | trior | tri0 | tri1
//               | uwire | wire | wand | wor"
// annex A.2.2.2 lists `supply0`/`supply1` again, as strength keywords:
//   "strength0 ::= supply0 | strong0 | pull0 | weak0
//    strength1 ::= supply1 | strong1 | pull1 | weak1"
// That double appearance IS the clause being pinned. §1.1 makes the semantics
// IEEE Std 1364 Verilog's: a supply net is a source at level supply (7), which
// is the same level a (supply1, supply0) driver asserts. So "a supply net
// cannot be overridden" is a CONSEQUENCE of the strength order, not a rule
// about supply nets — and it stops being true the moment the competitor is
// itself at supply strength.
//
// Today src/sim/digital.zig:778-781 implements the consequence directly: a
// supply net ignores its drivers unconditionally. That is right for line 1 and
// line 2's first two columns and wrong for the supply-versus-supply tie.
//
//! lrm annex A.2.2.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 4.6.6 7.13 7.13.3 7.10.1
//
// HAND DERIVATION — levels supply = 7, strong = 6.
//   vdd : supply1 net (s1 = 7 always) + (strong1, strong0) driver `a`
//   gnd : supply0 net (s0 = 7 always) + (strong1, strong0) driver `a`
//   v2  : supply1 net (s1 = 7 always) + (supply1, supply0) driver `a`
//   w   : plain wire + (supply1, supply0) driver `a` + (strong1, strong0) `k`,
//         with k held at 0 for the whole run
//
//   t=1  a=z:  vdd s1=7,s0=0 -> 1   gnd s0=7,s1=0 -> 0   v2 s1=7,s0=0 -> 1
//              w   s0=6 (k only), s1=0            -> 0
//   t=2  a=1:  vdd s1=7, s0=0                     -> 1
//              gnd s0=7, s1=6                     -> 0
//              v2  s1=max(7,7)=7, s0=0            -> 1
//              w   s1=7 (supply driver), s0=6 (k) -> 1
//   t=3  a=0:  vdd s1=7, s0=6                     -> 1
//              gnd s0=max(7,7)=7, s1=0            -> 0
//              v2  s1=7, s0=7, equal and nonzero  -> x
//              w   s0=max(7,6)=7, s1=0            -> 0
//
// Today: the v2 column is 1 on every line — a supply net never looks at a
// driver — and the w column reads 0, x, 0 because its two drivers are equals.

`timescale 1ns/1ns
module d03_supply_net_strength;
  reg a, k;
  supply1 vdd;
  supply0 gnd;
  supply1 v2;
  wire w;

  assign (strong1, strong0) vdd = a;
  assign (strong1, strong0) gnd = a;
  assign (supply1, supply0) v2 = a;
  assign (supply1, supply0) w = a;
  assign (strong1, strong0) w = k;

  initial begin
    k = 1'b0;
    a = 1'bz;
    #1 $display("undriven %b %b %b %b", vdd, gnd, v2, w);
    a = 1'b1;
    #1 $display("driver_one %b %b %b %b", vdd, gnd, v2, w);
    a = 1'b0;
    #1 $display("driver_zero %b %b %b %b", vdd, gnd, v2, w);
    $finish(0);
  end
endmodule
