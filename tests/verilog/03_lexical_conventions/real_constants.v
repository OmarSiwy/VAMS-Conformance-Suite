// IEEE 1364-2005 §3.5.2, p. 12: "The real constant numbers shall be
// represented as described by IEEE Std 754-1985, an IEEE standard for
// double-precision floating-point numbers. Real numbers can be specified in
// either decimal notation (for example, 14.72) or in scientific notation (for
// example, 39e8, which indicates 39 multiplied by 10 to the eighth power).
// Real numbers expressed with a decimal point shall have at least one digit
// on each side of the decimal point."
//
// The clause's valid forms, printed with %f (6 decimals) or %e:
//   14.72 -> 14.720000; 39e8 = 3.9e9 -> 3.900000e+09; 1.2 -> 1.200000;
//   0.1 -> 0.100000; 2394.26331 -> 2394.263310; 1.2E12 -> 1.200000e+12;
//   1.30e-2 -> 1.300000e-02; 0.1e-0 -> 0.100000; 23E10 -> 2.300000e+11;
//   29E-2 -> 0.290000; 236.123_763_e-12 -> 2.361238e-10, and it equals
//   236.123763e-12 because "underscores are ignored" -> 1
// Double precision, not single or extended:
//   0.1 + 0.2 == 0.3 is false in binary64 (0.30000000000000004 vs
//     0.29999999999999999) -> 0 (in binary32 the two sides round alike)
//   2**53 + 1 is not representable in binary64, so
//     9007199254740992.0 + 1.0 == 9007199254740992.0 -> 1
//     (an 80-bit extended format would hold the +1)
//! inherited IEEE 1364-2005 3.5.2
module b_3_5_2_real_constants;
  initial begin
    $display("%f %e %f %f %f", 14.72, 39e8, 1.2, 0.1, 2394.26331);
    $display("%e %e %f %e %f", 1.2E12, 1.30e-2, 0.1e-0, 23E10, 29E-2);
    $display("%e %b", 236.123_763_e-12, 236.123_763_e-12 == 236.123763e-12);
    $display("%b %b", 0.1 + 0.2 == 0.3, 9007199254740992.0 + 1.0 == 9007199254740992.0);
    $finish(0);
  end
endmodule
