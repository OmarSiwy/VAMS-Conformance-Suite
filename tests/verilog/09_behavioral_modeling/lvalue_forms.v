// IEEE 1364-2005 §9.2, p. 117: "The left-hand side of a procedural assignment
// can take one of the following forms: — reg, integer, real, realtime, or time
// data type: an assignment to the name reference of one of these data types.
// — Bit-select of a reg, integer, or time data type: an assignment to a single
// bit that leaves the other bits untouched. — Part-select of a reg, integer,
// or time data type: a part-select of one or more contiguous bits that leaves
// the rest of the bits untouched. — Memory word: a single word of a memory.
// — Concatenation or nested concatenation of any of the above: ..."
// (The concatenation form is concatenation_lvalue.v.)
// "If the right-hand side is unsigned, it is padded according to the rules
// specified in 5.4.1. If the right-hand side is signed, it is sign-extended."
//
//   r = 8'b10101010; r[0] = 1       -> 10101011 (bits 7..1 untouched)
//   r[5:2] = 4'b0110                -> bit7 1, bit6 0, bits 5..2 0110,
//                                      bits 1..0 11 -> 10011011
//   m[2] = 4'hc; m[1] = 4'h3        -> m[2] = c, m[1] = 3, m[0] still 0
//   i = 0; i[4] = 1                 -> integer 16
//   t = 0; t[3:1] = 3'b111          -> time 14
//   x = 2.5                         -> real 2.5
//   u = s4, s4 = 4'sb1010 (signed)  -> sign-extended to 11111010
//   u = 4'b1010 (unsigned)          -> zero-padded to 00001010
//! inherited IEEE 1364-2005 9.2
module b_9_2_lvalue_forms;
  reg [7:0] r, u;
  reg [3:0] m [0:2];
  integer i;
  time t;
  real x;
  reg signed [3:0] s4;

  initial begin
    r = 8'b10101010;
    r[0] = 1'b1;
    $display("%b", r);
    r[5:2] = 4'b0110;
    $display("%b", r);
    m[0] = 4'h0;
    m[2] = 4'hc;
    m[1] = 4'h3;
    $display("%h %h %h", m[2], m[1], m[0]);
    i = 0;
    i[4] = 1'b1;
    t = 0;
    t[3:1] = 3'b111;
    x = 2.5;
    $display("%0d %0d %0.1f", i, t, x);
    s4 = 4'sb1010;
    u = s4;
    $display("%b", u);
    u = 4'b1010;
    $display("%b", u);
    $finish(0);
  end
endmodule
