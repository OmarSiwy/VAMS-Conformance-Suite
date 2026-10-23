// native-required
// IEEE 1364-2005 A.8.4, p. 505-506:
//   constant_primary ::= number | parameter_identifier [ [ constant_range_expression ] ]
//     | specparam_identifier [ [ constant_range_expression ] ] | constant_concatenation
//     | constant_multiple_concatenation | constant_function_call
//     | constant_system_function_call | ( constant_mintypmax_expression ) | string
//   module_path_primary ::= number | identifier | module_path_concatenation
//     | module_path_multiple_concatenation | function_call | system_function_call
//     | ( module_path_mintypmax_expression )
//   primary ::= number | hierarchical_identifier [ { [ expression ] } [ range_expression ] ]
//     | concatenation | multiple_concatenation | function_call | system_function_call
//     | ( mintypmax_expression ) | string
//
// primary alternatives (m is reg [7:0] m [0:3], m[2] = 8'hC3; r = 4'b1001):
//   12                       a number
//   r[3]                     identifier with a bit-select: 1
//   m[2][7:4]                an array element then a range_expression: 4'hC
//   c.k                      a hierarchical identifier into instance c: 6
//   {r, 1'b0}                a concatenation: 5'b10010
//   {2{r[0]}}                a multiple_concatenation: 2'b11
//   inc(r)                   a function_call: 10
//   $unsigned(r)             a system_function_call: 9
//   (r + 1)                  a parenthesized expression: 10
//   "OK"                     a string, displayed %s
// constant_primary alternatives, in parameters: PS = P[3:0] of P = 8'h5A is
// 4'hA; PP = (P) is 90 (a constant_mintypmax_expression in parentheses);
// STR = "ab", a string, prints as ab. The specparam and number forms appear
// in the child's specify block (`specparam S = 6;`), and a
// module_path_primary in its condition `if (en == 1'b1)`; nothing printed
// reads the path's destination y, so its delay does not show.
// Output: "12 1 c 6 10010 11 10 9 10 OK" then "a 90 ab".
//! inherited IEEE 1364-2005 A.8.4
`timescale 1ns/1ns
module b_A_8_4_child (en, a, y);
  input en, a;
  output y;
  wire [3:0] k = 4'd6;
  assign y = a;
  specify
    specparam S = 6;
    if (en == 1'b1) (a => y) = 1;
  endspecify
endmodule
module b_A_8_4_primaries;
  parameter [7:0] P = 8'h5A;
  parameter [15:0] STR = "ab";
  localparam [3:0] PS = P[3:0];
  localparam PP = (P);
  reg [3:0] r;
  reg [7:0] m [0:3];
  wire y;
  b_A_8_4_child c (1'b1, 1'b1, y);
  function [3:0] inc(input [3:0] v);
    inc = v + 1;
  endfunction
  initial begin
    r = 4'b1001;
    m[2] = 8'hC3;
    $display("%0d %b %h %0d %b %b %0d %0d %0d %s",
             12, r[3], m[2][7:4], c.k, {r, 1'b0}, {2{r[0]}}, inc(r), $unsigned(r), (r + 1), "OK");
    $display("%h %0d %s", PS, PP, STR);
    $finish(0);
  end
endmodule
