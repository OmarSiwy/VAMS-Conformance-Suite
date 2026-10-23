// The sub-unit half of §9.10 / inherited IEEE 1364-2005 §17.7 (Simulation time
// system functions): what $time returns when the simulation is NOT sitting on a
// whole time unit. $time is an integer and $realtime is a real, so at a
// half-unit instant they must disagree, and the direction of that disagreement
// is a rounding rule. (This header cited §17.3 until the review; §17.3 is
// *Timescale system tasks* and belongs to 07_timeformat.v. Mapping:
// specification/CLAUSE-AUDIT.md:331-333 vs :323.)
//
// The rounding rule is the one docs/digital-time.md already records for this
// repo from §§4.8 and 4.8.2 — "nearest-integer real conversion, with exact
// halves rounded away from zero" — and which src/sim/time.zig implements for
// delays. $time applies the same conversion on the way OUT that a delay
// applies on the way in.
//
// HAND DERIVATION, `timescale 10ns/100ps`:
//   unit = 10ns, precision = 100ps, so one unit is 100 scheduler ticks and a
//   delay of 0.5 units is exactly representable (5ns = 50 ticks). Nothing in
//   this file depends on binary64 tie-breaking of the DELAY: 0.5 and 1.0 are
//   both exact in binary64 and both land on exact tick counts.
//
//   after #0.5 : 5ns  = 0.5 units
//                  $realtime = 0.5
//                  $time     = round(0.5) = 1   (exact half, away from zero)
//   after #1   : 15ns = 1.5 units
//                  $realtime = 1.5
//                  $time     = round(1.5) = 2   (exact half, away from zero)
//   after #0.5 : 20ns = 2.0 units
//                  $realtime = 2
//                  $time     = 2
//
// The last two lines are the assertion that matters: $time reads 2 at two
// DIFFERENT simulation instants (15ns and 20ns), while $realtime separates
// them. A runner that truncates instead of rounding prints 1, 1, 2; a runner
// that returns the precision tick count prints 50, 150, 200; a runner that
// returns the tick count scaled by the wrong factor prints 5, 15, 20. All
// three are distinguishable from the expected 1, 2, 2.
//
// %g renders the three reals with C's default precision 6: 0.5 -> "0.5",
// 1.5 -> "1.5", 2.0 -> "2" (§9.4.3 Table 9-23 plus "the full formatting
// capabilities available in the C language").
//
// NOTE ON THE DEPENDENCY. This file needs REAL procedural delays, which
// src/sim/digital.zig does not yet convert — its delay path calls only
// `signedDelay`/`unsignedDelay` (digital.zig:979), never `realDelay`, though
// src/sim/time.zig already implements `realDelay` with exactly the rounding
// above and docs/digital-time.md already justifies it. So this fixture is
// gated on wiring that existing utility into the runner as well as on the time
// queries themselves. It is kept separate from 05_time_queries.v for that
// reason: 05 can go green the day $time lands, this one needs both.
//
//! lrm 9.10
//! inherited IEEE 1364-2005 17.7 ($time rounding to the local time unit)
//! expect stdout 06_time_rounding.expected.txt
`timescale 10ns/100ps
module d09_time_rounding;
  initial begin
    #0.5 $display("a t=%0d r=%g", $time, $realtime);
    #1   $display("b t=%0d r=%g", $time, $realtime);
    #0.5 $display("c t=%0d r=%g", $time, $realtime);
    $finish(0);
  end
endmodule
