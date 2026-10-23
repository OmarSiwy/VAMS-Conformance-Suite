// IEEE 1364-2005 A.2.4 and Syntax 14-7 derive each PATHPULSE$ limit through
// limit_value ::= constant_mintypmax_expression. Both the single-limit and
// two-limit forms therefore accept minimum:typical:maximum expressions.
// W0251 records that VerA does not simulate specify pulse filtering. This
// test asserts only the legal declaration and the independently executed
// buffer: its constant input 1 reaches y before the t=1 sample, so y=1.
// The invalid neighbour is b_A_2_4_pathpulse_missing_corner_rejected.v.
//! inherited IEEE 1364-2005 A.2.4 14.6 14.6.1
`timescale 1ns/1ns
module pathpulse_mintypmax_leaf(a, y);
  input a;
  output y;
  assign y = a;
  specify
    specparam PATHPULSE$ = (1:2:3);
    specparam PATHPULSE$a$y = (1:2:3, 4:5:6);
    (a => y) = 1;
  endspecify
endmodule
module b_A_2_4_pathpulse_mintypmax;
  wire y;
  pathpulse_mintypmax_leaf u(1'b1, y);
  initial #1 begin
    $display("y=%b", y);
    $finish(0);
  end
endmodule
