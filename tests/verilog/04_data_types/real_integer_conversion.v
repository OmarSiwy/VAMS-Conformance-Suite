// IEEE 1364-2005 §4.8.2, pp. 33-34: "Real numbers shall be converted to
// integers by rounding the real number to the nearest integer, rather than by
// truncating it. Implicit conversion shall take place when a real number is
// assigned to an integer. If the fractional part of the real number is
// exactly 0.5, it shall be rounded away from zero. Implicit conversion shall
// take place when an expression is assigned to a real. Individual bits that
// are x or z in the net or the variable shall be treated as zero upon
// conversion."
//
// Into integer i (printed %0d):
//   1.4 -> 1;  1.6 -> 2;  -1.6 -> -2;  2.5 -> 3;  -2.5 -> -3;  0.5 -> 1
// Into real r (printed %f), from reg [3:0] v = 4'b1101 -> 13.000000
// (x and z bits: unknown_bits_to_real.v)
//! inherited IEEE 1364-2005 4.8.2
module b_4_8_2_real_integer_conversion;
  integer i;
  real r;
  reg [3:0] v;
  initial begin
    i = 1.4;  $write("%0d ", i);
    i = 1.6;  $write("%0d ", i);
    i = -1.6; $write("%0d ", i);
    i = 2.5;  $write("%0d ", i);
    i = -2.5; $write("%0d ", i);
    i = 0.5;  $display("%0d", i);
    v = 4'b1101; r = v; $display("%f", r);
    $finish(0);
  end
endmodule
