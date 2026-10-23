// IEEE 1364-2005 §12.2, p. 167: "A parameter declaration with no type or range
// specification shall default to the type and range of the final override
// value assigned to the parameter." "A parameter with a range specification,
// but with no type specification, shall be the range of the parameter
// declaration and shall be unsigned. An override value shall be converted to
// the type and range of the parameter." "A parameter with a type
// specification, but with no range specification, shall be of the type
// specified. An override value shall be converted to the type of the
// parameter. A signed parameter shall default to the range of the final
// override value assigned to the parameter." p. 168: "If a defparam
// assignment conflicts with a module instance parameter, the parameter in the
// module will take the value specified by the defparam." Of the clause's foo
// example: "the defparam of f1.A with the value 3.1415 is performed by
// converting the floating point number 3.1415 into a fixed-point number 3, and
// then the low 3 bits of 3 are assigned to A."
//
// foo prints A, ~B (so the width of B shows), B < 0 (its signedness) and S.
// Each instance prints at t = ID, so the four lines cannot race.
//   f1 #(.A(1)) with defparam f1.A = 2: the defparam wins, A = 2. B keeps
//      3'h2: ~B = 3'b101, unsigned so B < 0 is 0. S = 4'sb0111 = 7.
//   f2 #(13, 8'd200, 5'sb10000, 2): A is [2:0], 13 = 4'b1101 -> low 3 bits
//      3'b101 = 5. B takes 8'd200 = 8'b11001000 unsigned: ~B = 8'b00110111,
//      B < 0 is 0. S is signed with no range: 5'sb10000 keeps its 5 bits,
//      signed -16.
//   f3 #(.B(4'sb1000)): B takes 4 bits, signed: ~B = 4'b0111, B < 0 is 1.
//   f4 with defparam f4.A = 3.1415: 3.1415 -> 3 (rounded, §4.8.2), low 3 bits
//      3'b011 = 3.
//! inherited IEEE 1364-2005 12.2
`timescale 1ns/1ns
module foo;
  parameter [2:0] A = 3'h2;
  parameter B = 3'h2;
  parameter signed S = 4'sb0111;
  parameter ID = 1;
  initial #ID $display("%m A=%0d ~B=%b neg=%b S=%0d", A, ~B, B < 0, S);
endmodule
module b_12_2_override_type_and_range;
  foo #(.A(1), .ID(1)) f1();
  defparam f1.A = 2;
  foo #(13, 8'd200, 5'sb10000, 2) f2();
  foo #(.B(4'sb1000), .ID(3)) f3();
  foo #(.ID(4)) f4();
  defparam f4.A = 3.1415;
endmodule
