// IEEE 1364-2005 §17.1.1.3 sizes a displayed value by the largest value its
// expression can take; §4.8.2 converts a real to an integer by rounding, half
// away from zero. Neither clause, nor VAMS §9.4.3, says how wide the integer
// a real becomes under %d is, so the field width is VerA's choice
// (specification/Vague_Decisions.md VD-120): the digital engine reads a real
// in an integral context as a 64-bit signed integer (evaluate.zig `eval`),
// and %d sizes that like any other operand. The `%0d` line is the clause's
// own escape from automatic sizing; the `$rtoi` line is the contrast: §17.8
// returns an `integer`, 32 bits signed.
//
// HAND DERIVATION. A signed n-bit field holds -2^(n-1), its digits plus a
// sign column: n = 64 -> 9223372036854775808 is 19 digits, 20 columns;
// n = 32 -> 2147483648 is 10 digits, 11 columns.
//   %d   of 7 / 2.0   3.5 rounds away from zero to 4: 19 spaces, "4"
//   %0d  of 7 / 2.0   no automatic size                -> [4]
//   %d   of -2.5      rounds to -3: 18 spaces, "-3"
//   %d   of -9.2e18   exact in a double (92 * 10^17 is a multiple of 1024,
//                     the spacing below 2^63), so the 20 characters
//                     -9200000000000000000 fill the field with no space
//   %d   of $rtoi(3.5)  truncates to 3, an integer: 10 spaces, "3"
//! inherited IEEE 1364-2005 17.1.1.3
//! expect stdout decimal_of_real_width.expected.txt
module b_17_1_1_3_decimal_of_real_width;
  real r;
  initial begin
    r = -9.2e18;
    $display("[%d]", 7 / 2.0);
    $display("[%0d]", 7 / 2.0);
    $display("[%d]", -2.5);
    $display("[%d]", r);
    $display("[%d]", $rtoi(3.5));
  end
endmodule
