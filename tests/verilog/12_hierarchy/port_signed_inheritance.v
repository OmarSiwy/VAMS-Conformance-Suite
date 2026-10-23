// IEEE 1364-2005 §12.3.3, p. 175: "The signed attribute can be attached either
// to a port declaration or the corresponding net or reg declaration or to
// both. If either the port or the net/reg is declared as signed, then the
// other shall also be considered signed." "Nets connected to ports without an
// explicit net declaration shall be considered unsigned, unless the port is
// declared as signed."
//
// The clause's module test (p. 175), every input driven with 8'hFF, printing
// each input and the reg f after f = -1:
//   a: input [7:0], no net declaration   -> unsigned 255
//   b: input [7:0] + wire signed [7:0]   -> signed -1 (from the net)
//   c: input signed [7:0] + wire [7:0]   -> signed -1 (from the port)
//   d: input signed [7:0], no net decl   -> signed -1
//   f: output [7:0] + reg signed [7:0]   -> signed; f = -1 reads -1
// (g, the output reg that inherits signed from its port, is
// output_reg_inherits_port_sign.v.)
//! inherited IEEE 1364-2005 12.3.3
`timescale 1ns/1ns
module test(a,b,c,d,e,f,g,h);
  input [7:0] a;
  input [7:0] b;
  input signed [7:0] c;
  input signed [7:0] d;
  output [7:0] e;
  output [7:0] f;
  output signed [7:0] g;
  output signed [7:0] h;
  wire signed [7:0] b;
  wire [7:0] c;
  reg signed [7:0] f;
  reg [7:0] g;
  assign e = 8'd0;
  assign h = 8'd0;
  initial begin
    #1 f = -1;
    $display("%0d %0d %0d %0d %0d", a, b, c, d, f);
  end
endmodule
module b_12_3_3_port_signed_inheritance;
  wire [7:0] e, f, g, h;
  test t(8'hFF, 8'hFF, 8'hFF, 8'hFF, e, f, g, h);
endmodule
