// IEEE 1364-2005 §12.4, p. 181: "The keywords generate and endgenerate may be
// used in a module to define a generate region. A generate region is a textual
// span in the module description where generate constructs may appear. Use of
// generate regions is optional. There is no semantic difference in the module
// when a generate region is used." "A generate block is a collection of one or
// more module items. ... All other module items, including other generate
// constructs, are allowed in a generate block."
//
// The clause's gray-to-binary converter (§12.4.1 Example 2, p. 184) with one
// always block per bit instead of one continuous assign, three times: inside
// generate/endgenerate (g2b1), without the region (g2b2), and with the loop
// body holding a nested if-generate that picks between two equivalent
// statements by the constant i (g2b3). gray is set at t = 1, after every
// always block waits on it, so the update is not a time-0 race.
// bin[i] = ^gray[7:i]; gray = 8'b1100_1010:
//   bin[7] = 1, [6] = 1^1 = 0, [5] = 0^0 = 0, [4] = 0^0 = 0,
//   [3] = 0^1 = 1, [2] = 1^0 = 1, [1] = 1^1 = 0, [0] = 0^0 = 0
//   -> 10001100 for all three, printed at t = 2.
//! lrm 6.6
//! lrm 6.6:3
//! lrm 6.6:5
//! lrm 6.6:4
//! inherited IEEE 1364-2005 12.4
`timescale 1ns/1ns
module g2b1 (bin, gray);
  output [7:0] bin;
  input [7:0] gray;
  reg [7:0] bin;
  genvar i;
  generate
    for (i=0; i<8; i=i+1) begin:bit
      always @(gray) bin[i] = ^gray[7:i];
    end
  endgenerate
endmodule
module g2b2 (bin, gray);
  output [7:0] bin;
  input [7:0] gray;
  reg [7:0] bin;
  genvar i;
  for (i=0; i<8; i=i+1) begin:bit
    always @(gray) bin[i] = ^gray[7:i];
  end
endmodule
module g2b3 (bin, gray);
  output [7:0] bin;
  input [7:0] gray;
  reg [7:0] bin;
  genvar i;
  for (i=0; i<8; i=i+1) begin:bit
    if (i == 7) begin:msb
      always @(gray) bin[i] = gray[i];
    end else begin:rest
      always @(gray) bin[i] = ^gray[7:i];
    end
  end
endmodule
module b_12_4_generate_region_optional;
  reg [7:0] gray;
  wire [7:0] b1, b2, b3;
  g2b1 u1(b1, gray);
  g2b2 u2(b2, gray);
  g2b3 u3(b3, gray);
  initial begin
    #1 gray = 8'b1100_1010;
    #1 $display("%b %b %b", b1, b2, b3);
  end
endmodule
