// IEEE 1364-2005 A.3.3, p. 494:
//   inout_terminal ::= net_lvalue
//   output_terminal ::= net_lvalue
// A.8.5, p. 506: net_lvalue ::= hierarchical_net_identifier
//   [ { [ constant_expression ] } [ constant_range_expression ] ] | ...
// A gate's output and a switch's inout terminal can be bit-selects of a
// vector net.
//
// and (y[2], a, a) and buf (y[1], ~a) with a = 1; tran (s[3], s0) with
// s0 = 1: y[2] = 1, y[1] = 0, y[0] and y[3] undriven (z), s[3] = 1.
// Output: "y=z10z s3=1".
//! inherited IEEE 1364-2005 A.3.3
// native-required
`timescale 1ns/1ns
module b_A_3_3_bit_select_terminals;
  reg a;
  wire [3:0] y, s;
  wire s0 = 1'b1;
  and (y[2], a, a);
  buf (y[1], ~a);
  tran (s[3], s0);
  initial begin
    a = 1;
    #1 $display("y=%b s3=%b", y, s[3]);
    $finish(0);
  end
endmodule
