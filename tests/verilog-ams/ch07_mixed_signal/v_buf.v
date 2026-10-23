// A buffer: the mock host (tests/fixtures/ch07_mixed_signal/vdev_host.zig) feeds y back to a through a
// divider, so its operating point is a digital fixed point through analog.
`timescale 1ns/1ps
module v_buf(a, y);
  input a;
  output y;
  assign y = a;
endmodule
