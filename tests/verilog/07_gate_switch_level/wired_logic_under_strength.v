// Verilog-AMS LRM 2.4 annex A.2.2.1 gives `wand`/`wor` as net types and annex
// A.2.2.2 gives the drive strengths; §1.1 makes the combination IEEE Std 1364
// Verilog's clause 7 wired-logic resolution. The wired-logic tables apply only
// between drivers of EQUAL strength. IEEE 1364-2005 7.10.4: "The net types
// triand, wand, trior, and wor shall resolve conflicts when multiple drivers
// have the same strength." 7.10.1: "If two or more signals of unequal strength
// combine in a wired net configuration, the stronger signal shall dominate all
// the weaker drivers and determine the result." (4.6.2's tables are stated
// "assuming equal strengths for both drivers".)
//
// The `highz0` driver's 0 asserts NOTHING: it is z, and z is the identity of
// all three wired tables, so it cannot pull a wand down.
//
// CORRECTED GOLDEN. This file used to assert wa=0 at t=1 and wo=1 at t=2 by
// reading the tables across unequal strengths. Under 7.10.1 both are wrong:
// St1 against We0 on the wand is 1, St0 against We1 on the wor is 0.
//
// Only the resolved VALUE is asserted here. The strength of a wired-logic
// result is not observable from this runner: `%v` is not implemented (see
// specification/CLAUSE-AUDIT.md row 17.1-07) and there are no switch primitives to
// propagate it into (D08).
//
//! lrm annex A.2.2.1
//! lrm annex A.2.2.2
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 4.6.2 6.1.4 7.10.1 7.10.4
//
// HAND DERIVATION
//   wa : wand, drivers (strong1, highz0) a  and (weak1, weak0) b
//   wo : wor,  drivers (strong1, strong0) a and (weak1, weak0) b
//
//   t=1  a=1, b=0:  wa: St1 dominates We0 -> 1  wo: St1 dominates We0 -> 1
//   t=2  a=0, b=1:  a is z through highz0, and z is the wand identity,
//                   so wa = We1 -> 1            wo: St0 dominates We1 -> 0
//   t=3  a=0, b=0:  wa = z AND 0 = 0            wo: St0 and We0 agree -> 0
//   t=4  a=z, b=1:  wa = z AND 1 = 1            wo = z OR 1 = 1

`timescale 1ns/1ns
module d03_wired_logic_under_strength;
  reg a, b;
  wand wa;
  wor wo;

  assign (strong1, highz0) wa = a;
  assign (weak1, weak0) wa = b;
  assign (strong1, strong0) wo = a;
  assign (weak1, weak0) wo = b;

  initial begin
    a = 1'b1; b = 1'b0;
    #1 $display("one_zero %b %b", wa, wo);
    a = 1'b0; b = 1'b1;
    #1 $display("suppressed_zero %b %b", wa, wo);
    a = 1'b0; b = 1'b0;
    #1 $display("zero_zero %b %b", wa, wo);
    a = 1'bz; b = 1'b1;
    #1 $display("float_one %b %b", wa, wo);
    $finish(0);
  end
endmodule
