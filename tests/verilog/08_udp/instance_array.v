// IEEE 1364-2005 §8.6, p. 113: "An optional range may be specified for an
// array of UDP instances. The port connection rules remain the same as
// outlined in 7.1."
// §7.1.6, p. 78: "If bit lengths are different, each instance shall get a
// part-select of the port expression as specified in the range, starting
// with the right-hand index."
//
// g[3:0] is four inverters with 1-bit terminals; the 4-bit terminals q and
// a are split one bit per instance, g[0] taking bit 0, so q = ~a bitwise.
//   a = 4'b0011 -> q = 1100;  a = 4'b1010 -> q = 0101
//! inherited IEEE 1364-2005 8.6
`timescale 1ns/1ns
primitive inv(q, a);
  output q;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module b_8_6_instance_array;
  reg [3:0] a;
  wire [3:0] q;
  inv g[3:0] (q, a);
  initial begin
    a = 4'b0011;
    #1 $display("%b", q);
    a = 4'b1010;
    #1 $display("%b", q);
    $finish(0);
  end
endmodule
