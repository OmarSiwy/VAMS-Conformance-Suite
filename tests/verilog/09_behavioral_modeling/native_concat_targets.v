// IEEE 1364-2005 §9.3, p. 122: the left-hand side of an assign "shall be a
// variable reference or a concatenation of variables", and a force's "can be
// a concatenation"; §9.3.2, p. 125: the assignment "shall be reevaluated"
// while it is in effect. A native executable gives each operand its window
// of the value, evaluated as wide as the whole target (§5.5's assignment of
// a concatenation: the rightmost operand takes the low bits).
//
//   assign {h, w} = {c, ~c}, h 4 bits and w 68 bits, c 72 bits:
//   the value {c, ~c} is 144 bits; the target is 72, so its low 72 bits,
//   ~c, are assigned (§5.5.1 truncation): h = ~c[71:68], w = ~c[67:0].
//     c = 72'h90_0000_0000_0000_0003: ~c = 72'h6f_ffff_ffff_ffff_fffc
//       -> h = 6, w = f_ffff_ffff_ffff_fffc (17 digits: 16 f, then c)
//     c = 0: ~c all ones -> h = f, w = 17 f digits
//   force {n2, n1} = {s, s} with s 2 bits, n2 and n1 1-bit nets driven 0:
//     s = 2'b10 -> {n2, n1} = 2'b10 (the low 2 bits of 4'b1010): n2 1, n1 0
//     s = 2'b01 -> n2 0, n1 1
//! inherited IEEE 1364-2005 9.3 9.3.1 9.3.2
// native-required
`timescale 1ns/1ns
module native_concat_targets;
  reg [71:0] c;
  reg [3:0] h;
  reg [67:0] w;
  reg [1:0] s;
  wire n2, n1;
  assign n2 = 1'b0;
  assign n1 = 1'b0;
  initial begin
    c = 72'h90_0000_0000_0000_0003;
    assign {h, w} = {c, ~c};
    #1 $display("%h %h", h, w);
    c = 72'h0;
    #1 $display("%h %h", h, w);
    s = 2'b10;
    force {n2, n1} = {s, s};
    #1 $display("%b %b", n2, n1);
    s = 2'b01;
    #1 $display("%b %b", n2, n1);
    $finish(0);
  end
endmodule
