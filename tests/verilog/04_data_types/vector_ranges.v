// IEEE 1364-2005 §4.3.1, p. 24: "The most significant bit specified by the
// msb constant expression is the left-hand value in the range, and the least
// significant bit specified by the lsb constant expression is the right-hand
// value in the range. Both the msb constant expression and the lsb constant
// expression shall be constant integer expressions. The msb and lsb constant
// expressions may be any integer value — positive, negative, or zero. The lsb
// value may be greater than, equal to, or less than the msb value. Vector
// nets and regs shall obey laws of arithmetic modulo-2 to the power n (2n),
// where n is the number of bits in the vector. Vector nets and regs shall be
// treated as unsigned quantities, unless the net or reg is declared to be
// signed or is connected to a port that is declared to be signed (see
// 12.2.3)."
//
// reg [-1:4] b (the clause's "6-bit vector reg"), b = 6'b100001: b[-1] is the
//   MSB -> 1; b[4] the LSB -> 1; b[-1:0] -> 10.
// Modulo 2**4: reg [3:0] v = 15; v = v + 1 -> 0000 (%b), 0 (%0d).
// Unsigned unless signed: v = 4'b1000 reads 8; reg signed [3:0] s =
//   4'b1000 reads -8 (the clause's "a 4-bit vector in range -8 to 7").
// Bounds from constant integer expressions: parameter W = 3, reg [W:0] p
//   is 4 bits: {1'b1, p} with p = 4'hF -> 11111.
//! inherited IEEE 1364-2005 4.3.1
module b_4_3_1_vector_ranges;
  parameter W = 3;
  reg [-1:4] b;
  reg [3:0] v;
  reg signed [3:0] s;
  reg [W:0] p;
  initial begin
    b = 6'b100001;
    $display("%b %b %b", b[-1], b[4], b[-1:0]);
    v = 15;
    v = v + 1;
    $display("%b %0d", v, v);
    v = 4'b1000;
    s = 4'b1000;
    p = 4'hF;
    $display("%0d %0d %b", v, s, {1'b1, p});
    $finish(0);
  end
endmodule
