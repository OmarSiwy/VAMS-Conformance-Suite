// Verilog-AMS LRM 2.4 annex A.2.2.1:
//   "net_type ::= supply0 | supply1 | tri | triand | trior | tri0 | tri1
//               | uwire | wire | wand | wor"
// §1.1 makes their semantics IEEE Std 1364 Verilog's: a tri0 net models a
// resistive pulldown and a tri1 a resistive pullup, and clause 7's table of
// net-type strengths gives that pull the level `pull` (5) — NOT "a value used
// only when nothing else drives".
//
// That distinction is invisible today because every driver has the same
// strength, so any non-z driver wins. Under the strength model the pull is a
// permanent competitor at level 5: a weak driver can never move a tri0, and a
// pull-strength driver ties with it.
//
//! lrm annex A.2.2.1
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 4.6.4 7.13 7.13.1 7.10.1 7.10.3
//
// HAND DERIVATION — one stimulus `a` feeding four nets. Levels: strong = 6,
// pull = 5, weak = 3. The net's own pull is an extra contribution on one side:
// tri0 adds s0 = 5, tri1 adds s1 = 5.
//
//   t     driver       t (tri0, weak drv)   u (tri1, weak drv)   p (tri0, pull drv)   s (tri0, strong drv)
//   1  a=z  nothing    s0=5,s1=0 -> 0       s0=0,s1=5 -> 1       s0=5,s1=0 -> 0       s0=5,s1=0 -> 0
//   2  a=1  s1=drv     s0=5,s1=3 -> 0       s0=0,s1=5 -> 1       s0=5,s1=5 -> x       s0=5,s1=6 -> 1
//   3  a=0  s0=drv     s0=5,s1=0 -> 0       s0=3,s1=5 -> 1       s0=5,s1=0 -> 0       s0=6,s1=0 -> 0
//   4  a=x  both       s0=5,s1=3 -> 0       s0=3,s1=5 -> 1       s0=5,s1=5 -> x       s0=6,s1=6 -> x
//
// Line 4 is the sharpest: a weak x on a tri0 is a KNOWN 0, because the pulldown
// outweighs both halves of the ambiguous weak signal.
//
// Today: line 1 is right (an undriven tri0/tri1 already shows its pull), and
// lines 2, 3 and 4 all read the driver's own value on every net.

`timescale 1ns/1ns
module d03_tri0_tri1_pull_strength;
  reg a;
  tri0 t;
  tri1 u;
  tri0 p;
  tri0 s;

  assign (weak1, weak0) t = a;
  assign (weak1, weak0) u = a;
  assign (pull1, pull0) p = a;
  assign (strong1, strong0) s = a;

  initial begin
    a = 1'bz;
    #1 $display("undriven %b %b %b %b", t, u, p, s);
    a = 1'b1;
    #1 $display("driver_one %b %b %b %b", t, u, p, s);
    a = 1'b0;
    #1 $display("driver_zero %b %b %b %b", t, u, p, s);
    a = 1'bx;
    #1 $display("driver_x %b %b %b %b", t, u, p, s);
    $finish(0);
  end
endmodule
