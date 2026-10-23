//! inherited IEEE 1364-2005 19.8
//! reject it shall be an error if some modules have a
// It is an error if some modules have a `timescale and others do not: a
// precedes the directive and b follows it, so a has none and b has one
// (pr1403406/pr434/resetall).
module triage_mixed_timescale_a;
  initial $display("A");
endmodule

`timescale 1ns/1ps
module triage_mixed_timescale_b;
  initial #1 $display("B");
endmodule
