// IEEE 1364-2005 §4.9: "Arrays can be used to group elements of the declared
// element type into multidimensional objects. ... Each dimension shall be
// represented by an address range." No dimension count is stated. VerA
// refused a 17th dimension (E1100) until 2026-10 (#29): the runner gathered
// one index per dimension in a 16-entry table. It now builds the row-major
// offset innermost dimension first and keeps no table.
//
// HAND DERIVATION.
//   w is a net array of 17 dimensions, sixteen [0:0] then [0:1]: the two
//     elements differ only in the last index. One is driven 1, the other 0,
//     so w[0]..[0][1] reads 1 and w[0]..[0][0] reads 0.
//   m is a 4-bit reg array of 40 dimensions: [0:1], thirty-eight [0:0], then
//     [2:0] (a descending range, addressed by value, §4.9). It holds
//     2 * 1 * 3 = 6 elements. m[1][0]..[0][2] = 9 and m[0][0]..[0][0] = 3
//     are written with constant indices; m[i][0]..[0][j] with i = 1, j = 1
//     is written 5 with variable indices. Reading back:
//       m[1]..[2] = 9, m[0]..[0] = 3, m[1]..[1] (constant) = 5,
//       m[0]..[1] was never written: x (§3.2 a reg starts at x),
//       m[i]..[3] with j = 3 is outside [2:0]: §5.2.1 reads x.
//   %d of a 4-bit operand pads to 2 columns (15 has 2 digits).
//! inherited IEEE 1364-2005 4.9
//! expect stdout array_17_dimensions.expected.txt
module b_4_9_array_17_dimensions;
  wire w [0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:1];
  assign w[0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][1] = 1'b1;
  assign w[0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0] = 1'b0;
  reg [3:0] m [0:1][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][0:0][2:0];
  integer i, j;
  initial begin
    m[1][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][2] = 4'd9;
    m[0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0] = 4'd3;
    i = 1; j = 1;
    m[i][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][j] = 4'd5;
    #1 $display("%b %b", w[0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][1], w[0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0]);
    $display("%d %d %d", m[1][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][2], m[0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0], m[1][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][1]);
    j = 3;
    $display("%d %d", m[0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][1], m[i][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][0][j]);
  end
endmodule
