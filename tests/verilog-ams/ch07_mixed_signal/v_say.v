// A device's transcript (tests/fixtures/ch07_mixed_signal/vdev_host.zig): "born" at time 0, and
// "edge" from the step that runs each rising clk edge, printed only when
// the host accepts that step.
`timescale 1ns/1ps
module v_say(clk, q);
  input clk;
  output q;
  reg q;
  initial begin q = 0; $display("born"); end
  always @(posedge clk) begin q <= ~q; $display("edge"); end
endmodule
