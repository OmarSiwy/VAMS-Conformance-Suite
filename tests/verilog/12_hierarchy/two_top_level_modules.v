// IEEE 1364-2005 §12.1.1, p. 165: "Top-level modules are modules that are
// included in the source text, but do not appear in any module instantiation
// statement". "A model shall contain at least one top-level module." §12.5,
// p. 191: "A design description contains one or more top-level modules".
// §12.2.1, p. 170, of its example: "The module annotate has the defparam
// statement, which overrides size and delay parameter values for instances m1
// and m2 in the top-level module top. The modules top and annotate would both
// be considered top-level modules."
//
// The clause's example (§12.2.1, pp. 169-170), with vdff reporting its own
// parameters at t = delay so the two reports cannot race:
//   m1: size = 5, delay = 10 -> "top.m1 size=5 delay=10" at t = 10
//   m2: size = 10, delay = 20 -> "top.m2 size=10 delay=20" at t = 20
//! inherited IEEE 1364-2005 12.1.1 12.2.1 12.5
`timescale 1ns/1ns
module top;
  reg clk;
  reg [0:4] in1;
  reg [0:9] in2;
  wire [0:4] o1;
  wire [0:9] o2;
  vdff m1 (o1, in1, clk);
  vdff m2 (o2, in2, clk);
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
module annotate;
  defparam
    top.m1.size = 5,
    top.m1.delay = 10,
    top.m2.size = 10,
    top.m2.delay = 20;
endmodule
