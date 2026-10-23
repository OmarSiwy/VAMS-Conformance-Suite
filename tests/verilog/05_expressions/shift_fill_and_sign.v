// IEEE 1364-2005 §5.1.12, p. 53: "The left shift operators, << and <<<, shall
// shift their left operand to the left by the number by the number of bit
// positions given by the right operand. In both cases, the vacated bit
// positions shall be filled with zeroes." ... "The logical right shift shall
// fill the vacated bit positions with zeroes. The arithmetic right shift shall
// fill the vacated bit positions with zeroes if the result type is unsigned.
// It shall fill the vacated bit positions with the value of the most
// significant (i.e., sign) bit of the left operand if the result type is
// signed. If the right operand has an x or z value, then the result shall be
// unknown. The right operand is always treated as an unsigned number and has
// no effect on the signedness of the result. The result signedness is
// determined by the left-hand operand and the remainder of the expression, as
// outlined in 5.5.1."
//
// The clause's examples: start = 1, start << 2 -> 0100;
//   signed start = 4'b1000, start >>> 2 -> 1110 (sign-filled).
// Unsigned left operand: 4'b1000 >>> 2 -> 0010 (zero fill); >> -> 0010.
// Left shifts fill zeros whatever the sign: 4'sb1001 <<< 1 -> 0010, << 1 -> 0010.
// x/z in the right operand: 4'b0001 << 1'bx -> xxxx, 4'b0001 >> 2'bz1 -> xxxx.
// Right operand unsigned: 3'sb100 read unsigned is 4 (signed it would be -4),
//   so 8'b1 << 3'sb100 -> 0000_0001 shifted 4 places -> 00010000.
// Right operand does not make the result signed: u >>> 4'sb0001 with
//   u = 4'b1000 (unsigned) -> 0100.
// Remainder of the expression: s8 = ($signed(4'b1000) >>> 1) + 8'd0.
//   8'd0 is unsigned, so the + and its context-determined operands are
//   8-bit unsigned (§5.5.1, §5.5.2); $signed(4'b1000) is a primary, so it
//   is zero-extended to 0000_1000; >>> on an unsigned result zero-fills:
//   0000_0100; + 0 -> 00000100.
// Same without the unsigned operand: s8 = $signed(4'b1000) >>> 1 into a
//   signed 8-bit s8: signed, sign-extended to 1111_1000, >>> 1 -> 11111100.
//! inherited IEEE 1364-2005 5.1.12
module b_5_1_12_shift_fill_and_sign;
  reg [3:0] start, result, u;
  reg signed [3:0] sstart;
  reg signed [7:0] s8;
  reg [7:0] u8;
  initial begin
    start = 1;
    result = (start << 2);
    $display("%b", result);
    sstart = 4'b1000;
    result = (sstart >>> 2);
    $display("%b", result);
    u = 4'b1000;
    $display("%b %b %b %b", u >>> 2, u >> 2, 4'sb1001 <<< 1, 4'sb1001 << 1);
    $display("%b %b %b", 4'b0001 << 1'bx, 4'b0001 >> 2'bz1, 8'b1 << 3'sb100);
    $display("%b", u >>> 4'sb0001);
    u8 = ($signed(4'b1000) >>> 1) + 8'd0;
    s8 = $signed(4'b1000) >>> 1;
    $display("%b %b", u8, s8);
    $finish(0);
  end
endmodule
