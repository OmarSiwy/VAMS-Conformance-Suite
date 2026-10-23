// Verilog-AMS LRM 2.4 annex A.6.1:
//   "continuous_assign ::= assign [ drive_strength ] [ delay3 ]
//    list_of_net_assignments ;"
// annex A.2.2.2:
//   "drive_strength ::= ( strength0 , strength1 ) | ( strength1 , strength0 )
//                     | ( strength0 , highz1 ) | ( strength1 , highz0 )
//                     | ( highz0 , strength1 ) | ( highz1 , strength0 )
//    strength0 ::= supply0 | strong0 | pull0 | weak0
//    strength1 ::= supply1 | strong1 | pull1 | weak1"
// §1.1: "Verilog-AMS HDL consists of the complete IEEE Std 1364 Verilog
// specification", so the MEANING of those keywords is IEEE Std 1364 Verilog
// clause 7: eight strength levels, ordered
//
//   supply(7) > strong(6) > pull(5) > large(4) > weak(3) > medium(2)
//             > small(1) > highz(0)
//
// and a net's value is resolved from its drivers, NOT from a conflict rule on
// four-state values alone. The model each derivation below uses is the one the
// standard's tables encode and the one named as the upgrade path in
// src/sim/digital.zig:103-114 — each driver contributes a level on the 0 side
// and a level on the 1 side:
//
//   value 1 -> (s0 = 0,        s1 = strength1)
//   value 0 -> (s0 = strength0, s1 = 0)
//   value x -> (s0 = strength0, s1 = strength1)
//   value z -> (s0 = 0,        s1 = 0)
//
// the net takes the MAXIMUM of each side across its drivers, and collapses:
// s1 > s0 -> 1, s0 > s1 -> 0, s0 == s1 != 0 -> x, both 0 -> z.
//
// THIS IS THE POINT OF THE ROW. Today two disagreeing drivers conflict to x
// whether or not one of them would have won; under the strength model a
// disagreement is only x when the two sides are EQUAL.
//
//! lrm annex A.6.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.4 7.10.1 7.10.3
//
// HAND DERIVATION — driver A is (strong1, strong0) a, driver B is (weak1, weak0) b.
//   t=1  a=1 -> s1=6; b=0 -> s0=3.  6 > 3            -> w = 1
//   t=2  a=0 -> s0=6; b=1 -> s1=3.  6 > 3            -> w = 0
//   t=3  a=z -> contributes nothing; b=1 -> s1=3     -> w = 1
//   t=4  a=0 -> s0=6; b=0 -> s0=3.  max s0=6, s1=0   -> w = 0
//   t=5  a=x -> s0=6 AND s1=6; b=0 -> s0=3.
//        max s0 = 6, max s1 = 6, equal and nonzero   -> w = x
//
// A value-only resolver gets lines 1 and 2 wrong (x for both).

`timescale 1ns/1ns
module d03_drive_strength_dominance;
  reg a, b;
  wire w;

  assign (strong1, strong0) w = a;
  assign (weak1, weak0) w = b;

  initial begin
    a = 1'b1; b = 1'b0;
    #1 $display("strong_one_beats_weak_zero %b", w);
    a = 1'b0; b = 1'b1;
    #1 $display("strong_zero_beats_weak_one %b", w);
    a = 1'bz;
    #1 $display("strong_removed_weak_shows %b", w);
    a = 1'b0; b = 1'b0;
    #1 $display("both_zero %b", w);
    a = 1'bx;
    #1 $display("strong_x_covers_weak_zero %b", w);
    $finish(0);
  end
endmodule
