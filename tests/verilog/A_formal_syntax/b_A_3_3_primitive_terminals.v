// IEEE 1364-2005 A.3.3, p. 494:
//   enable_terminal ::= expression
//   inout_terminal ::= net_lvalue
//   input_terminal ::= expression
//   ncontrol_terminal ::= expression
//   output_terminal ::= net_lvalue
//   pcontrol_terminal ::= expression
//
// Input, enable and control terminals that are expressions, not bare
// identifiers; output and inout terminals that are whole nets (a bit-select
// net_lvalue is b_A_3_3_bit_select_terminals.v). With a = 1, b = 0:
//   and (y2, a & ~b, a | b): (1 & 1) & (1 | 0)              -> y2 = 1
//   bufif1 (y1, a ^ b, a && !b): enable a && !b = 1, input 1 -> y1 = 1
//   cmos (y0, b, ~b, b): ncontrol ~b = 1, pcontrol b = 0, passes b -> y0 = 0
//   tran (s3, s0), s0 driven 1                              -> s3 = 1
// Output: "y=110 s3=1".
//! inherited IEEE 1364-2005 A.3.3
// native-required
`timescale 1ns/1ns
module b_A_3_3_primitive_terminals;
  reg a, b;
  wire y2, y1, y0, s3;
  wire s0 = 1'b1;
  and (y2, a & ~b, a | b);
  bufif1 (y1, a ^ b, a && !b);
  cmos (y0, b, ~b, b);
  tran (s3, s0);
  initial begin
    a = 1;
    b = 0;
    #1 $display("y=%b%b%b s3=%b", y2, y1, y0, s3);
    $finish(0);
  end
endmodule
