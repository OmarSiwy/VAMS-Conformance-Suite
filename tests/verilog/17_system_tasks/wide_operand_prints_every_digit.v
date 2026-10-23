// IEEE 1364-2005 §17.1.1.3: "For expression arguments, the values written to
// the output file (or terminal) are sized automatically." §17.1.1.7: an
// argument printed with %s is "interpreted as a sequence of 8-bit hexadecimal
// ASCII codes, with each 8 bits representing a single character." §17.3.2
// Syntax 17-10 gives $timeformat a precision_number and a suffix_string. None
// bounds the operand's width, the precision or the suffix. VerA printed
// through a fixed 1024-digit buffer (128 bytes for %t) and panicked past it;
// it now writes every digit.
//
// HAND DERIVATION.
//   b is 1025 bits holding 1 << 1024: "1" and 1024 zeros, 1025 digits.
//   h is 4104 bits holding 1 << 4100: 4104 / 4 = 1026 hex digits; bit 4100
//     is bit 0 of digit 1025, so "1" and 1025 zeros.
//   s is 1025 bytes of 8'h41: %0s prints 1025 "A"s.
//   At #1 in a 1 ns module with $timeformat(-9, 120, " ns", 20), %t is 1
//     with 120 fractional zeros and the suffix: 2 + 120 + 3 = 125 columns,
//     wider than the 20-column minimum, so no padding.
//! inherited IEEE 1364-2005 17.1.1.3 17.1.1.7 17.3.2
//! expect stdout wide_operand_prints_every_digit.expected.txt
`timescale 1ns/1ns
module b_17_1_1_3_wide_operand_prints_every_digit;
  reg [1024:0] b;
  reg [4103:0] h;
  reg [8199:0] s;
  initial begin
    b = 1; b = b << 1024;
    h = 1; h = h << 4100;
    s = {1025{8'h41}};
    $display("%b", b);
    $display("%h", h);
    $display("%0s", s);
    $timeformat(-9, 120, " ns", 20);
    #1 $display("%t", $time);
    $finish(0);
  end
endmodule
