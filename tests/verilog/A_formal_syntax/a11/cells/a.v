// IEEE 1364-2005 A.1.1 support source for A_formal_syntax/b_A_1_1_*: the
// cell a, printing its instance and its library binding (%l, §13.6).
`timescale 1ns/1ns
module a;
  parameter D = 0;
  initial #D $display("%m %l");
endmodule
