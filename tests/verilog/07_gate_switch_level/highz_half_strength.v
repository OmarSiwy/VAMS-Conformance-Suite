// Verilog-AMS LRM 2.4 annex A.2.2.2:
//   "drive_strength ::= ... | ( strength1 , highz0 ) | ( highz0 , strength1 )"
// §1.1: "Verilog-AMS HDL consists of the complete IEEE Std 1364 Verilog
// specification" — so `highz0` on the 0 side is IEEE Std 1364 Verilog clause
// 7's level 0: the driver has NO 0-side output at all. An open-drain / open-
// source driver is exactly this, and it is the case that proves a driver's
// strength is a per-VALUE property and not one number per driver.
//
// A driver declared (strong1, highz0) contributes
//     value 1 -> s1 = 6 (strong), s0 = 0
//     value 0 -> s1 = 0,          s0 = 0   <- i.e. it drives z
// so its 0 is INVISIBLE on the net: it neither wins, nor conflicts, nor even
// keeps the net off z.
//
//! lrm annex A.6.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.4 7.10.1
//
// HAND DERIVATION — driver A is (strong1, highz0) a, driver B is (weak1, weak0) b.
//   t=1  a=0 -> nothing;  b=0 -> s0=3.   max s0=3, s1=0     -> w = 0
//   t=2  a=1 -> s1=6;     b=0 -> s0=3.   6 > 3              -> w = 1
//   t=3  a=0 -> nothing;  b=1 -> s1=3.   max s1=3, s0=0     -> w = 1
//   t=4  a=0 -> nothing;  b=z -> nothing. both sides 0      -> w = z
//
// The `x` value of an A-style driver is deliberately NOT sampled: (strong1,
// highz0) driving x is the ambiguous "strong-1-or-z" signal whose collapse to a
// single four-state character is a §7.10 ambiguity question, not a dominance
// one, and this fixture pins dominance.
//
// Today: line 2 resolves x (1 against 0), line 3 resolves x, and line 4
// resolves 0 — the highz half of the pair does not exist, so the driver's 0 is
// a real 0.

`timescale 1ns/1ns
module d03_highz_half_strength;
  reg a, b;
  wire w;

  assign (strong1, highz0) w = a;
  assign (weak1, weak0) w = b;

  initial begin
    a = 1'b0; b = 1'b0;
    #1 $display("open_drain_zero_is_invisible %b", w);
    a = 1'b1; b = 1'b0;
    #1 $display("strong_one_wins %b", w);
    a = 1'b0; b = 1'b1;
    #1 $display("weak_one_uncontested %b", w);
    a = 1'b0; b = 1'bz;
    #1 $display("no_driver_left %b", w);
    $finish(0);
  end
endmodule
