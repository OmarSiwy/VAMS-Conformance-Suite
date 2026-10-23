// IEEE 1364-2005 §9.7.2, p. 133: "— A negedge shall be detected on the
// transition from 1 to x, z, or 0, and from x or z to 0 — A posedge shall be
// detected on the transition from 0 to x, z, or 1, and from x or z to 1"
// (Table 9-1) ... "An implicit event shall be detected on any change in the
// value of the expression. An edge event shall be detected only on the least
// significant bit of the expression. A change of value in any operand of the
// expression without a change in the result of the expression shall not be
// detected as an event."
//
// s walks 0 1 0 x 0 z 1 x 1 z x z 0, one change per time unit, so its twelve
// transitions are every ordered pair of Table 9-1 exactly once:
//   step 1  0->1 posedge    step 7  1->x negedge
//   step 2  1->0 negedge    step 8  x->1 posedge
//   step 3  0->x posedge    step 9  1->z negedge
//   step 4  x->0 negedge    step 10 z->x no edge
//   step 5  0->z posedge    step 11 x->z no edge
//   step 6  z->1 posedge    step 12 z->0 negedge
// Then v (2 bits) goes 01 -> 10 (step 13): its LSB falls 1->0 -> negedge only;
// the MSB's rise is not a posedge. w (2 bits) goes 00 -> 10 (step 14): its LSB
// is unchanged, so neither edge, but @(w) sees the change -> "change w 14".
// Each step has at most one line, so no two processes race to print. Lines
// print only for step > 0: the time-0 initialisation (x -> 0 and so on) races
// the always blocks' first wait, and step is then x or 0, never > 0. (The
// operand-without-result rule is expression_event.v.)
//! inherited IEEE 1364-2005 9.7.2
`timescale 1ns/1ns
module b_9_7_2_edge_detection;
  reg s;
  reg [1:0] v, w;
  integer step;

  always @(posedge s) if (step > 0) $display("posedge s %0d", step);
  always @(negedge s) if (step > 0) $display("negedge s %0d", step);
  always @(posedge v) if (step > 0) $display("posedge v %0d", step);
  always @(negedge v) if (step > 0) $display("negedge v %0d", step);
  always @(posedge w) if (step > 0) $display("posedge w %0d", step);
  always @(negedge w) if (step > 0) $display("negedge w %0d", step);
  always @(w) if (step > 0) $display("change w %0d", step);

  initial begin
    step = 0;
    s = 1'b0;
    v = 2'b01;
    w = 2'b00;
    #1 step = 1;  s = 1'b1;
    #1 step = 2;  s = 1'b0;
    #1 step = 3;  s = 1'bx;
    #1 step = 4;  s = 1'b0;
    #1 step = 5;  s = 1'bz;
    #1 step = 6;  s = 1'b1;
    #1 step = 7;  s = 1'bx;
    #1 step = 8;  s = 1'b1;
    #1 step = 9;  s = 1'bz;
    #1 step = 10; s = 1'bx;
    #1 step = 11; s = 1'bz;
    #1 step = 12; s = 1'b0;
    #1 step = 13; v = 2'b10;
    #1 step = 14; w = 2'b10;
    #1 $finish(0);
  end
endmodule
