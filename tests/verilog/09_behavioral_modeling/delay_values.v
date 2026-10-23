// IEEE 1364-2005 §9.7.1, p. 132: "A procedural statement following the delay
// control shall be delayed in its execution with respect to the procedural
// statement preceding the delay control by the specified delay. If the delay
// expression evaluates to an unknown or high-impedance value, it shall be
// interpreted as zero delay. If the delay expression evaluates to a negative
// value, it shall be interpreted as a twos-complement unsigned integer of the
// same size as a time variable."
// Example 2's forms: "#d rega = regb;", "#((d+e)/2) rega = regb;",
// "#regr regr = regr + 1;".
//
// Times are in the 1ns unit of the `timescale.
//   #(1'bx), #(1'bz): zero delay         -> printed at 0, 0
//   #d, d = 3                                -> 3
//   #((d+e)/2), e = 5: (3+5)/2 = 4           -> 7
//   #regr, regr = 2, then regr = regr + 1    -> 9, regr = 3
//   #(-1) in a second initial: -1 as a 64-bit unsigned is 2^64 - 1, so its
//   statement cannot run before the $finish at 20 and prints nothing
//! inherited IEEE 1364-2005 9.7.1
`timescale 1ns/1ns
module b_9_7_1_delay_values;
  integer d, e, regr;

  initial begin
    #(1'bx) $display("%0d", $time);
    #(1'bz) $display("%0d", $time);
    d = 3;
    e = 5;
    #d $display("%0d", $time);
    #((d+e)/2) $display("%0d", $time);
    regr = 2;
    #regr regr = regr + 1;
    $display("%0d %0d", $time, regr);
    #11 $finish(0);
  end

  initial #(-1) $display("BAD negative delay ran at %0d", $time);
endmodule
