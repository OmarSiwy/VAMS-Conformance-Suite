// IEEE 1364-2005 §14.3.3: "Active specify paths are those whose input
// has transitioned most recently in time, and either they have no condition or
// their conditions are true. In the presence of simultaneous input
// transitions, it is possible for many specify paths to an output to be
// simultaneously active." ... "a delay must be selected from among them. This
// is done by comparing the correct delay for the specific transition being
// scheduled from each specify path and choosing the smallest."
//
// Example 1 verbatim, (A => Y) = (6, 9); (B => Y) = (5, 11), with Y = A | B:
// "For a Y transition from 0 to 1, if A transitioned more recently than B, a
// delay of 6 will be chosen. But if B transitioned more recently than A, a
// delay of 5 will be chosen. And if, the last time they transitioned, A and B
// did so simultaneously, then the smallest of the two rise delays would be
// chosen, which is the rise delay from B of 5. The fall delay from A of 9
// would be chosen if Y was instead to transition from 1 to 0."
//   t = 1:   A = B = 0 together: Y x -> 0, Table 14-3's max(tz0, t10) per
//            path, 9 and 11, the smaller: Y = 0 at 10
//   t = 20:  A = 1: rise from A, 6:  Y = 1 at 26
//   t = 40:  A = 0: fall from A, 9:  Y = 0 at 49
//   t = 60:  B = 1: rise from B, 5:  Y = 1 at 65
//   t = 80:  B = 0: fall from B, 11: Y = 0 at 91
//   t = 100: A = B = 1 together: rise, min(6, 5) = 5: Y = 1 at 105
//   t = 120: A = B = 0 together: fall, min(9, 11) = 9: Y = 0 at 129
//
// Example 2's `if (MODE < 5) (A => Y) = (5, 9);` ... `if (MODE < 1) (A => Y)
// = (7, 7);` uses `<`, which neither Table 14-1 nor A.7.4's
// binary_module_path_operator admits (condition_operator_rejected.v),
// so each condition is the input bit LT[k], set as MODE < k+1 would be:
// MODE 2 is LT = 5'b11100, MODE 5 is 5'b00000, MODE 0 is 5'b11111. "when
// MODE is 2, the first three specify paths are active. A rise transition would
// select a delay of 4 ... A fall transition would select a delay of 5":
//   t = 1:   LT = 11100, A2 = 0: Y2 x -> 0, min(9, 8, 5) = 5: at 6
//   t = 20:  A2 = 1: rise, min(5, 4, 6) = 4: Y2 = 1 at 24
//   t = 40:  A2 = 0: fall, min(9, 8, 5) = 5: Y2 = 0 at 45
//   t = 61:  LT = 00000 (MODE 5) since t = 60, A2 = 1: no path active, no
//            path delay: Y2 = 1 at 61
//   t = 81:  LT = 11111 (MODE 0) since t = 80, A2 = 0: fall, min of all five,
//            2: Y2 = 0 at 83
//   t = 100: A2 = 1: rise, min(5, 4, 6, 3, 7) = 3: Y2 = 1 at 103
// (iverilog 13 lands Y2's first x -> 0 at 1, with no path delay: LT was set
// in the same statement list just before A2, so every condition reads true
// when the transition is scheduled, and §14.2.4.1 would count an x or z
// condition as true anyway, "If the conditional expression evaluates to x or
// z, it shall be treated as true".)
//! inherited IEEE 1364-2005 14.3.3 14.2.4
`timescale 1ns/1ns
module b_14_3_3_delay_selection_ex1(A, B, Y);
  input A, B;
  output Y;
  assign Y = A | B;
  specify
    (A => Y) = (6, 9);
    (B => Y) = (5, 11);
  endspecify
endmodule

module b_14_3_3_delay_selection_ex2(A, LT, Y);
  input A;
  input [4:0] LT;
  output Y;
  assign Y = A;
  specify
    if (LT[4]) (A => Y) = (5, 9);
    if (LT[3]) (A => Y) = (4, 8);
    if (LT[2]) (A => Y) = (6, 5);
    if (LT[1]) (A => Y) = (3, 2);
    if (LT[0]) (A => Y) = (7, 7);
  endspecify
endmodule

module b_14_3_3_delay_selection;
  reg a, b, a2;
  reg [4:0] lt;
  wire y, y2;
  b_14_3_3_delay_selection_ex1 u1(a, b, y);
  b_14_3_3_delay_selection_ex2 u2(a2, lt, y2);
  always @(y) $display("%0t Y=%b", $time, y);
  always @(y2) $display("%0t Y2=%b", $time, y2);
  initial begin
    #1 a = 0; b = 0;
    #19 a = 1;
    #20 a = 0;
    #20 b = 1;
    #20 b = 0;
    #20 a = 1; b = 1;
    #20 a = 0; b = 0;
  end
  initial begin
    #1 lt = 5'b11100; a2 = 0;
    #19 a2 = 1;
    #20 a2 = 0;
    #20 lt = 5'b00000;
    #1 a2 = 1;
    #19 lt = 5'b11111;
    #1 a2 = 0;
    #19 a2 = 1;
  end
endmodule
