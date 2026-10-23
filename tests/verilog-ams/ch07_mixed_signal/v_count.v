// A free-running 2-bit counter on a 10 ns clock (tests/fixtures/ch07_mixed_signal/vdev_host.zig): its
// first rising clock edge is at 5 ns, so q is k mod 4 from 5 + 10(k-1) ns.
`timescale 1ns/1ps
module v_count(q);
  output [1:0] q;
  reg [1:0] q;
  reg clk;
  initial begin
    clk = 0;
    q = 0;
  end
  always #5 clk = ~clk;
  always @(posedge clk) q <= q + 1;
endmodule
