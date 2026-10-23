// IEEE 1364-2005 §12.3.9.2, p. 179: "A structural net expression is a port
// expression whose operands can be the following: - A scalar net - A vector
// net - A constant bit-select of a vector net - A part-select of a vector net
// - A concatenation of structural net expressions". §12.3.8, p. 179: the
// external item for an output "shall be a structural net expression".
//
// w is wire [3:0]. u1's 2-bit output drives the part-select w[3:2] with 2'b10;
// u2's 1-bit output drives the constant bit-select w[1] with 1; u3 drives
// w[0] with 0. -> w = 4'b1010.
//! inherited IEEE 1364-2005 12.3.9.2 12.3.8
`timescale 1ns/1ns
module two(output [1:0] y);
  assign y = 2'b10;
endmodule
module one #(parameter V = 1'b0) (output y);
  assign y = V;
endmodule
module b_12_3_9_2_select_sinks;
  wire [3:0] w;
  two u1(w[3:2]);
  one #(1'b1) u2(w[1]);
  one #(1'b0) u3(w[0]);
  initial #1 $display("%b", w);
endmodule
