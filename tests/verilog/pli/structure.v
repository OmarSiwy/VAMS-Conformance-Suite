// The design structure.c walks: IEEE 1364-2005 §26.6's structural
// objects, a few of each, in a shape derivable by reading this file. Every
// number about it is asserted from C, through the object model.
//
//   b26_structure                        the one top-level module
//     P = 8'd5 (range [7:0]), L = P + 1  parameter, localparam
//     bus [7:0], s, s2, s3               nets; bus = {4'b0000, r}
//     na [0:1] of [3:0]                  net array
//     r [3:0]                            reg
//     mem [0:3] of [7:0]                 reg array (a memory)
//     m2 [0:1][0:2] of [3:0]             two-dimensional reg array
//     i, ia [0:2], x, t                  integer, integer array, real, time
//     ev                                 named event
//     u  = b26_leaf (W 8), named ports   a = bus, y = s
//     w4 = b26_leaf #(.W(4)), ordered    a = r,   y = s2
//     c1 = b26_buf, ordered              i = s,   o = s3
//     arr[1:0] = b26_cell, ordered       i = s in each instance (module array)
//     gen[0], gen[1]                     loop generate, nets gw and gv each
//
// Time 0 leaves r = 9, i = 5, x = 2.5, t = 7, mem[1] = 8'h11, ia[2] = 3, so
// bus = 8'h09, s = bus[0] = 1 and s3 = s = 1.
`timescale 1ns/1ps

module b26_leaf(a, y);
  parameter W = 8;
  input [W-1:0] a;
  output y;
  wire [W-1:0] inner;
  assign y = a[0];
endmodule

module b26_cell(i);
  input i;
endmodule

module b26_buf(i, o);
  input i;
  output o;
  assign o = i;
endmodule

module b26_structure;
  parameter [7:0] P = 8'd5;
  localparam L = P + 1;
  wire [7:0] bus;
  wire s, s2, s3;
  wire [3:0] na [0:1];
  reg [3:0] r;
  reg [7:0] mem [0:3];
  reg [3:0] m2 [0:1][0:2];
  integer i;
  integer ia [0:2];
  real x;
  time t;
  event ev;

  assign bus = {4'b0000, r};
  b26_leaf u (.a(bus), .y(s));
  b26_leaf #(.W(4)) w4 (r, s2);
  b26_buf c1 (s, s3);
  b26_cell arr [1:0] (s);

  genvar g;
  generate for (g = 0; g < 2; g = g + 1) begin : gen
    wire gw = g;
    wire [g+1:0] gv = g + 1;
  end endgenerate

  initial begin
    r = 4'd9;
    i = 5;
    x = 2.5;
    t = 7;
    mem[1] = 8'h11;
    ia[2] = 3;
    #1 $finish(0);
  end
endmodule
