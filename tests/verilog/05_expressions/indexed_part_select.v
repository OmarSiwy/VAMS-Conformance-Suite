// native-required
// IEEE 1364-2005 §5.2.1, pp. 56-57: "The msb_base_expr and lsb_base_expr
// shall be integer expressions, and the width_expr shall be a positive
// constant integer expression. The lsb_base_expr and msb_base_expr can vary at
// run time. The first two examples select bits starting at the base and
// ascending the bit range. The number of bits selected is equal to the width
// expression. The second two examples select bits starting at the base and
// descending the bit range." ... "Part-selects that are partially out of
// range shall, when read, return x for the bits that are out of range and
// shall, when written, only affect the bits that are in range."
//
// The clause's equivalences (p. 57), with big_vect = 32'h89AB_CDEF in
// reg [31:0] and little_vect the same bits in reg [0:31] (little_vect[0] is
// the MSB, 1000...):
//   big_vect[0 +: 8]  == big_vect[7:0]   -> ef
//   big_vect[15 -: 8] == big_vect[15:8]  -> cd
//   little_vect[0 +: 8]  == little_vect[0:7]  -> 89 (the leftmost byte)
//   little_vect[15 -: 8] == little_vect[8:15] -> ab
//   dword[8*sel +: 8], dword = 64'h0123_4567_89AB_CDEF, sel = 2 -> bits
//     23:16 -> ab (a run-time base)
// Partially out of range, reg [7:0] v = 8'b1010_0101, base b = 6:
//   read v[b +: 4] = bits 9..6: bits 9 and 8 do not exist -> x;
//     v[7:6] = 10 -> xx10
//   write v[b +: 4] = 4'b0101: only bits 7:6 are written, with the low two
//     bits of the value, 01 -> v = 01_10_0101 -> 01100101
//! inherited IEEE 1364-2005 5.2.1
module b_5_2_1_indexed_part_select;
  reg [31:0] big_vect;
  reg [0:31] little_vect;
  reg [63:0] dword;
  reg [7:0] v;
  integer sel, b;
  initial begin
    big_vect = 32'h89AB_CDEF;
    little_vect = 32'h89AB_CDEF;
    dword = 64'h0123_4567_89AB_CDEF;
    sel = 2;
    $display("%h %h %h %h %h", big_vect[0 +: 8], big_vect[15 -: 8], little_vect[0 +: 8], little_vect[15 -: 8], dword[8*sel +: 8]);
    v = 8'b1010_0101;
    b = 6;
    $display("%b", v[b +: 4]);
    v[b +: 4] = 4'b0101;
    $display("%b", v);
    $finish(0);
  end
endmodule
