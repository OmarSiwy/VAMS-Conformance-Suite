// native-required
// IEEE 1364-2005 §6, p. 68, Table 6-1 "Legal left-hand forms in assignment
// statements": for a continuous assignment "Constant indexed part-select of a
// vector net"; for a procedural assignment "Indexed part-select of a vector
// reg, integer, or time variable".
//
// §5.2.1 (p. 56): a[base +: w] selects w bits ascending from base, a[base -: w]
// w bits descending from base.
// Continuous, a4 = 4'b0101 at time 0, read at time 1:
//   w8[0 +: 4] = a4   -> w8[3:0] = 0101
//   w8[7 -: 4] = ~a4  -> w8[7:4] = 1010      -> w8 = 10100101
// Procedural, k = 2 (a run-time base):
//   rv = 0; rv[k +: 4] = 4'b1111      -> rv[5:2] = 1111 -> 00111100
//   iv = 0; iv[31 -: 8] = 8'hAB       -> iv[31:24] = ab -> ab000000
//   tv = 0; tv[k*8 +: 8] = 8'hCD      -> tv[23:16] = cd -> 0000000000cd0000
//! inherited IEEE 1364-2005 6
module b_6_indexed_part_select_lhs;
  reg [3:0] a4;
  wire [7:0] w8;
  assign w8[0 +: 4] = a4;
  assign w8[7 -: 4] = ~a4;
  reg [7:0] rv;
  integer iv, k;
  time tv;
  initial begin
    a4 = 4'b0101;
    k = 2;
    rv = 0; rv[k +: 4] = 4'b1111;
    iv = 0; iv[31 -: 8] = 8'hAB;
    tv = 0; tv[k*8 +: 8] = 8'hCD;
    #1 $display("%b %b %h %h", w8, rv, iv, tv);
    $finish(0);
  end
endmodule
