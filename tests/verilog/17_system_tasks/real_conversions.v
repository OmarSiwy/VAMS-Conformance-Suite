// VAMS 9.4.3, the sentence above Table 9-23: "The format specifications in
// Table 9-23 are used for real numbers and have the full formatting
// capabilities available in the C language." Table 9-23 lists "%e or %E
// Display 'real' in an exponential format", "%f or %F ... in a decimal format"
// and "%g or %G ... whichever format results in the shorter printed output".
// IEEE 1364-2005 17.1.1.2 gives the digital context the same three. So each is
// C11 7.21.6.1's conversion, at C's default precision 6.
//
// HAND DERIVATION, `timescale 1ns/1ps`, $realtime in ns:
//
//  t=0           0.0  %e "0.000000e+00"   %f "0.000000"
//                     %g: exponent X = 0, P = 6 > X >= -4, so style f with
//                     precision P-1-X = 5, "0.00000", trailing zeros and the
//                     point removed -> "0"
//  t=1.5         1.5  %e "1.500000e+00"   %E "1.500000E+00"   %f "1.500000"
//                     %g: X = 0 -> "1.50000" stripped -> "1.5"
//                     %10f: "1.500000" is 8 columns, right-justified in 10
//                     -> "  1.500000"
//                     %14e: "1.500000e+00" is 12 columns -> "  1.500000e+00"
//  t=1234567.25  = 1.5 + 1234565.75, exact in 1 ps ticks and in binary.
//                     %e: 1.23456725e6 to 6 fraction digits -> "1.234567e+06"
//                     %f: "1234567.250000"
//                     %g: X = 6 >= P = 6, so style e with precision P-1 = 5:
//                     1.2345672|5 -> "1.23457e+06" (the case %g exists for)
//
// No value is a rounding tie, so no line depends on the tie-breaking rule.
//! lrm 9.4.3 (Table 9-23)
//! inherited IEEE 1364-2005 17.1.1.2 (%e %f %g in the digital context)
//! expect stdout real_conversions.expected.txt
`timescale 1ns/1ps
module d09_real_conversions;
  initial begin
    $display("[%e][%f][%g]", $realtime, $realtime, $realtime);
    #1.5 $display("[%e][%E][%f][%g]", $realtime, $realtime, $realtime, $realtime);
    $display("[%10f][%14e]", $realtime, $realtime);
    #1234565.75 $display("[%e][%f][%g]", $realtime, $realtime, $realtime);
    $finish(0);
  end
endmodule
