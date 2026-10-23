// IEEE 1364-2005 §5.2, pp. 55-56: "The simplest type is a reference to a net,
// variable, or parameter in its complete form; that is, just the name of the
// net, variable, or parameter is given. In this case, all of the bits making
// up the net, variable, or parameter value shall be used as the operand." ...
// "If a single bit of a vector net, vector reg, integer, or time variable, or
// parameter is required, then a bit-select operand shall be used. A
// part-select operand shall be used to reference a group of adjacent bits in a
// vector net, vector reg, integer, or time variable, or parameter." ... "A
// concatenation of other operands (including nested concatenations) can be
// specified as an operand. A function call is an operand."
//
// v = 8'hA5 = 1010_0101, net n = ~v = 0101_1010, P = 8'h3C = 0011_1100,
// i = -2 (integer, 32 bits of 1111...1110), t = 64'h1_0000_0000 (time).
//   whole: v -> a5, n -> 5a, P -> 3c
//   bit-selects: v[7] = 1, n[0] = 0, i[0] = 0, i[31] = 1, P[2] = 1, t[32] = 1
//   part-selects: v[3:0] = 0101, n[7:4] = 0101, i[3:0] = 1110, P[5:2] = 1111,
//                 t[35:32] = 0001
//   nested concatenation {v[7:6], {n[1:0], P[1:0]}} = 10_10_00 -> 101000
//   function call inv(v) = ~v -> 5a
//! inherited IEEE 1364-2005 5.2
module b_5_2_operand_forms;
  parameter P = 8'h3C;
  reg [7:0] v;
  wire [7:0] n = ~v;
  integer i;
  time t;
  function [7:0] inv;
    input [7:0] x;
    inv = ~x;
  endfunction
  initial begin
    v = 8'hA5;
    i = -2;
    t = 64'h1_0000_0000;
    #1;
    $display("%h %h %h", v, n, P);
    $display("%b%b%b%b%b%b", v[7], n[0], i[0], i[31], P[2], t[32]);
    $display("%b %b %b %b %b", v[3:0], n[7:4], i[3:0], P[5:2], t[35:32]);
    $display("%b %h", {v[7:6], {n[1:0], P[1:0]}}, inv(v));
    $finish(0);
  end
endmodule
