// IEEE 1364-2005 A.8.7, p. 506-507:
//   number ::= decimal_number | octal_number | binary_number | hex_number | real_number
//   real_number ::= unsigned_number . unsigned_number
//     | unsigned_number [ . unsigned_number ] exp [ sign ] unsigned_number
//   exp ::= e | E
//   decimal_number ::= unsigned_number | [ size ] decimal_base unsigned_number
//     | [ size ] decimal_base x_digit { _ } | [ size ] decimal_base z_digit { _ }
//   binary_number ::= [ size ] binary_base binary_value
//   octal_number ::= [ size ] octal_base octal_value
//   hex_number ::= [ size ] hex_base hex_value
//   sign ::= + | -
//   size ::= non_zero_unsigned_number
//   non_zero_unsigned_number ::= non_zero_decimal_digit { _ | decimal_digit}
//   unsigned_number ::= decimal_digit { _ | decimal_digit }
//   binary_value ::= binary_digit { _ | binary_digit }
//   octal_value ::= octal_digit { _ | octal_digit }
//   hex_value ::= hex_digit { _ | hex_digit }
//   decimal_base ::= '[s|S]d | '[s|S]D
//   binary_base ::= '[s|S]b | '[s|S]B
//   octal_base ::= '[s|S]o | '[s|S]O
//   hex_base ::= '[s|S]h | '[s|S]H
//   non_zero_decimal_digit ::= 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
//   decimal_digit ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
//   binary_digit ::= x_digit | z_digit | 0 | 1
//   octal_digit ::= x_digit | z_digit | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
//   hex_digit ::= x_digit | z_digit | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
//     |a|b|c|d|e|f|A|B|C|D|E|F
//   x_digit ::= x | X
//   z_digit ::= z | Z | ?
//
// Line 1, integers in decimal:
//   1_000        unsigned_number with an underscore: 1000
//   8'd2_5       sized decimal: 25
//   'D7          unsized, capital base: 7
//   4'sd7 + 4'sD1  signed decimal bases: 8 read as 4-bit signed 1000 = -8
//   12'o7_7      octal: 63;  6'O17: 15
//   8'hF_f       hex, both cases: 255;  'H1A: 26
//   8'sh80       signed hex: -128
// Line 2, x/z digits, in binary (%b):
//   4'bx0_1?     binary with x_digit and the z_digit ?: x01z
//   4'dx         decimal x_digit: xxxx;  4'DZ_: decimal z_digit and a _: zzzz
//   8'B1010_zZXx: 1010zzxx;  6'o7?: 111zzz;  8'hxA: xxxx1010
// Line 3, reals (%g):
//   1.5, 2e3 (exp, no fraction: 2000), 2.5E-1 (0.25), 1_2.5e+1 (125)
// Output: "1000 25 7 -8 63 15 255 26 -128" then
// "x01z xxxx zzzz 1010zzxx 111zzz xxxx1010" then "1.5 2000 0.25 125".
//! inherited IEEE 1364-2005 A.8.7
module b_A_8_7_numbers;
  reg signed [3:0] s4;
  reg signed [7:0] s8;
  initial begin
    s4 = 4'sd7 + 4'sD1;
    s8 = 8'sh80;
    $display("%0d %0d %0d %0d %0d %0d %0d %0d %0d",
             1_000, 8'd2_5, 'D7, s4, 12'o7_7, 6'O17, 8'hF_f, 'H1A, s8);
    $display("%b %b %b %b %b %b", 4'bx0_1?, 4'dx, 4'DZ_, 8'B1010_zZXx, 6'o7?, 8'hxA);
    $display("%g %g %g %g", 1.5, 2e3, 2.5E-1, 1_2.5e+1);
    $finish(0);
  end
endmodule
