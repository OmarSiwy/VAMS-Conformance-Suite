// IEEE 1364-2005 §17.1.1.3: "For expression arguments, the values written to
// the output file (or terminal) are sized automatically", and the clause
// sizes a decimal field by the largest value the operand can hold, at any
// width. VerA refused a known %d operand wider than 64 bits (E1100) until
// 2026-10 (#29); it now prints every digit.
//
// HAND DERIVATION. A %d field is the digit count of the operand's largest
// value: 2^n - 1 unsigned, -2^(n-1) signed (one column for the sign).
//   r is 65 bits holding 2^64 = 18446744073709551616 (20 digits). Field:
//     2^65 - 1 = 36893488147419103231, 20 columns. No padding.
//   r - 1 is a 65-bit expression worth 2^64 - 1 = 18446744073709551615; %0d
//     prints no padding.
//   s is signed 65 bits. Field: -2^64 = -18446744073709551616, 21 columns.
//     s = -1: "-1" behind 19 spaces. s = 1 << 64 sets the sign bit alone:
//     -2^64, exactly 21 columns.
//   q is 128 bits of ones: 2^128 - 1 = 340282366920938463463374607431768211455
//     (39 digits, 39 columns). The default $display radix is decimal, so
//     $display(q) prints the same line.
//   k is 1001 bits holding 2^1000, printed with %0d: its 302 digits (2^1000
//     by repeated doubling, also `python3 -c 'print(2**1000)'`).
//   With r[3] = x, r holds one x bit among known bits: §17.1.1.4 prints "X"
//     right-justified in r's 20 columns.
//! inherited IEEE 1364-2005 17.1.1.3
//! expect stdout decimal_over_64_bits.expected.txt
module b_17_1_1_3_decimal_over_64_bits;
  reg [64:0] r;
  reg signed [64:0] s;
  reg [127:0] q;
  reg [1000:0] k;
  initial begin
    r = 1; r = r << 64;
    $display("%d", r);
    $display("%0d", r - 1);
    s = -1;
    $display("%d", s);
    s = 1; s = s << 64;
    $display("%d", s);
    q = ~128'd0;
    $display("%d", q);
    $display(q);
    k = 1; k = k << 1000;
    $display("%0d", k);
    r[3] = 1'bx;
    $display("%d", r);
  end
endmodule
