// 65536 pins: one past what a device holds (E1103). Each pin is a bit of a
// contract mask (`contract.MaskOf`), and Zig's widest integer is u65535.
module v_pins(a);
  input [65535:0] a;
endmodule
