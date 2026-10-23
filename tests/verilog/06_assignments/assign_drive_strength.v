// Verilog-AMS LRM 2.4 annex A.6.1:
//   "continuous_assign ::= assign [ drive_strength ] [ delay3 ]
//    list_of_net_assignments ;"
// annex A.2.2.2:
//   "drive_strength ::= ( strength0 , strength1 ) | ( strength1 , strength0 )
//                     | ( strength0 , highz1 ) | ( strength1 , highz0 )
//                     | ( highz0 , strength1 ) | ( highz1 , strength0 )
//    strength0 ::= supply0 | strong0 | pull0 | weak0
//    strength1 ::= supply1 | strong1 | pull1 | weak1"
//
// The ORDER of those strengths is fixed by §9.22.4 $driver_strength, whose
// Figure 9-3 "Strength value mapping" names eight levels per side —
//   Su 7, St 6, Pu 5, La 4, We 3, Me 2, Sm 1, HiZ 0
// — encoded, per the sentence above the figure, as "bits 5-3 for strength0 and
// bits 2-0 for strength1 (see IEEE Std 1364-2005 Verilog HDL, subclauses 7.10
// and 7.11)". So pull (5) OUTRANKS weak (3), and two drivers of EQUAL strength
// driving opposite values leave the net unknown.
//
// §8.5.3.1 makes each continuous assignment its own process, and annex A.6.1's
// "net_assignment ::= net_lvalue = expression" makes each its own DRIVER; the
// net's value is the resolution of all of its drivers, which is why a strength
// annotation is observable at all.
//
//! lrm annex A.6.1
//! lrm annex A.2.2.2
//! lrm 9.22.4
//! lrm 8.5.3.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 6.1.4 7.10.1
//
// Hand derivation.
//   y has two drivers:  (pull1, pull0) a   and   (weak1, weak0) b
//   w has two drivers:  (strong1, strong0) 1'b1  and  (strong1, strong0) 1'b0
//
//   t=1   a = 1 -> driver A at Pu1, level 5
//         b = 0 -> driver B at We0, level 3
//         5 > 3, the stronger driver wins outright          -> y = 1
//         w's two drivers are both St, level 6, and disagree, so neither wins
//         and the resolved value is unknown                 -> w = x
//   t=11  a := 1'bz at t=10.  A driver of z contributes HiZ (0) regardless of
//         the declared drive strength, so the We0 driver is alone
//                                                           -> y = 0
//   t=21  a := 1'b0, b := 1'b1 at t=20.  Both polarities are now the reverse
//         of t=1: driver A at Pu0, level 5; driver B at We1, level 3
//         5 > 3, the stronger driver still wins             -> y = 0
//         w unchanged by anything in this module, throughout -> w = x
//
// CORRECTED AFTER REVIEW — what actually discriminates here, and what does not.
//
// The t=11 line does NOT discriminate, and the previous version of this header
// wrongly said it was the line that did. At t=11 `a` is z and `b` is 0, and a
// resolver with no strength model at all already gives 0 for z-vs-0: z loses to
// any driven value under plain four-state resolution. The line is kept because
// it pins a separate claim — that a z VALUE overrides a non-HiZ declared
// STRENGTH, so Pu1 does not survive `a` going z — but it is not evidence of a
// strength ORDERING and is no longer presented as such.
//
// The lines with teeth are:
//   t1  y=1   strength-blind resolution of 1-vs-0 is x, not 1; "last driver
//             wins" (the `b` assignment is later in source order) gives 0.
//             Only Pu(5) > We(3) yields 1.
//   t21 y=0   the same two drivers with both polarities swapped. Strength-blind
//             is again x; "last driver wins" is now 1; a "1 beats 0" or
//             wired-or rule is 1. Only a model in which the WINNER TRACKS THE
//             STRENGTH rather than the value yields 0. t1 and t21 together
//             cannot both be produced by any value-biased rule, and t21 is the
//             line added by this correction to replace the t=11 claim.
//   w=x       on every line: two equal, opposing St drivers must resolve to x,
//             which is what "last driver wins" (0) cannot produce.

`timescale 1ns/1ns
module assign_drive_strength;
  reg a, b;
  wire y;
  wire w;

  assign (pull1, pull0) y = a;
  assign (weak1, weak0) y = b;
  assign (strong1, strong0) w = 1'b1;
  assign (strong1, strong0) w = 1'b0;

  initial begin
    a = 1'b1; b = 1'b0;
    #1 #0 $display("t1 y=%b w=%b", y, w);
    #9 a = 1'bz;
    #1 #0 $display("t11 y=%b w=%b", y, w);
    #9 a = 1'b0; b = 1'b1;
    #1 #0 $display("t21 y=%b w=%b", y, w);
    $finish(0);
  end
endmodule
