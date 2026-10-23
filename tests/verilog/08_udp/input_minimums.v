// IEEE 1364-2005 §8.1.2, p. 107: "Implementations may limit the maximum
// number of inputs to a UDP, but they shall allow at least 9 inputs for
// sequential UDPs and 10 inputs for combinational UDPs."
//
// and10: a combinational 10-input AND. Row 1 is all ones -> 1; rows 2-11
// put a 0 in one position and ? elsewhere -> 0. Any combination with an x
// and no 0 matches no row -> x (§8.2).
// latch9: a level-sensitive sequential UDP with 9 inputs: g is input 1, d
// is input 9, inputs 2-8 are ? in every row. g=1 loads d, g=0 holds.
//
// v drives and10's inputs 1..10 from v[9] down to v[0]; w drives latch9's
// inputs 2..8.
//   t=0  v = 10'b1111111111 -> 1                    t=1: "1"
//   t=1  v = 10'b1111111110 -> input 10 is 0 -> 0   t=2: "0"
//   t=2  v = 10'b111111111x -> no row matches -> x  t=3: "x"
//   t=3  w = 7'b0000000 (rows ignore inputs 2-8); g = 1 with d still x
//        matches no row -> x
//   t=4  d = 1 with g = 1 -> row 2 -> 1             t=5: "1"
//   t=5  d = 0 with g = 1 -> row 1 -> 0             t=6: "0"
//   t=6  g = 0 -> row 3 holds 0
//   t=7  d = 1 with g = 0 -> row 3 holds 0          t=8: "0"
//! inherited IEEE 1364-2005 8.1.2
`timescale 1ns/1ns
primitive and10(y, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10);
  output y;
  input i1, i2, i3, i4, i5, i6, i7, i8, i9, i10;
  table
    1 1 1 1 1 1 1 1 1 1 : 1;
    0 ? ? ? ? ? ? ? ? ? : 0;
    ? 0 ? ? ? ? ? ? ? ? : 0;
    ? ? 0 ? ? ? ? ? ? ? : 0;
    ? ? ? 0 ? ? ? ? ? ? : 0;
    ? ? ? ? 0 ? ? ? ? ? : 0;
    ? ? ? ? ? 0 ? ? ? ? : 0;
    ? ? ? ? ? ? 0 ? ? ? : 0;
    ? ? ? ? ? ? ? 0 ? ? : 0;
    ? ? ? ? ? ? ? ? 0 ? : 0;
    ? ? ? ? ? ? ? ? ? 0 : 0;
  endtable
endprimitive

primitive latch9(q, g, i2, i3, i4, i5, i6, i7, i8, d);
  output q;
  reg q;
  input g, i2, i3, i4, i5, i6, i7, i8, d;
  table
    1 ? ? ? ? ? ? ? 0 : ? : 0;
    1 ? ? ? ? ? ? ? 1 : ? : 1;
    0 ? ? ? ? ? ? ? ? : ? : -;
  endtable
endprimitive

module b_8_1_2_input_minimums;
  reg [9:0] v;
  reg [6:0] w;
  reg g, d;
  wire y, q;
  and10 u1(y, v[9], v[8], v[7], v[6], v[5], v[4], v[3], v[2], v[1], v[0]);
  latch9 u2(q, g, w[6], w[5], w[4], w[3], w[2], w[1], w[0], d);
  initial begin
    v = 10'b1111111111;
    #1 $display("%b", y);
    v = 10'b1111111110;
    #1 $display("%b", y);
    v = 10'b111111111x;
    #1 $display("%b", y);
    w = 7'b0000000;
    g = 1;
    #1 d = 1;
    #1 $display("%b", q);
    d = 0;
    #1 $display("%b", q);
    g = 0;
    #1 d = 1;
    #1 $display("%b", q);
    $finish(0);
  end
endmodule
