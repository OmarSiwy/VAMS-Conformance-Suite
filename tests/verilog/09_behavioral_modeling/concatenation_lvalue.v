// IEEE 1364-2005 §9.2, p. 117: "— Concatenation or nested concatenation of any
// of the above: a concatenation or nested concatenation of any of the previous
// four forms. Such specification effectively partitions the result of the
// right-hand expression and assigns the partition parts, in order, to the
// various parts of the concatenation or nested concatenation."
// §9.2.1, p. 118, example: "{carry, acc} = rega + regb; // a concatenation"
//
//   {carry, acc} = rega + regb, rega = regb = 8'hc0: the RHS is sized by the
//     9-bit LHS (§5.4.1), 192 + 192 = 384 = 9'b1_1000_0000 -> carry 1, acc 80
//   {a, {b, c}} = 6'b10_110_1: a (2 bits) = 10, b (3) = 110, c (1) = 1
//   {r[1:0], m[1]} = 6'b01_1010: a part-select and a memory word, the first
//     two bits to r[1:0] = 01, the last four to m[1] = a; r[7:2] untouched
//     (r = 8'hff before -> r = 11111101)
//! inherited IEEE 1364-2005 9.2 9.2.1
module b_9_2_concatenation_lvalue;
  reg [7:0] rega, regb, acc, r;
  reg carry;
  reg [1:0] a;
  reg [2:0] b;
  reg c;
  reg [3:0] m [0:1];

  initial begin
    rega = 8'hc0;
    regb = 8'hc0;
    {carry, acc} = rega + regb;
    $display("%b %h", carry, acc);
    {a, {b, c}} = 6'b10_110_1;
    $display("%b %b %b", a, b, c);
    r = 8'hff;
    {r[1:0], m[1]} = 6'b01_1010;
    $display("%b %h", r, m[1]);
    $finish(0);
  end
endmodule
