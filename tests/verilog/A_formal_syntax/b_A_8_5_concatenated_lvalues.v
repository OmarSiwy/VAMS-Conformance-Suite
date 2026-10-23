// IEEE 1364-2005 A.8.5, p. 506:
//   net_lvalue ::= hierarchical_net_identifier [ { [ constant_expression ] } [ constant_range_expression ] ]
//     | { net_lvalue { , net_lvalue } }
//   variable_lvalue ::= hierarchical_variable_identifier [ { [ expression ] } [ range_expression ] ]
//     | { variable_lvalue { , variable_lvalue } }
//
// The lvalue forms beyond a whole net or a selected variable:
//   assign {co, sum} = a + b, a = 4'd9, b = 4'd8: 17 = 5'b1_0001 -> co = 1,
//     sum = 4'b0001 (a concatenated net_lvalue)
//   assign n[2] = 1'b1, assign n[1:0] = 2'b01: n = 4'bz101 (net bit- and
//     part-selects; n[3] undriven)
//   {c, s} = 5'b0_1110: c = 0, s = 4'b1110 (a concatenated variable_lvalue)
//   {c, s[1:0]} = 3'b101: c = 1, s[1:0] = 2'b01 -> s = 4'b1101
// Output: "co=1 sum=0001 n=z101 c=1 s=1101".
//! inherited IEEE 1364-2005 A.8.5
`timescale 1ns/1ns
module b_A_8_5_concatenated_lvalues;
  reg [3:0] a, b, s;
  reg c;
  wire co;
  wire [3:0] sum, n;
  assign {co, sum} = a + b;
  assign n[2] = 1'b1;
  assign n[1:0] = 2'b01;
  initial begin
    a = 4'd9;
    b = 4'd8;
    {c, s} = 5'b0_1110;
    {c, s[1:0]} = 3'b101;
    #1 $display("co=%b sum=%b n=%b c=%b s=%b", co, sum, n, c, s);
    $finish(0);
  end
endmodule
