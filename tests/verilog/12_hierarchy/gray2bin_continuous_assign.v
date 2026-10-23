// IEEE 1364-2005 §12.4.1, p. 184, Example 2: "A parameterized gray-code-to-
// binary-code converter module using a loop to generate continuous
// assignments", whose body is `assign bin[i] = ^gray[SIZE-1:i];` with the
// comment "i refers to the implicitly defined localparam whose value in each
// instance of the generate block is the value of the genvar when it was
// elaborated." §6.1.1, Table 6-1, p. 68: a continuous assignment's left-hand
// side may be a "Constant bit-select of a vector net".
//
// The clause's module, SIZE = 8, as written. Each generate block instance
// drives one bit of bin; gray = 8'b1100_1010 at t = 1:
//   bin[7] = 1, [6] = 1^1 = 0, [5] = 0^0 = 0, [4] = 0^0 = 0,
//   [3] = 0^1 = 1, [2] = 1^0 = 1, [1] = 1^1 = 0, [0] = 0^0 = 0
//   -> 10001100 at t = 2.
//! inherited IEEE 1364-2005 12.4.1 6.1.1
`timescale 1ns/1ns
module gray2bin1 (bin, gray);
  parameter SIZE = 8;
  output [SIZE-1:0] bin;
  input [SIZE-1:0] gray;
  genvar i;
  generate
    for (i=0; i<SIZE; i=i+1) begin:bit
      assign bin[i] = ^gray[SIZE-1:i];
    end
  endgenerate
endmodule

module b_12_4_1_gray2bin_continuous_assign;
  reg [7:0] gray;
  wire [7:0] bin;
  gray2bin1 u(bin, gray);
  initial begin
    #1 gray = 8'b1100_1010;
    #1 $display("%b", bin);
    $finish(0);
  end
endmodule
