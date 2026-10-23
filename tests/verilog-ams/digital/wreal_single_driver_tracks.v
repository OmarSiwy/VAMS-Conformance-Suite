// Verilog-AMS LRM 2.4 §3.7:
//
//   "A wreal net shall not store its value. A wreal net can be used for
//    real-valued nets which are driven by a single driver, such as a continuous
//    assignment."
//
// "shall not store its value" is the whole content of this fixture. A wreal net
// is a WINDOW onto its single driver, not a latch: the moment the driver's
// value changes, the net's value is the new one, and there is no state in the
// net that could hold the old one. The observable consequence is the last two
// lines below — when the driving VARIABLE is set to a value, the net follows,
// and when the driving EXPRESSION's other operand moves, the net follows that
// too, with no assignment to the net anywhere.
//
// This also pins the "real" in wreal: the values are exact IEEE-754 doubles
// carried without conversion. -0.25, 1.5 and 2.5 are all exactly representable
// in binary, so a tool that routed the value through an integer (reading 0, 1,
// 2) or through a four-state vector fails on the fractional digits alone, and
// 1.0/3.0 is included precisely because it is NOT exactly representable: %g
// prints it to six significant digits, which is the same "0.333333" for the
// true double and also for common reduced-precision representations. This
// six-digit transcript checks fractional value propagation, NOT full binary64
// precision; a separate discriminator is required for that claim.
//
//! lrm 3.7
//! lrm 3.7:1
//! timescale 1ns/1ns
//
// HAND DERIVATION — `assign w = src;` and `assign z = src * gain;`
//   t=1  src = 1.5,   gain = 2.0  ->  w = 1.5          z = 1.5*2.0  = 3
//   t=2  src = -0.25              ->  w = -0.25        z = -0.25*2  = -0.5
//   t=3  gain = 4.0               ->  w = -0.25 (the driver did not move, so
//                                     the net does not move either)
//                                     z = -0.25*4.0 = -1
//   t=4  src = 1.0/3.0            ->  w = 0.333333 to six significant digits
//                                     z = (1/3)*4 = 1.33333
//
//   1.0/3.0 in double is 0.333333333333333314829616256247...; %g with the
//   default precision of 6 prints "0.333333". Times four is
//   1.33333333333333325931846502...; %g prints "1.33333".
//   1.5*2.0 = 3.0 exactly -> %g prints "3", not "3.0" (%g strips the trailing
//   zero and the point). -0.25*2.0 = -0.5 exactly. -0.25*4.0 = -1.0 exactly ->
//   "-1".

`timescale 1ns/1ns
module m04_wreal_single_driver_tracks;
  real src;
  real gain;
  wreal w;
  wreal z;

  assign w = src;
  assign z = src * gain;

  initial begin
    src = 1.5; gain = 2.0;
    #1 $display("net_follows_driver %g %g", w, z);
    src = -0.25;
    #1 $display("net_follows_negative_fraction %g %g", w, z);
    gain = 4.0;
    #1 $display("unchanged_driver_leaves_net_alone %g %g", w, z);
    src = 1.0 / 3.0;
    #1 $display("full_double_precision %g %g", w, z);
    $finish(0);
  end
endmodule
