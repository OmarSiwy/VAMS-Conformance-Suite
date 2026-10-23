// IEEE 1364-2005 §9.7.2, p. 133: "An implicit event shall be detected on any
// change in the value of the expression." ... "A change of value in any
// operand of the expression without a change in the result of the expression
// shall not be detected as an event."
//
// @(a & b), a = 0, b = 0:
//   t=1 b = 1: the operand b changes, a & b stays 0 -> no event
//   t=2 a = 1: a & b goes 0 -> 1                     -> "change 2"
//   t=3 b = 0: a & b goes 1 -> 0                     -> "change 3"
//   t=4 a = 0: operand changes, a & b stays 0        -> no event
// Lines print only for step > 0: the time-0 x -> 0 initialisation races the
// always block's first wait, and step is then x or 0.
//! inherited IEEE 1364-2005 9.7.2
`timescale 1ns/1ns
module b_9_7_2_expression_event;
  reg a, b;
  integer step;

  always @(a & b) if (step > 0) $display("change %0d", step);

  initial begin
    step = 0;
    a = 1'b0;
    b = 1'b0;
    #1 step = 1; b = 1'b1;
    #1 step = 2; a = 1'b1;
    #1 step = 3; b = 1'b0;
    #1 step = 4; a = 1'b0;
    #1 $finish(0);
  end
endmodule
