// IEEE 1364-2005 §5.5.2, pp. 65-66: "In general, any context-determined
// operand of an operator shall be the same type and size as the result of the
// operator. However, there are two exceptions: — If the result type of the
// operator is real and if it has a context-determined operand that is not
// real, that operand shall be treated as if it were self-determined and then
// converted to real just before the operator is applied. — The relational and
// equality operators have operands that are neither fully self-determined nor
// fully context-determined. The operands shall affect each other as if they
// were context-determined operands with a result type and size (maximum of
// the two operand sizes) determined from them. However, the actual result
// type shall always be 1 bit unsigned. The type and size of the operand shall
// be independent of the rest of the expression and vice versa."
//
// Real exception: (4'd15 + 4'd1) + 0.5. The outer + is real (0.5 is real),
//   so its non-real operand (4'd15 + 4'd1) is self-determined: 4 bits,
//   16 mod 16 = 0; converted to 0.0; + 0.5 -> 0.500000.
// Relational/equality operands size each other:
//   (4'd15 + 4'd1) == 5'd16: sized max(4,5) = 5 bits, 15 + 1 = 16 -> 1
// and are independent of the rest of the expression:
//   w = 16'd0 + ((4'd15 + 4'd1) == 4'd0): the == operands are 4 bits,
//   whatever w's 16 bits are: 16 mod 16 = 0 == 0 -> 1; the 1-bit unsigned
//   result zero-extends -> w = 1 (%0d).
// Propagation to a primary, sign-extended only if the propagated type is
//   signed: u8 = 4'sb1000 + 4'sb0001 -> signed, 11111000 + 1 = 11111001;
//   u8 = 4'sb1000 + 4'b0001 -> unsigned, 00001000 + 1 = 00001001.
//! inherited IEEE 1364-2005 5.5.2
module b_5_5_2_real_and_relational_operands;
  reg [15:0] w;
  reg [7:0] u8, v8;
  initial begin
    $display("%f %b", (4'd15 + 4'd1) + 0.5, (4'd15 + 4'd1) == 5'd16);
    w = 16'd0 + ((4'd15 + 4'd1) == 4'd0);
    u8 = 4'sb1000 + 4'sb0001;
    v8 = 4'sb1000 + 4'b0001;
    $display("%0d %b %b", w, u8, v8);
    $finish(0);
  end
endmodule
