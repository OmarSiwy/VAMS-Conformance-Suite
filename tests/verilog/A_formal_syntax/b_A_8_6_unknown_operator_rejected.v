// IEEE 1364-2005 A.8.6, p. 506:
//   binary_operator ::= + | - | * | / | % | == | != | === | !== | && | || | **
//     | < | <= | > | >= | & | | | ^ | ^~ | ~^ | >> | << | >>> | <<<
// `<>` is not in the list (inequality is `!=`).
//
// `a <> b` derives no expression. Legal neighbour: b_A_8_6_operators.v
// (`a != b`).
//! inherited IEEE 1364-2005 A.8.6
//! reject E0209
//! reject expected an expression: found `>`
//! neighbour b_A_8_6_operators.v
module b_A_8_6_unknown_operator_rejected;
  reg [3:0] a, b;
  initial begin
    a = 1;
    b = 2;
    $display("%b", a <> b);
  end
endmodule
