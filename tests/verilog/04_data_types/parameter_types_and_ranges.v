// IEEE 1364-2005 §4.10.1, p. 36-37, the type and range rules: "A parameter
// with a range specification, but with no type specification, shall be the
// range of the parameter declaration and shall be unsigned. The sign and
// range shall not be affected by value overrides." "A parameter with no range
// specification and with either a signed type specification or no type
// specification shall have an implied range with an lsb equal to 0 and an msb
// equal to one less than the size of the final value assigned to the
// parameter." and the clause's integral examples: "parameter byte_size = 8,
// byte_mask = byte_size - 1;", "parameter p1 = 13'h7e;", "parameter [31:0]
// dec_const = 1'b1; // value converted to 32 bits", "parameter newconst =
// 3'h4; // implied range of [2:0]". §12.2, p. 168: "When an untyped and
// unranged parameter's value is overridden, the parameter takes on the size
// and type of the override."
//
//   byte_mask = 8 - 1 = 7.
//   p1 = 13'h7e: 13 bits, 0000001111110.
//   dec_const = 1'b1 in [31:0]: 31 zeros then 1.
//   newconst = 3'h4: [2:0], 100.
//   u.R, [3:0] and overridden by 8'hFF: keeps [3:0] and unsigned, 1111 = 15.
//   u.U, untyped 1, overridden by 8'h0F: takes 8 bits, 00001111.
// Output: "7 0000001111110 00000000000000000000000000000001 100"
//   then "R=1111 15 U=00001111".
//! inherited IEEE 1364-2005 4.10.1
module b_4_10_1_leaf;
  parameter [3:0] R = 1;
  parameter U = 1;
  initial #1 $display("R=%b %0d U=%b", R, R, U);
endmodule
module b_4_10_1_parameter_types_and_ranges;
  parameter byte_size = 8, byte_mask = byte_size - 1;
  parameter p1 = 13'h7e;
  parameter [31:0] dec_const = 1'b1;
  parameter newconst = 3'h4;
  b_4_10_1_leaf #(8'hFF, 8'h0F) u();
  initial begin
    $display("%0d %b %b %b", byte_mask, p1, dec_const, newconst);
    #2 $finish(0);
  end
endmodule
