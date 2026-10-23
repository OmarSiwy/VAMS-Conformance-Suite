// IEEE 1364-2005 §5.1.3, p. 44: "A negative value for an integer with no base
// specifier shall be interpreted differently from an integer with a base
// specifier. An integer with no base specifier shall be interpreted as a
// signed value in twos-complement form. An integer with an unsigned base
// specifier shall be interpreted as an unsigned value."
//
// The clause's own four assignments to integer IntA (32-bit signed):
//   -12 / 3: signed; -12/3 = -4.
//   -'d 12 / 3: 'd12 is unsized unsigned (integer size, 32 here), so it is
//      unsigned (§5.5.1): -12 mod 2**32 = 4294967284; /3 = 1431655761.33,
//      truncated -> 1431655761 (< 2**31, so IntA prints it unchanged).
//   -'sd 12 / 3: signed; -4.
//   -4'sd 12 / 3: 4'sd12 = 4'b1100, signed, = -4. The operands are sized to
//      32 bits (IntA and the literal 3) and all signed, so 4'sd12 is
//      sign-extended to -4; -(-4) = 4; 4/3 = 1.
// The clause gives all four results: -4, 1431655761, -4, 1.
//! inherited IEEE 1364-2005 5.1.3
module b_5_1_3_integer_number_signedness;
  integer IntA;
  initial begin
    IntA = -12 / 3;
    $display("%0d", IntA);
    IntA = -'d 12 / 3;
    $display("%0d", IntA);
    IntA = -'sd 12 / 3;
    $display("%0d", IntA);
    IntA = -4'sd 12 / 3;
    $display("%0d", IntA);
    $finish(0);
  end
endmodule
