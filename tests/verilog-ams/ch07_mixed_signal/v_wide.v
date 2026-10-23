// 132 pins (tests/fixtures/ch07_mixed_signal/vdev_host.zig): more than a u64 mask names, and ports
// wider than one plane word. q is a 65-bit counter from 2^64, so q[64],
// in its slot's second word, is 1; y reads d[64], in d's second word.
`timescale 1ns/1ps
module v_wide(clk, q, d, y);
  input clk;
  output [64:0] q;
  input [64:0] d;
  output y;
  reg [64:0] q;
  initial q = 65'h1_0000_0000_0000_0000;
  always @(posedge clk) q <= q + 1;
  assign y = d[64];
endmodule
