// IEEE 1364-2005 §6, p. 68, Table 6-1 "Legal left-hand forms in assignment
// statements": for a continuous assignment "Constant bit-select of a vector
// net", "Constant part-select of a vector net" and "Concatenation or nested
// concatenation of any of the above left-hand side"; for a procedural
// assignment "Concatenation or nested concatenation of any of the above
// left-hand side".
//
// The Table 6-1 rows table_6_1_left_hand_forms.v cannot run. Reads at
// time 1; a = 1, r8 = 8'hA5 = 1010_0101.
// Continuous:
//   bs[0] = a, bs[7] = ~a; bits 6:1 have no driver, so z (§4.2.1)
//                                   -> 0zzzzzz1
//   ps[7:4] = r8[3:0], ps[3:0] = r8[7:4]   -> 0101_1010 -> 01011010
//   {c3, c2} = 3'b101               -> c3 = 1, c2 = 01
//   {c4, {c5, c6}} = 7'b1010_01_1   -> c4 = 1010, c5 = 01, c6 = 1
//   {pb[3], pp[1:0]} = 3'b011       -> pb = 0zzz, pp = zz11
// Procedural:
//   {p, {q, r1}} = 9'b1010_0110_1   -> p = 1010, q = 0110, r1 = 1
//   rw = 0; {rw[0], rw[7:6]} = 3'b110      -> rw[0] = 1, rw[7:6] = 10
//                                   -> 1000_0001 -> 81
//! inherited IEEE 1364-2005 6
module b_6_table_6_1_select_and_concatenation_lhs;
  reg a;
  reg [7:0] r8;
  wire [7:0] bs, ps;
  wire c3, c6;
  wire [1:0] c2, c5;
  wire [3:0] c4, pb, pp;
  assign bs[0] = a;
  assign bs[7] = ~a;
  assign ps[7:4] = r8[3:0];
  assign ps[3:0] = r8[7:4];
  assign {c3, c2} = 3'b101;
  assign {c4, {c5, c6}} = 7'b1010_01_1;
  assign {pb[3], pp[1:0]} = 3'b011;

  reg r1;
  reg [3:0] p, q;
  reg [7:0] rw;
  initial begin
    a = 1;
    r8 = 8'hA5;
    {p, {q, r1}} = 9'b1010_0110_1;
    rw = 0; {rw[0], rw[7:6]} = 3'b110;
    #1;
    $display("%b %b", bs, ps);
    $display("%b %b %b %b %b %b %b", c3, c2, c4, c5, c6, pb, pp);
    $display("%b %b %b %h", p, q, r1, rw);
    $finish(0);
  end
endmodule
