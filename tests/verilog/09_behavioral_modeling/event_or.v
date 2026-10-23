// IEEE 1364-2005 §9.7.4, p. 134: "The logical or of any number of events can be
// expressed so that the occurrence of any one of the events triggers the
// execution of the procedural statement that follows it. The keyword or or a
// comma character (,) is used as an event logical or operator. A combination
// of these can be used in the same event expression. Comma-separated
// sensitivity lists shall be synonymous to or-separated sensitivity lists."
// The clause's forms: "@(trig or enable)", "always @(posedge clk, negedge
// rstn)", "always @(a or b, c, d or e)".
//
// One change per step, lines only for step > 0 (the time-0 initialisation
// races the always blocks' first wait; step is then x or 0):
//   @(a or b, c): steps 1 (a), 2 (b), 3 (c)       -> "abc 1", "abc 2", "abc 3"
//   @(posedge clk, negedge rstn): clk 0->1 (4), rstn 1->0 (5) fire; clk 1->0
//     (6) and rstn 0->1 (7) are the other edges -> "edge 4", "edge 5"
//   @(trig or enable): -> trig (8), enable changes (9) -> "te 8", "te 9"
//! inherited IEEE 1364-2005 9.7.4
`timescale 1ns/1ns
module b_9_7_4_event_or;
  reg a, b, c, clk, rstn, enable;
  event trig;
  integer step;

  always @(a or b, c) if (step > 0) $display("abc %0d", step);
  always @(posedge clk, negedge rstn) if (step > 0) $display("edge %0d", step);
  always @(trig or enable) if (step > 0) $display("te %0d", step);

  initial begin
    step = 0;
    a = 0; b = 0; c = 0; clk = 0; rstn = 1; enable = 0;
    #1 step = 1; a = 1;
    #1 step = 2; b = 1;
    #1 step = 3; c = 1;
    #1 step = 4; clk = 1;
    #1 step = 5; rstn = 0;
    #1 step = 6; clk = 0;
    #1 step = 7; rstn = 1;
    #1 step = 8; -> trig;
    #1 step = 9; enable = 1;
    #1 $finish(0);
  end
endmodule
