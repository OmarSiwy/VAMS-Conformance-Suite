// Verilog-AMS LRM 2.4 annex A.6.1 (`assign [ drive_strength ] ...`) and annex
// A.2.2.2 (the eight strength keywords). §1.1 makes the semantics IEEE Std 1364
// Verilog clause 7's: a net's value is the resolution of ALL of its drivers,
// recomputed whenever any one of them changes.
//
// This fixture is the "resolution after driver removal" half of D03 with the
// strength model switched on. Two equal-strength drivers that disagree give x
// AT THAT STRENGTH — the x is not a terminal state, it is a value at level 3
// that a level 6 driver overrides, and that comes back the instant the level 6
// driver goes to z.
//
//! lrm annex A.6.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.4 7.10.1
//
// HAND DERIVATION — drivers A and B are (weak1, weak0), driver C is
// (strong1, strong0). Levels: weak = 3, strong = 6.
//   t=1  a=1 -> s1=3; b=0 -> s0=3; c=z -> nothing.
//        max s0 = 3 = max s1, nonzero and equal              -> w = x
//   t=2  c=0 -> s0=6.  max s0 = 6, max s1 = 3                -> w = 0
//   t=3  c=1 -> s1=6.  max s1 = 6, max s0 = 3                -> w = 1
//   t=4  c=z -> nothing.  back to the weak tie               -> w = x
//   t=5  b=1 -> s1=3; a=1 -> s1=3.  max s1 = 3, max s0 = 0   -> w = 1
//
// Two drivers agreeing (line 5) does not raise the strength — the maximum of
// two 3s is 3 — which is why this line reads 1 and not something else; the
// value is what is observable here, and it is 1 either way.
//
// Today: lines 2 and 3 read x. A third driver cannot break a tie without
// strengths.

`timescale 1ns/1ns
module d03_three_drivers_strength_removal;
  reg a, b, c;
  wire w;

  assign (weak1, weak0) w = a;
  assign (weak1, weak0) w = b;
  assign (strong1, strong0) w = c;

  initial begin
    a = 1'b1; b = 1'b0; c = 1'bz;
    #1 $display("weak_tie %b", w);
    c = 1'b0;
    #1 $display("strong_zero_breaks_tie %b", w);
    c = 1'b1;
    #1 $display("strong_one_breaks_tie %b", w);
    c = 1'bz;
    #1 $display("tie_restored_after_removal %b", w);
    b = 1'b1;
    #1 $display("weak_drivers_agree %b", w);
    $finish(0);
  end
endmodule
