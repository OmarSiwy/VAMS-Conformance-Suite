// IEEE 1364-2005 §3.4, p. 8: "Operators are single-, double-, or triple-
// character sequences and are used in expressions. ... Unary operators shall
// appear to the left of their operand. Binary operators shall appear between
// their operands. A conditional operator shall have two operator characters
// that separate three operands."
//
// a = 4'b0011 (unsigned). Each $display argument is self-determined:
//   unary, left of the operand: ~a = 1100; -a = 1101 (two's complement,
//     4 bits); &a = 0; |a = 1
//   binary, between the operands: a + 4'd1 = 0100
//   conditional, ? and : separating three operands: (a == 3) ? 4'd9 : 4'd6
//     -> 1001
//   triple-character: a === 4'b0011 -> 1; a !== 4'b0011 -> 0;
//     4'sb1000 >>> 1 (signed, sign-filled, §5.1.12) -> 1100; a <<< 1 -> 0110
// Printed: "1100 1101 0 1 0100 1001 1 0 1100 0110".
//! inherited IEEE 1364-2005 3.4
module b_3_4_operator_positions;
  reg [3:0] a;
  initial begin
    a = 4'b0011;
    $display("%b %b %b %b %b %b %b %b %b %b", ~a, -a, &a, |a, a + 4'd1,
             (a == 3) ? 4'd9 : 4'd6, a === 4'b0011, a !== 4'b0011,
             4'sb1000 >>> 1, a <<< 1);
    $finish(0);
  end
endmodule
