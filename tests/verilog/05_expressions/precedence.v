// IEEE 1364-2005 §5.1.2, p. 43: "Operators shown on the same row in Table 5-4
// shall have the same precedence. Rows are arranged in order of decreasing
// precedence for the operators." ... "All operators shall associate left to
// right with the exception of the conditional operator, which shall associate
// right to left." ... "When operators differ in precedence, the operators
// with higher precedence shall associate first."
//
// Each line is chosen so the Table 5-4 grouping and the wrong one differ.
// Integer operands are 32-bit signed; printed with %0d.
//   10 - 4 - 3      left:  (10-4)-3 = 3          right: 10-(4-3) = 9
//   1 + 6 / 3       / first: 1+2 = 3             (1+6)/3 = 2
//   (1 + 6) / 3     parentheses: 7/3 = 2
//   2 * 3 ** 2      ** first: 2*9 = 18           (2*3)**2 = 36
//   2 ** 3 ** 2     left:  (2**3)**2 = 64        right: 2**(3**2) = 512
//   -2 ** 2         unary first: (-2)**2 = 4     -(2**2) = -4
//   !0 + 1          unary first: 1+1 = 2         !(0+1) = 0
//   1 << 1 + 1      + first: 1<<2 = 4            (1<<1)+1 = 3
//   8 >> 1 > 3      >> first: 4>3 = 1            8>>(1>3) = 8>>0 = 8
//   3 == 2 < 1      < first: 3==(0) = 0          (3==2)<1 = 0<1 = 1
//   1 ? 2 : 0 ? 3 : 4   right: 1?2:(0?3:4) = 2   left: (1?2:0)?3:4 = 2?3:4 = 3
//   1 || 0 && 0     && first: 1||0 = 1           (1||0)&&0 = 0
// Bitwise rows on 4-bit operands (printed with %b, 4 bits):
//   4'b1100 | 4'b1010 & 4'b0110    & first: 1100|0010 = 1110
//                                  left: 1110&0110 = 0110
//   4'b1100 ^ 4'b1010 & 4'b0110    & first: 1100^0010 = 1110
//                                  left: 0110&0110 = 0110
//   4'b1100 | 4'b1010 ^ 4'b0110    ^ first: 1100|1100 = 1100
//                                  left: 1110^0110 = 1000
//   4'b0110 & 4'b0110 == 4'b0110   == first: 0110 & (1), the 1-bit result
//                                  zero-extended to 4 bits (Table 5-22,
//                                  max(L(i),L(j))): 0110&0001 = 0000
//                                  left: (0110)==0110 = 1 -> 0001
//! inherited IEEE 1364-2005 5.1.2
module b_5_1_2_precedence;
  initial begin
    $display("%0d %0d %0d %0d %0d %0d %0d", 10 - 4 - 3, 1 + 6 / 3, (1 + 6) / 3, 2 * 3 ** 2, 2 ** 3 ** 2, -2 ** 2, !0 + 1);
    $display("%0d %0d %0d %0d %0d", 1 << 1 + 1, 8 >> 1 > 3, 3 == 2 < 1, 1 ? 2 : 0 ? 3 : 4, 1 || 0 && 0);
    $display("%b %b %b %b", 4'b1100 | 4'b1010 & 4'b0110, 4'b1100 ^ 4'b1010 & 4'b0110,
             4'b1100 | 4'b1010 ^ 4'b0110, 4'b0110 & 4'b0110 == 4'b0110);
    $finish(0);
  end
endmodule
