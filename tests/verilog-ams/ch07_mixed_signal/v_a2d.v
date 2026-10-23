// An A2D edge (tests/fixtures/ch07_mixed_signal/vdev_host.zig): y follows a; z rises one tick after a
// rising edge of a, so z's event time says at which tick the edge arrived.
`timescale 1ns/1ns
module v_a2d(a, y, z);
  input a;
  output y, z;
  reg z;
  assign y = a;
  initial z = 0;
  always @(posedge a) #1 z = 1;
endmodule
