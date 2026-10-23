// VAMS §9.2 Table 9-7 gives `$abstime` "Supported in digital context: Yes",
// and §9.10: "$abstime returns the absolute time, that is a real value number
// representing time in seconds". Table 9-11 gives `$ln1p` and `$expm1` the
// same Yes; §9.14 makes them aliases of §4.3.1's ln1p(x) = ln(1 + x) and
// expm1(x) = exp(x) - 1. Before #58 the digital engine refused all three as
// "this digital expression form is not implemented".
//   `timescale 1ns/1ps, #1.5: 1.5 ns = 1500 ticks of 1 ps -> $abstime = 1.5e-9,
//     which %g prints as 1.5e-09
//   $ln1p(0.5) = ln 1.5 = 0.405465108...  -> %g 0.405465
//   $expm1(0.5) = e^0.5 - 1 = 0.648721270... -> %g 0.648721
//   $ln1p(1e-20) and $expm1(1e-20): x - x^2/2 + ... and x + x^2/2 + ... are
//     1e-20 to double precision (1 + 1e-20 would round to 1 and give 0), so
//     %g prints 1e-20 for each
//! lrm 9.10
//! lrm 9.14
//! lrm 9.2
`timescale 1ns/1ps
module vams_digital_abstime_math;
  initial begin
    #1.5 $display("%g", $abstime);
    $display("%g %g", $ln1p(0.5), $expm1(0.5));
    $display("%g %g", $ln1p(1e-20), $expm1(1e-20));
    $finish(0);
  end
endmodule
