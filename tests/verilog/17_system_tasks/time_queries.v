// §9.10 Table 9-7 gives $time, $stime and $realtime "Supported in digital
// context: Yes / Supported in analog context: No" — the whole row is digital,
// which is why nothing in lib/backend can stand in for it, and why
// lib/ir/lower.zig:6846 lists all three in `isDigitalOnlySysFunc` as names to
// REFUSE in an analog block. A refusal list is not an implementation. §9.10's
// body confirms Verilog-AMS adds only $abstime here and otherwise inherits
// IEEE Std 1364 Verilog unchanged. The inherited clause is §17.7, "Simulation
// time system functions" — this header said §17.3 until the review, and §17.3
// is *Timescale system tasks* ($printtimescale/$timeformat), which is
// 07_timeformat.v's clause, not this one. The repo's own mapping is
// specification/CLAUSE-AUDIT.md:331-333 (17.7-01 $time, 17.7-02 $stime, 17.7-03
// $realtime) against :323 (17.3-01 $printtimescale/$timeformat).
//
// The inherited definitions this file pins:
//   $time     returns the current simulation time as a 64-bit integer, SCALED
//             to the time unit of the scope that invokes it.
//   $stime    returns the same time as a 32-bit unsigned integer (the low
//             order 32 bits).
//   $realtime returns the same time as a real, with the same scaling.
//
// The word that matters is SCALED. The scheduler counts in the design's finest
// precision; these three functions do not report that count. This module's
// directive is `timescale 10ns/1ns`, so its unit is 10ns and its precision is
// 1ns — a factor of ten apart — which makes the two numbers different and
// makes a runner that simply returns its own tick counter fail.
//
// HAND DERIVATION:
//   unit = 10ns, precision = 1ns, so one unit is 10 scheduler ticks.
//   t=0     : simulation time 0ns = 0 ticks = 0.0 units
//               $time 0, $stime 0, $realtime 0
//   after #3: `#3` is 3 UNITS = 30ns = 30 scheduler ticks
//               $time 3, $stime 3, $realtime 3      (NOT 30)
//   after #4: 3+4 = 7 units = 70ns = 70 scheduler ticks
//               $time 7, $stime 7, $realtime 7      (NOT 70)
//
//   `cap = $time;` stores 7 into a 64-bit reg, rendered as 61 zeros and 111.
//   This observes storage/formatting, NOT the function's return width: a
//   32-bit result zero-extends to exactly the same value. The withdrawn width
//   claim moves to TIME-IEEE-001 in docs/conformance-ieee-tasks-review.md at 8b1514d4 and
//   time_stime_wrap.v, which observes bit32 of the actual time result.
//
//   `ahead = $time + 1;` is 8: the function's result is an ordinary integral
//   operand and participates in arithmetic. `%0d` of 8 is "8".
//
// $realtime is printed with the Table 9-23 "%g or %G Display 'real' in
// exponential or decimal format, whichever format results in the shorter
// printed output" conversion, which §9.4.3 gives "the full formatting
// capabilities available in the C language": C's %g with the default precision
// of 6 renders the exact values 0.0, 3.0 and 7.0 as "0", "3" and "7".
//
// Sub-unit times, where $time and $realtime genuinely disagree, are in
// 06_time_rounding.v; this file deliberately stays on unit boundaries so it
// depends on nothing but integral delays, which the runner already executes.
//
//! lrm 9.10
//! inherited IEEE 1364-2005 17.7 ($time/$stime/$realtime scaling and width)
//! expect stdout 05_time_queries.expected.txt
`timescale 10ns/1ns
module d09_time_queries;
  reg [63:0] cap;
  integer ahead;
  initial begin
    $display("t=%0d s=%0d r=%g", $time, $stime, $realtime);
    #3 $display("t=%0d s=%0d r=%g", $time, $stime, $realtime);
    #4 $display("t=%0d s=%0d r=%g", $time, $stime, $realtime);
    cap = $time;
    ahead = $time + 1;
    $display("cap=%b", cap);
    $display("ahead=%0d", ahead);
    $finish(0);
  end
endmodule
