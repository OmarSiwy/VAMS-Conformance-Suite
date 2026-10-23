// 1202 pins (tests/fixtures/ch07_mixed_signal/vdev_host.zig), past 1024 and past the old 256-pin cap,
// so `U` is an enum(u11): a 600-bit register q loads the 600-bit input
// bus d on each rising clk, and y reads d[599].
`timescale 1ns/1ps
module v_huge(clk, d, q, y);
  input clk;
  input [599:0] d;
  output [599:0] q;
  output y;
  reg [599:0] q;
  initial q = 0;
  always @(posedge clk) q <= d;
  assign y = d[599];
endmodule
