// native-required
// IEEE 1364-2005 A.8.3, p. 504-505:
//   base_expression ::= expression
//   conditional_expression ::= expression1 ? { attribute_instance } expression2 : expression3
//   constant_base_expression ::= constant_expression
//   constant_expression ::= constant_primary | unary_operator { attribute_instance } constant_primary
//     | constant_expression binary_operator { attribute_instance } constant_expression
//     | constant_expression ? { attribute_instance } constant_expression : constant_expression
//   constant_mintypmax_expression ::= constant_expression
//     | constant_expression : constant_expression : constant_expression
//   constant_range_expression ::= constant_expression | msb_constant_expression : lsb_constant_expression
//     | constant_base_expression +: width_constant_expression
//     | constant_base_expression -: width_constant_expression
//   dimension_constant_expression ::= constant_expression
//   expression ::= primary | unary_operator { attribute_instance } primary
//     | expression binary_operator { attribute_instance } expression | conditional_expression
//   expression1 ::= expression   expression2 ::= expression   expression3 ::= expression
//   lsb_constant_expression ::= constant_expression
//   mintypmax_expression ::= expression | expression : expression : expression
//   module_path_conditional_expression ::= module_path_expression ? { attribute_instance }
//     module_path_expression : module_path_expression
//   module_path_expression ::= module_path_primary
//     | unary_module_path_operator { attribute_instance } module_path_primary
//     | module_path_expression binary_module_path_operator { attribute_instance } module_path_expression
//     | module_path_conditional_expression
//   module_path_mintypmax_expression ::= module_path_expression
//     | module_path_expression : module_path_expression : module_path_expression
//   msb_constant_expression ::= constant_expression
//   range_expression ::= expression | msb_constant_expression : lsb_constant_expression
//     | base_expression +: width_constant_expression | base_expression -: width_constant_expression
//   width_constant_expression ::= constant_expression
//
// v = 8'b1011_0110, i = 2, P = 5:
//   c = (i > 1) ? v[7:4] : v[3:0]          a conditional_expression: 4'b1011
//   n = -P + 3 * 2                          a unary then binary constant expr: 1
//   Q = (P > 4) ? P - 1 : P + 1             a constant ?: : 4
//   v[i +: 3]                               range_expression base +: width: bits 4..2 = 3'b101
//   v[i+3 -: 2]                             base -: width: bits 5..4 = 2'b11
//   v[P]                                    a range_expression that is one expression: 1
//   K = V[3 +: 2], V = 8'hA5                a constant_range_expression +: on a
//                                            parameter: bits 4..3 of 1010_0101 = 2'b00
// The module_path expressions sit in a specify block's condition
// `if (!en ? a : ~a)`. Nothing printed reads the path's destination y, so
// its delay (§14.3.3) does not show in the output.
// (min:typ:max expressions are b_A_2_2_3_mintypmax_delay.v and
// b_A_7_4_mintypmax_path_delay.v; attributes on operators, b_A_9_1_attributes.v.)
// Output: "c=1011 n=1 Q=4 s1=101 s2=11 s3=1 K=00".
//! inherited IEEE 1364-2005 A.8.3
`timescale 1ns/1ns
module b_A_8_3_cell (en, a, y);
  input en, a;
  output y;
  assign y = a;
  specify
    if (!en ? a : ~a) (a => y) = 1;
  endspecify
endmodule
module b_A_8_3_expressions;
  parameter P = 5;
  parameter [7:0] V = 8'hA5;
  localparam Q = (P > 4) ? P - 1 : P + 1;
  localparam [1:0] K = V[3 +: 2];
  reg [7:0] v;
  integer i, n;
  reg [3:0] c;
  wire y;
  b_A_8_3_cell u (1'b1, 1'b1, y);
  initial begin
    v = 8'b1011_0110;
    i = 2;
    c = (i > 1) ? v[7:4] : v[3:0];
    n = -P + 3 * 2;
    $display("c=%b n=%0d Q=%0d s1=%b s2=%b s3=%b K=%b", c, n, Q, v[i +: 3], v[i+3 -: 2], v[P], K);
    $finish(0);
  end
endmodule
