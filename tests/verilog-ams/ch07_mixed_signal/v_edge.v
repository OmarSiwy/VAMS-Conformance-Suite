// A 2-bit counter on an analog clock pin, posedge only (tests/fixtures/ch07_mixed_signal/vdev_host.zig):
// nothing waits on a falling edge of clk, so its crossing needs no locating.
`timescale 1ns/1ps
module v_edge(clk, q);
  input clk;
  output [1:0] q;
  reg [1:0] q;
  initial q = 0;
  always @(posedge clk) q <= q + 1;
endmodule
