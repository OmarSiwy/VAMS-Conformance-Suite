// IEEE 1364-2005 §7.1.5, pp. 77-78: "A [lhi:rhi] range specification shall
// represent an array of abs(lhi-rhi)+1 instances. Neither of the two constant
// expressions are required to be zero, and lhi is not required to be larger
// than rhi. If both constant expressions are equal, only one instance shall be
// generated." ... "It could be declared correctly as one array of eight
// instances or as two arrays with unique names of four elements each:
//   nand #2 t_nand[0:7]( ... );
//   nand #2 x_nand[0:3] ( ... ), y_nand[4:7] ( ... );"
//
// The clause's two legal forms, with 4-bit and 8-bit terminals (§7.1.6: each
// instance gets one bit, starting with the right-hand index).
//   x_nand[0:3]: a1=1100, b1=1010 -> ~(a1 & b1) = ~1000 = 0111
//   y_nand[4:7]: a2=0011, b2=1111 -> ~0011 = 1100
//   t_nand[0:7]: {a1,a2} = 11000011, {b1,b2} = 10101111
//     -> ~(10000011) = 01111100
//   one[5:5]: equal bounds, a single instance on 1-bit terminals:
//     ~(1 & 1) = 0
// Sampled at t=3, after the #2.
// Line: "0111 1100 01111100 0".
//! inherited IEEE 1364-2005 7.1.5
`timescale 1ns/1ns
module b_7_1_5_two_named_arrays;
  reg [3:0] a1, b1, a2, b2;
  reg s;
  wire [3:0] o1, o2;
  wire [7:0] o8;
  wire o;
  nand #2 x_nand[0:3] (o1, a1, b1), y_nand[4:7] (o2, a2, b2);
  nand #2 t_nand[0:7] (o8, {a1, a2}, {b1, b2});
  nand one[5:5] (o, s, s);
  initial begin
    a1 = 4'b1100; b1 = 4'b1010; a2 = 4'b0011; b2 = 4'b1111; s = 1;
    #3 $display("%b %b %b %b", o1, o2, o8, o);
    $finish(0);
  end
endmodule
