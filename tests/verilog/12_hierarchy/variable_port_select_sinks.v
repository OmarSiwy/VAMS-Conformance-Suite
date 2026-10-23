// IEEE 1364-2005 §12.3.9.2, p. 179: "A structural net expression is a port
// expression whose operands can be the following: - A scalar net - A vector
// net - A constant bit-select of a vector net - A part-select of a vector net
// - A concatenation of structural net expressions". §12.3.3: an output port
// "declared as a variable" is that variable. Nothing restricts the external
// item by how the port is declared inside, so an `output reg` drives a
// part-select, a bit-select or a concatenation exactly as an output net does.
//
// HAND DERIVATION: u[j] (a generate loop, j = 0..2) is a register loaded with
// 8'h10 + j at t=1, its output connected to the indexed part-select
// flat[8*j +: 8]: flat = {8'h12, 8'h11, 8'h10} = 24'h121110. b's 4-bit
// variable q = 4'b1001 drives the concatenation {w[0], v[2:0]}: §6.5.7.1 joins
// operands highest-order first, so w[0] = q[3] = 1 and v[2:0] = 3'b001; w[1]
// and v[3] are undriven, z. At t=2: "121110 z1 z001".
//! inherited IEEE 1364-2005 12.3.9.2 12.3.3
`timescale 1ns/1ns
module r8(input clk, input [7:0] d, output reg [7:0] q);
  always @(posedge clk) q <= d;
endmodule
module b(output reg [3:0] q);
  initial q = 4'b1001;
endmodule
module b_12_3_9_2_variable_port_select_sinks;
  reg clk;
  wire [23:0] flat;
  wire [1:0] w;
  wire [3:0] v;
  genvar j;
  generate for (j = 0; j < 3; j = j + 1) begin : g
    wire [7:0] d = 8'h10 + j;
    r8 u(.clk(clk), .d(d), .q(flat[8*j +: 8]));
  end endgenerate
  b ub(.q({w[0], v[2:0]}));
  initial begin
    clk = 0;
    #1 clk = 1;
    #1 $display("%h %b %b", flat, w, v);
    $finish(0);
  end
endmodule
