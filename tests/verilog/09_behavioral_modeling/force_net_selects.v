// IEEE 1364-2005 §9.3.2, p. 124: "The left-hand side of the assignment can be a
// variable, a net, a constant bit-select of a vector net, a part-select of a
// vector net, or a concatenation." ... "A force procedural statement on a net
// shall override all drivers of the net—gate outputs, module outputs, and
// continuous assignments—until a release procedural statement is executed on
// the net. When released, the net shall immediately be assigned the value
// determined by the drivers of the net."
//
// w is driven 0000 by a continuous assignment.
//   force w[2] = 1; force w[1:0] = 2'b11   -> w = 0111 (bit 3 still driven 0)
//   release w[2]                            -> bit 2 returns to its driver 0,
//                                              bits 1..0 stay forced -> 0011
//   release w[1:0]                          -> 0000
//! inherited IEEE 1364-2005 9.3.2
// native-required
`timescale 1ns/1ns
module b_9_3_2_force_net_selects;
  wire [3:0] w;
  assign w = 4'b0000;

  initial begin
    #1 force w[2] = 1'b1;
    force w[1:0] = 2'b11;
    #1 $display("%b", w);
    release w[2];
    #1 $display("%b", w);
    release w[1:0];
    #1 $display("%b", w);
    $finish(0);
  end
endmodule
