// IEEE 1364-2005 §12.1.2 applies §7.1.6's array connection rules: each
// instance takes its part of a port expression, starting at the right-hand
// instance index with the least significant bits.
// §7.1.6: "each instance shall get a part-select of the port expression as
// specified in the range, starting with the right-hand index."
//
// HAND DERIVATION. Four input bits split into two two-bit input ports.
// Each leaf swaps its two bits: 10_01 becomes 01_10, and 00_11 becomes
// 00_11. An ascending instance range assigns the low pair to index 1;
// descending assigns it to index 0. Joining each output through the same
// array direction reconstructs 0110 then 0011 in either case. Direct
// hierarchical reads also pin the right-hand instance's low pair.
// Rejection neighbour: instance_array_width_product_rejected.v uses
// an actual width that matches neither one port nor the complete array.
//! inherited IEEE 1364-2005 12.1.2 7.1.6
`timescale 1ns/1ns
module pair_swap(input [1:0] p, output [1:0] q);
  assign q = {p[0], p[1]};
endmodule
module b_12_instance_array_width_product;
  reg [3:0] p;
  wire [3:0] descending, ascending;
  pair_swap down[1:0](p, descending);
  pair_swap up[0:1](p, ascending);
  initial begin
    p = 4'b1001;
    #1 $display("down=%b up=%b low=%b/%b", descending, ascending, down[0].p, up[1].p);
    p = 4'b0011;
    #1 $display("down=%b up=%b low=%b/%b", descending, ascending, down[0].p, up[1].p);
  end
endmodule
