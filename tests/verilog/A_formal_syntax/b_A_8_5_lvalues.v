// native-required
// IEEE 1364-2005 A.8.5, p. 506:
//   net_lvalue ::= hierarchical_net_identifier [ { [ constant_expression ] } [ constant_range_expression ] ]
//     | { net_lvalue { , net_lvalue } }
//   variable_lvalue ::= hierarchical_variable_identifier [ { [ expression ] } [ range_expression ] ]
//     | { variable_lvalue { , variable_lvalue } }
//
// variable_lvalue forms, in order on v = 8'h00, i = 1:
//   v[7] = 1                    a bit-select            v = 1000_0000
//   v[3:2] = 2'b11              a part-select           v = 1000_1100
//   v[i +: 2] = 2'b01           an indexed part-select, bits 2..1 -> v = 1000_1010
//   m[i] = 4'd9                 an array element
//   m[0][3] = 1                 an array element's bit: m[0] = 4'b1000 after m[0] = 0
//   c = 1
// net_lvalue: assign w = ~c, a whole net: w = 0.
// (Concatenated lvalues, and net lvalues that are selects, are
// b_A_8_5_concatenated_lvalues.v.)
// Output: "v=10001010 m1=9 m0=1000 c=1 w=0".
//! inherited IEEE 1364-2005 A.8.5
`timescale 1ns/1ns
module b_A_8_5_lvalues;
  reg [7:0] v;
  reg [3:0] m [0:1];
  reg c;
  integer i;
  wire w;
  assign w = ~c;
  initial begin
    v = 8'h00;
    i = 1;
    v[7] = 1'b1;
    v[3:2] = 2'b11;
    v[i +: 2] = 2'b01;
    m[i] = 4'd9;
    m[0] = 4'd0;
    m[0][3] = 1'b1;
    c = 1'b1;
    #1 $display("v=%b m1=%0d m0=%b c=%b w=%b", v, m[1], m[0], c, w);
    $finish(0);
  end
endmodule
