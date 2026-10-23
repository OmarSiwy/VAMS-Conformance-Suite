// IEEE 1364-2005 §5.1.7, p. 48: "When one or both operands of a relational
// expression are unsigned, the expression shall be interpreted as a comparison
// between unsigned values. If the operands are of unequal bit lengths, the
// smaller operand shall be zero-extended to the size of the larger operand.
// When both operands are signed, the expression shall be interpreted as a
// comparison between signed values. If the operands are of unequal bit
// lengths, the smaller operand shall be sign-extended to the size of the
// larger operand. If either operand is a real operand, then the other operand
// shall be converted to an equivalent real value" ... "Relational operators
// shall have lower precedence than arithmetic operators."
//
//   -1 < 4'd3          4'd3 unsigned -> unsigned 32-bit compare:
//                      32'hFFFFFFFF < 3 -> 0
//   4'sb1111 < 8'sd1   both signed; 4'sb1111 sign-extends to 8'sb11111111
//                      = -1; -1 < 1 -> 1
//   4'b1111 < 8'd1     unsigned; zero-extends to 8'd15; 15 < 1 -> 0
//   4'sb1000 >= 8'sd0  -8 >= 0 -> 0
//   4'b1000 >= 8'd0    8 >= 0 -> 1
//   1.5 > 1            1 -> 1.0; 1.5 > 1.0 -> 1
//   4'b1x00 < 4'd3     an x operand bit -> 1'bx
// The clause's precedence example with foo = 5, a = 4:
//   a < foo - 1        = a < (foo - 1) = 4 < 4 -> 0
//   foo - (1 < a)      = 5 - 1 -> 4
//   foo - 1 < a        = (5 - 1) < 4 -> 0
//! inherited IEEE 1364-2005 5.1.7
module b_5_1_7_relational_extension;
  integer foo, a;
  initial begin
    foo = 5;
    a = 4;
    $display("%b%b%b%b%b%b%b", -1 < 4'd3, 4'sb1111 < 8'sd1, 4'b1111 < 8'd1,
             4'sb1000 >= 8'sd0, 4'b1000 >= 8'd0, 1.5 > 1, 4'b1x00 < 4'd3);
    $display("%0d %0d %0d", a < foo - 1, foo - (1 < a), foo - 1 < a);
    $finish(0);
  end
endmodule
