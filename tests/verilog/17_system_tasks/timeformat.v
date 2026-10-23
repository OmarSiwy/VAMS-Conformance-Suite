// §9.6: "Verilog AMS HDL does not extend the timescale tasks defined in IEEE
// Std 1364 Verilog", and Table 9-3 lists exactly two of them — $printtimescale
// and $timeformat — both "Supported in digital context: Yes / Supported in
// analog context: No". lib/ir/lower.zig:6826 carries both names in
// `isDigitalOnlySysFunc`, i.e. VerA today knows only that they are ILLEGAL in
// an analog block. The inherited clause is §17.3, "Timescale system tasks" —
// this header said §17.7 until the review, and §17.7 is *Simulation time system
// functions* ($time/$stime/$realtime), which belongs to 05_time_queries.v and
// 06_time_rounding.v. The repo's own mapping is specification/CLAUSE-AUDIT.md:323
// (17.3-01 "$printtimescale, $timeformat") against :331-333.
//
// The inherited call is
//     $timeformat(units_number, precision, suffix, min_field_width)
// and it sets the four properties of the %t conversion:
//   units_number     the power of ten of the SECOND in which %t reports, so
//                    -9 means report in nanoseconds, -6 in microseconds, -12
//                    in picoseconds;
//   precision        digits after the decimal point;
//   suffix           a string appended after the number;
//   min_field_width  the minimum number of columns, right-justified.
//
// The claim worth pinning is that %t does NOT print the raw integer it is
// handed. It converts the argument from the invoking scope's TIME UNIT into
// the $timeformat unit. This module is `timescale 10ns/1ns`, so the two differ
// by a factor of ten, and the arithmetic is visible in every line.
//
// HAND DERIVATION. After `#3` the simulation is 3 units past zero and one unit
// is 10ns, so the instant is 30ns = 30e-9 s = 0.03e-6 s = 30000e-12 s. $time
// itself is the integer 3 (pinned by 05_time_queries.v); every line below
// hands that same 3 to %t.
//
//   $timeformat(-9,  0, "",    0)  -> 30 ns, 0 decimals, no padding -> "30"
//   $timeformat(-9,  2, "",   10)  -> "30.00" is 5 characters, right-justified
//                                     in 10 -> 5 spaces + "30.00"
//                                            -> "     30.00"
//   $timeformat(-9,  2, " ns", 0)  -> "30.00" then the literal suffix
//                                            -> "30.00 ns"
//   $timeformat(-6,  3, "",    0)  -> 30ns expressed in microseconds is 0.03,
//                                     to 3 decimals            -> "0.030"
//   $timeformat(-12, 0, "",    0)  -> 30ns in picoseconds       -> "30000"
//
// Every min_field_width here is either 0 or paired with an EMPTY suffix, on
// purpose: whether the minimum width counts the suffix characters is a
// question this fixture declines to decide, so it never puts a nonzero width
// and a nonempty suffix in the same call. See tests/fixtures/ch09_system_tasks/d09_SPEC.md at 8b1514d4.
//
// The final line hands %t a literal 1 rather than $time. %t formats a TIME
// VALUE given in the scope's unit, so the 1 means one unit = 10ns and prints
// "10". A runner that special-cases $time, or that treats %t as "the current
// time" and ignores its argument, prints "30" there and fails.
//
//! lrm 9.6
//! lrm 9.6:1000
//! inherited IEEE 1364-2005 17.3 ($timeformat and the %t conversion)
//! expect stdout 07_timeformat.expected.txt
`timescale 10ns/1ns
module d09_timeformat;
  initial begin
    #3;
    $timeformat(-9, 0, "", 0);
    $display("[%t]", $time);
    $timeformat(-9, 2, "", 10);
    $display("[%t]", $time);
    $timeformat(-9, 2, " ns", 0);
    $display("[%t]", $time);
    $timeformat(-6, 3, "", 0);
    $display("[%t]", $time);
    $timeformat(-12, 0, "", 0);
    $display("[%t]", $time);
    $timeformat(-9, 0, "", 0);
    $display("[%t]", 1);
    $finish(0);
  end
endmodule
