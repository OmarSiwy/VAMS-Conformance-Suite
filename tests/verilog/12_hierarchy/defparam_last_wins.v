// IEEE 1364-2005 §12.2.1, p. 168: "Using the defparam statement, parameter
// values can be changed in any module instance throughout the design using the
// hierarchical name of the parameter." p. 169: "In the case of multiple
// defparams for a single parameter, the parameter takes the value of the last
// defparam statement encountered in the source text."
//
// The clause's top/vdff example with the annotate defparams placed in top (a
// second top-level module is two_top_level_modules.v), and one more
// defparam of m1.size after them. vdff reports at t = delay, so the reports
// cannot race:
// (%m names the instances under this module, not the clause's top):
//   m1: size 5 then 6 -> the last one, 6; delay 10 -> "<top>.m1 size=6 delay=10"
//   m2: size 10, delay 20                        -> "<top>.m2 size=10 delay=20"
//! inherited IEEE 1364-2005 12.2.1
`timescale 1ns/1ns
module b_12_2_1_defparam_last_wins;
  reg clk;
  reg [0:4] in1;
  reg [0:9] in2;
  wire [0:4] o1;
  wire [0:9] o2;
  vdff m1 (o1, in1, clk);
  vdff m2 (o2, in2, clk);
  defparam
    m1.size = 5,
    m1.delay = 10,
    m2.size = 10,
    m2.delay = 20;
  defparam m1.size = 6;
endmodule
module vdff (out, in, clk);
  parameter size = 1, delay = 1;
  input [0:size-1] in;
  input clk;
  output [0:size-1] out;
  reg [0:size-1] out;
  always @(posedge clk)
    # delay out = in;
  initial #delay $display("%m size=%0d delay=%0d", size, delay);
endmodule
