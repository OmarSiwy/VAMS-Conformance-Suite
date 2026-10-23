// v_edge counting every change of clk (tests/fixtures/ch07_mixed_signal/vdev_host.zig): both of its
// edges wake the counter, so both crossings are located.
`timescale 1ns/1ps
module v_any(clk, q);
  input clk;
  output [1:0] q;
  reg [1:0] q;
  initial q = 0;
  always @(clk) q <= q + 1;
endmodule
