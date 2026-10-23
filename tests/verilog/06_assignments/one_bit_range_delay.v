// IEEE1364-2005 §6.1.3: "If the left-hand references a scalar net, then the
// delay shall be treated in the same way as for gate delays"; for a vector
// net, a transition that is neither to zero nor to z takes the rising delay.
// §4.3 calls a net 1 bit wide a scalar and a "Multibit" net a vector, so a
// `wire [0:0]` (a range, one bit) takes the gate rule: width decides
// (specification/Vague_Decisions.md VD-038).
// #(7,5,2), both nets start 0 and both drivers go to x at t=10:
//   s  [0:0]: gate rule, a transition to x takes min(7,5,2) = 2 -> due 12
//   v  [1:0]: vector rule, 00 -> xx is "otherwise", rising 7     -> due 17
// Samples at 13 (s moved, v not yet) and 18 (both moved).
//! inherited IEEE 1364-2005 6.1.3
`timescale 1ns/1ns
module b_6_1_3_one_bit_range_delay;
  reg [0:0] a;
  reg [1:0] b;
  wire [0:0] s;
  wire [1:0] v;
  assign #(7,5,2) s = a;
  assign #(7,5,2) v = b;
  initial begin
    a = 0; b = 0;
    #10 a = 1'bx; b = 2'bxx;
    #3 $display("t13 s=%b v=%b", s, v);
    #5 $display("t18 s=%b v=%b", s, v);
    $finish(0);
  end
endmodule
