// IEEE 1364-2005 §5.4.1, pp. 62-63: "Table 5-22 shows how the form of an
// expression shall determine the bit lengths of the results of the
// expression. In Table 5-22, i, j, and k represent expressions of an operand,
// and L(i) represents the bit length of the operand represented by i."
//
// A concatenation operand is self-determined (Table 5-22, last two rows), so
// {1'b1, e} prints a 1 followed by exactly L(e) bits: the position of the
// leading 1 reads the width of e. a = 4'b1111, b = 6'b000001, c = 2'b10.
// (Table 5-22's unsized-constant row is "Same as integer", whose size is
// implementation-dependent, at least 32 (§4.8); not asserted.)
//   sized constant 3'd5              L = 3:  1_101
//   a + b  (i op j, + - * / % & | ^ ^~ ~^): max(4,6) = 6: 15+1 = 16
//                                            1_010000
//   a & b                           6:       1_000001
//   -a     (op i, + - ~): L(a) = 4:  16-15 = 1 -> 1_0001
//   ~b                              6:       1_111110
//   a < b  (relational/equality): 1 bit: 15 < 1 = 0 -> 1_0
//   a === b                         1 bit:   1_0
//   a && b (logical): 1 bit:                 1_1
//   &a     (reduction and !): 1 bit:         1_1
//   !a                              1 bit:   1_0
//   a << 2 (shift and **, L(i), j self-determined): 4: 1111<<2 = 1100 -> 1_1100
//   c ** 3: L(c) = 2: 2**3 = 8 mod 4 = 0 -> 1_00
//   c ? a : b  (max(L(j),L(k)) = 6, a zero-extended): 1_001111
//   {a, c}  L(a)+L(c) = 6:                   1_111110
//   {2{c, a}}  2*(2+4) = 12:                 1_101111101111
//! inherited IEEE 1364-2005 5.4.1
module b_5_4_1_table_5_22_widths;
  reg [3:0] a;
  reg [5:0] b;
  reg [1:0] c;
  initial begin
    a = 4'b1111;
    b = 6'b000001;
    c = 2'b10;
    $display("%b %b %b %b %b", {1'b1, 3'd5}, {1'b1, a + b}, {1'b1, a & b}, {1'b1, -a}, {1'b1, ~b});
    $display("%b %b %b %b %b", {1'b1, a < b}, {1'b1, a === b}, {1'b1, a && b}, {1'b1, &a}, {1'b1, !a});
    $display("%b %b %b", {1'b1, a << 2}, {1'b1, c ** 3}, {1'b1, c ? a : b});
    $display("%b %b", {1'b1, {a, c}}, {1'b1, {2{c, a}}});
    $finish(0);
  end
endmodule
