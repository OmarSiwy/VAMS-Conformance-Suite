// IEEE 1364-2005 §3.5.3, p. 12: "Real numbers shall be converted to integers
// by rounding the real number to the nearest integer, rather than by
// truncating it. Implicit conversion shall take place when a real number is
// assigned to an integer. The ties shall be rounded away from zero. For
// example: The real numbers 35.7 and 35.5 both become 36 when converted to
// an integer and 35.2 becomes 35. Converting -1.5 to integer yields -2,
// converting 1.5 to integer yields 2."
//
// The clause's five values: 35.7 -> 36, 35.5 -> 36, 35.2 -> 35, -1.5 -> -2,
// 1.5 -> 2. Ties away from zero, not to even: 2.5 -> 3, -2.5 -> -3.
// Nearest, not truncated, below zero: -35.7 -> -36.
// A reg converts by the same general rule, §4.8.2, p. 33: "Real numbers shall
// be converted to integers by rounding the real number to the nearest
// integer" (and §5.5.1, p. 65, "Reals converted to integers by type coercion
// are signed"): q = 7.5 -> 8 = 1000.
//! inherited IEEE 1364-2005 3.5.3
module b_3_5_3_real_to_integer_rounding;
  integer i1, i2, i3, i4, i5, i6, i7, i8;
  reg [3:0] q;
  initial begin
    i1 = 35.7; i2 = 35.5; i3 = 35.2; i4 = -1.5; i5 = 1.5;
    i6 = 2.5; i7 = -2.5; i8 = -35.7;
    q = 7.5;
    $display("%0d %0d %0d %0d %0d", i1, i2, i3, i4, i5);
    $display("%0d %0d %0d %b", i6, i7, i8, q);
    $finish(0);
  end
endmodule
