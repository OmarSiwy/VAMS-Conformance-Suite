// IEEE 1364-2005 A.8.1, p. 504:
//   concatenation ::= { expression { , expression } }
//   constant_concatenation ::= { constant_expression { , constant_expression } }
//   constant_multiple_concatenation ::= { constant_expression constant_concatenation }
//   module_path_concatenation ::= { module_path_expression { , module_path_expression } }
//   module_path_multiple_concatenation ::= { constant_expression module_path_concatenation }
//   multiple_concatenation ::= { constant_expression concatenation }
//
// a = 2'b10, b = 3'b011:
//   {a, b}                   5'b10011
//   {2{a}}                   4'b1010 (a multiple_concatenation)
//   {1'b1, {2{b[0]}}, a}     nested: 1, 11, 10 -> 5'b11110
//   P = {2'b01, 2'b11}       a constant_concatenation parameter: 4'b0111
//   Q = {3{1'b1}}            a constant_multiple_concatenation: 3'b111
// The module_path forms appear in a specify block's state-dependent path
// condition, `if ({en, en} == 2'b11)` and `if ({2{en}} == 2'b11)`. Nothing
// printed reads the path's destination y, so its delay does not show.
// Output: "10011 1010 11110 0111 111".
//! inherited IEEE 1364-2005 A.8.1
`timescale 1ns/1ns
module b_A_8_1_cell (en, a, y);
  input en, a;
  output y;
  assign y = a;
  specify
    if ({en, en} == 2'b11) (a => y) = 1;
    if ({2{en}} == 2'b11) (en => y) = 1;
  endspecify
endmodule
module b_A_8_1_concatenations;
  parameter [3:0] P = {2'b01, 2'b11};
  parameter [2:0] Q = {3{1'b1}};
  reg [1:0] a;
  reg [2:0] b;
  wire y;
  b_A_8_1_cell c (1'b1, 1'b1, y);
  initial begin
    a = 2'b10;
    b = 3'b011;
    $display("%b %b %b %b %b", {a, b}, {2{a}}, {1'b1, {2{b[0]}}, a}, P, Q);
    $finish(0);
  end
endmodule
