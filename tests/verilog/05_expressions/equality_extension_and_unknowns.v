// IEEE 1364-2005 §5.1.8, p. 49: "The equality operators shall rank lower in
// precedence than the relational operators." ... "If the operands are of
// unequal bit lengths and if one or both operands are unsigned, the smaller
// operand shall be zero-extended to the size of the larger operand. If both
// operands are signed, the smaller operand shall be sign-extended to the size
// of the larger operand." ... "For the logical equality and logical
// inequality operators (== and !=), if, due to unknown or high-impedance bits
// in the operands, the relation is ambiguous, then the result shall be a 1-bit
// unknown value (x)." ... "Bits that are x or z shall be included in the
// comparison and shall match for the result to be considered equal. The
// result of these operators shall always be a known value, either 1 or 0."
//
// ext:  4'b1010 == 8'b00001010     zero-extend -> 0000_1010 == 0000_1010 -> 1
//       4'sb1010 == 8'sb11111010   sign-extend -> 1111_1010 == 1111_1010 -> 1
//       4'b1010 == 8'sb11111010    one unsigned -> zero-extend:
//                                  0000_1010 vs 1111_1010 -> 0
// x/z:  4'b1x10 == 4'b1010         bit 2 unknown, others equal: ambiguous -> x
//       4'b1x10 == 4'b0010         bit 3 is 1 vs 0: unequal whatever x is -> 0
//       4'b1x10 != 4'b0010         -> 1
//       4'b1z10 != 4'b1010         ambiguous -> x
// case: 4'b1x10 === 4'b1x10 -> 1;  4'b1z10 === 4'b1x10 -> 0 (z does not match x)
//       4'b1z10 !== 4'b1x10 -> 1;  4'b10x0 !== 4'b10x0 -> 0
// real: 2.0 == 2 -> 2 converted to 2.0 -> 1
// prec: 1 == 2 > 1   relational first: 1 == (1) -> 1
//                    (the other grouping, (1==2) > 1 = 0 > 1, gives 0)
//! inherited IEEE 1364-2005 5.1.8
module b_5_1_8_equality_extension_and_unknowns;
  initial begin
    $display("ext=%b%b%b", 4'b1010 == 8'b00001010, 4'sb1010 == 8'sb11111010, 4'b1010 == 8'sb11111010);
    $display("xz=%b%b%b%b", 4'b1x10 == 4'b1010, 4'b1x10 == 4'b0010, 4'b1x10 != 4'b0010, 4'b1z10 != 4'b1010);
    $display("case=%b%b%b%b", 4'b1x10 === 4'b1x10, 4'b1z10 === 4'b1x10, 4'b1z10 !== 4'b1x10, 4'b10x0 !== 4'b10x0);
    $display("real=%b prec=%b", 2.0 == 2, 1 == 2 > 1);
    $finish(0);
  end
endmodule
