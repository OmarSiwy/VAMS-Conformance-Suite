// IEEE 1364-2005 §9.3.2, p. 124: "The left-hand side of the assignment can
// be ... a constant bit-select of a vector net, a part-select of a vector
// net"; the force overrides the net's drivers "until a release procedural
// statement is executed on the net. When released, the net shall
// immediately be assigned the value determined by the drivers of the net."
// A native executable holds the forced bits against the net's resolution
// and lets the rest follow the drivers. The select here spans the boundary
// between two 64-bit words.
//
// w is 70 bits, driven {70{d}}; w[69:60] is printed, bits 69 down to 60.
//   d = 0; force w[66:62] = 5'b10101            -> 000 10101 00
//   force w[66:62] = 5'b11111 (the same select) -> 000 11111 00
//   d = 1: the unforced bits follow the driver  -> 111 11111 11
//   d = 0                                        -> 000 11111 00
//   release w[66:62]: the driver's again         -> 000 00000 00
//! inherited IEEE 1364-2005 9.3.2
// native-required
`timescale 1ns/1ns
module native_force_net_selects;
  reg d;
  wire [69:0] w;
  assign w = {70{d}};
  initial begin
    d = 1'b0;
    #1 force w[66:62] = 5'b10101;
    #1 $display("%b", w[69:60]);
    force w[66:62] = 5'b11111;
    #1 $display("%b", w[69:60]);
    d = 1'b1;
    #1 $display("%b", w[69:60]);
    d = 1'b0;
    #1 $display("%b", w[69:60]);
    release w[66:62];
    #1 $display("%b", w[69:60]);
    $finish(0);
  end
endmodule
