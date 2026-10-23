// IEEE 1364-2005 §17.1.1.3, p. 282: "When displaying decimal values, leading
// zeros are suppressed and replaced by spaces. In other radices, leading
// zeros are always displayed. The automatic sizing of displayed data can be
// overridden by inserting a zero between the % character and the letter that
// indicates the radix"
//
// The clause's module printval, reg [11:0] r1 = 10: a 12-bit value is up to
// 4095 (four decimal columns) and FFF (three hex columns), so
//   "Printing with maximum size - :  10: :00a:"
// and with %0d / %0h, "two columns and one column, respectively":
//   "Printing with minimum size - :10: :a:"
// The same override on 16-bit c = 1 in binary and octal: %0b -> 1, %0o -> 1.
//! inherited IEEE 1364-2005 17.1.1.3
module b_17_1_1_3_zero_width_format;
  reg [11:0] r1;
  reg [15:0] c;
  initial begin
    r1 = 10;
    c = 1;
    $display( "Printing with maximum size - :%d: :%h:", r1,r1 );
    $display( "Printing with minimum size - :%0d: :%0h:", r1,r1 );
    $display("%0b %0o", c, c);
    $finish(0);
  end
endmodule
