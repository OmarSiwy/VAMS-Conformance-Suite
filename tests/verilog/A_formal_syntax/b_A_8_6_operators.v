// IEEE 1364-2005 A.8.6, p. 506:
//   unary_operator ::= + | - | ! | ~ | & | ~& | | | ~| | ^ | ~^ | ^~
//   binary_operator ::= + | - | * | / | % | == | != | === | !== | && | || | **
//     | < | <= | > | >= | & | | | ^ | ^~ | ~^ | >> | << | >>> | <<<
//   unary_module_path_operator ::= ! | ~ | & | ~& | | | ~| | ^ | ~^ | ^~
//   binary_module_path_operator ::= == | != | && | || | & | | | ^ | ^~ | ~^
//
// a = 4'b1100, b = 4'b1010, s = -8 (a signed 8-bit reg). Every operator
// once, each result a 4-bit value unless noted (1-bit results print 1 digit):
// unary:  +a 1100  -a 0100  !a 0  ~a 0011  &a 0  ~&a 1  |a 1  ~|a 0  ^a 0
//         ~^a 1  ^~a 1
// binary: a+b 0110  a-b 0010  a*b 1000  a/b 0001  a%b 0010
//         a==b 0  a!=b 1  a===b 0  a!==b 1  a&&b 1  a||b 1
//         2**3 = 8 (1000)
//         a<b 0  a<=b 0  a>b 1  a>=b 1
//         a&b 1000  a|b 1110  a^b 0110  a^~b 1001  a~^b 1001
//         a>>1 0110  a<<1 1000  s>>>2 = -2 (11111110)  a<<<1 1000
// Printed six lines, in that order, the ** result and the four relational
// results sharing the fourth and the shifts the sixth.
// Every module path operator appears in a specify block's path condition
// (nothing printed reads its destination y, so the path delay does not show).
//! inherited IEEE 1364-2005 A.8.6
`timescale 1ns/1ns
module b_A_8_6_cell (en, a, y);
  input en, a;
  output y;
  assign y = a;
  specify
    if (!en && ~a || &en && ~&a | |en & ~|a ^ ^en ^~ ~^a ~^ ^~en == 1'b1 != 1'b0) (a => y) = 1;
  endspecify
endmodule
module b_A_8_6_operators;
  reg [3:0] a, b, r0, r1, r2, r3, r4;
  reg signed [7:0] s;
  wire y;
  b_A_8_6_cell c (1'b1, 1'b1, y);
  initial begin
    a = 4'b1100;
    b = 4'b1010;
    s = -8;
    r0 = +a; r1 = -a; r2 = ~a;
    $display("%b %b %b %b %b %b %b %b %b %b %b", r0, r1, !a, r2, &a, ~&a, |a, ~|a, ^a, ~^a, ^~a);
    r0 = a + b; r1 = a - b; r2 = a * b; r3 = a / b; r4 = a % b;
    $display("%b %b %b %b %b", r0, r1, r2, r3, r4);
    $display("%b %b %b %b %b %b", a == b, a != b, a === b, a !== b, a && b, a || b);
    r0 = 2 ** 3;
    $display("%b %b %b %b %b", r0, a < b, a <= b, a > b, a >= b);
    r0 = a & b; r1 = a | b; r2 = a ^ b; r3 = a ^~ b; r4 = a ~^ b;
    $display("%b %b %b %b %b", r0, r1, r2, r3, r4);
    r0 = a >> 1; r1 = a << 1; r2 = a <<< 1;
    $display("%b %b %b %b", r0, r1, s >>> 2, r2);
    $finish(0);
  end
endmodule
