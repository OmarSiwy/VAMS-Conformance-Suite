// IEEE 1364-2005 §12.3.3, p. 175: "If either the port or the net/reg is
// declared as signed, then the other shall also be considered signed." The
// clause's module test declares "output signed [7:0] g;" and "reg [7:0] g;
// // reg g inherits signed attribute from port".
//
// g = -1 stores 8'hFF; g is signed, so %0d prints -1 (unsigned would be 255).
// g < 0 is then 1.
//! inherited IEEE 1364-2005 12.3.3
`timescale 1ns/1ns
module test(g);
  output signed [7:0] g;
  reg [7:0] g;
  initial begin
    #1 g = -1;
    $display("%0d %b", g, g < 0);
  end
endmodule
module b_12_3_3_output_reg_inherits_port_sign;
  wire [7:0] g;
  test t(g);
endmodule
