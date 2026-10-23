// The digital design the P04 VPI applications traverse and refuse against.
//
// Not a tests/fixtures/** fixture (it carries no directives): every number
// about it is asserted from C, by the p04_*.c applications beside it, through
// the object model of LRM 11.6. Its only job is to hold one object of each
// class those applications name, with a shape that is derivable by reading
// this file:
//
//   p04_objects            the top module (11.6.1 NOTE 1)
//     parameter W = 8      11.6.12, an integer parameter
//     localparam M = W - 1 11.6.12, a localparam, 7
//     wire [7:0] bus       11.6.8, a vector net, continuously driven
//     wire       lsb       11.6.8, a scalar net, driven by u's port y
//     wire       lsb2      11.6.8, a scalar net, driven by v's port y
//     reg  [3:0] r         11.6.9, written once at t=0 with 9
//     reg  [7:0] mem[0:3]  11.6.11, a memory of four 8-bit words
//     integer    i         11.6.10, 5
//     real       x         11.6.10, 2.5
//     p04_leaf   u         a child instance with two ports:
//       input  [7:0] a     11.6.4, port index 0, 8 bits
//       output       y     11.6.4, port index 1, 1 bit
//     p04_leaf   v         a second instance of the same definition — 11.2.2's
//                          "instantiated twice as m1 and m2"
//
// THE TIMELINE: everything is written at t=0 and nothing changes after it,
// so any read from t=0's read-only region on reads the values above. bus is
// {4'b0000, r} = 8'h09, and lsb = lsb2 = bus[0] = 1. $finish(0) at t=1.

`timescale 1ns/1ns

module p04_objects;
  parameter W = 8;
  localparam M = W - 1;
  wire [7:0] bus;
  wire       lsb;
  wire       lsb2;
  reg  [3:0] r;
  reg  [7:0] mem [0:3];
  integer    i;
  real       x;

  assign bus = {4'b0000, r};
  p04_leaf u(.a(bus), .y(lsb));
  p04_leaf v(.a(bus), .y(lsb2));

  initial begin
    r = 4'd9;
    i = 5;
    x = 2.5;
    mem[0] = 8'h00;
    mem[1] = 8'h11;
    mem[2] = 8'h22;
    mem[3] = 8'h33;
    #1 $finish(0);
  end
endmodule

module p04_leaf(a, y);
  input  [7:0] a;
  output       y;
  assign y = a[0];
endmodule
