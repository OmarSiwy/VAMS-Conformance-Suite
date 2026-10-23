// IEEE 1364-2005 §12.3.8, p. 179: "the item receiving the value through the
// port (the internal item for inputs, the external item for outputs) shall be
// a structural net expression. The item that provides the value can be any
// expression." §12.3.9.1, p. 179: "An input or inout port shall be of type
// net." §12.3.9.2, p. 179: "A structural net expression is a port expression
// whose operands can be the following: - A scalar net - A vector net - A
// constant bit-select of a vector net - A part-select of a vector net - A
// concatenation of structural net expressions".
//
// m: input [1:0] a and inout io are nets (§12.3.9.1); y = a; io = a[0].
// r = 4'b1001.
//   u1: a from the expression r[3:2] & 2'b11 = 10; y into the concatenation
//       {hi1, hi0} -> hi1 = 1, hi0 = 0; io = a[0] = 0.
//   u2: a from the constant 2'b01; y into the vector net lo -> 01.
//   u3: a from the part-select r[1:0] = 01; y into the vector net w2 -> 01.
// -> "10 01 0 01"
//! inherited IEEE 1364-2005 12.3.8 12.3.9 12.3.9.1 12.3.9.2
`timescale 1ns/1ns
module m(input [1:0] a, output [1:0] y, inout io);
  assign y = a;
  assign io = a[0];
endmodule
module b_12_3_8_structural_sinks_and_expression_sources;
  reg [3:0] r;
  wire [1:0] lo, w2;
  wire hi1, hi0, io;
  m u1(r[3:2] & 2'b11, {hi1, hi0}, io);
  m u2(2'b01, lo, );
  m u3(r[1:0], w2, );
  initial begin
    r = 4'b1001;
    #1 $display("%b%b %b %b %b", hi1, hi0, lo, io, w2);
  end
endmodule
