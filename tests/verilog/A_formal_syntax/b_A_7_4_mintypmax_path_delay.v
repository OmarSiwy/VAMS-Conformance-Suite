// IEEE 1364-2005 A.7.4, p. 501:
//   path_delay_expression ::= constant_mintypmax_expression
// A.8.3, p. 504: constant_mintypmax_expression ::= constant_expression
//   | constant_expression : constant_expression : constant_expression
// §14.3.1, p. 222 (quoted for context): "Each path delay expression may be a
// single value—representing the typical delay—or a colon-separated list of
// three values—representing a minimum, typical, and maximum delay, in that
// order."
//
// `(a => y) = (1:2:3);`: the typical 2 times y's x -> 1 from a's transition
// at time 0 (§14.3.3), so at t=10 y = 1. Output: "y=1".
//! inherited IEEE 1364-2005 A.7.4
`timescale 1ns/1ns
module b_A_7_4_mtm_cell (a, y);
  input a;
  output y;
  assign y = a;
  specify
    (a => y) = (1:2:3);
  endspecify
endmodule
module b_A_7_4_mintypmax_path_delay;
  wire y;
  b_A_7_4_mtm_cell c (1'b1, y);
  initial #10 begin
    $display("y=%b", y);
    $finish(0);
  end
endmodule
