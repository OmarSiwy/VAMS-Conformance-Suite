// native-required
// IEEE 1364-2005 §5.2.2, p. 58: "To express bit-selects or part-selects of
// array elements, the desired word shall first be selected by supplying an
// address for each dimension. Once selected, bit-selects and part-selects
// shall be addressed in the same manner as net and reg bit-selects and
// part-selects (see 5.2.1)." §5.2, p. 56: "An array element or a bit-select
// or part-select of an array element can be referenced as an operand."
//
// The clause's examples, reg [7:0] twod_array[0:255][0:255] with
// twod_array[14][1] = 8'hC5 = 1100_0101 and twod_array[1][3] = 8'h40 =
// 0100_0000:
//   twod_array[14][1][3:0] -> 0101   ("access lower 4 bits of word")
//   twod_array[1][3][6]    -> 1      ("access bit 6 of word")
//   twod_array[1][3][sel], sel = 7 -> 0 ("use variable bit-select")
// One dimension, reg [7:0] mema[0:3], mema[2] = 8'h3C = 0011_1100:
//   mema[2][5:2] -> 1111, mema[2][0] -> 0
//! inherited IEEE 1364-2005 5.2.2 5.2
module b_5_2_2_element_selects;
  reg [7:0] twod_array[0:255][0:255];
  reg [7:0] mema[0:3];
  integer sel;
  initial begin
    twod_array[14][1] = 8'hC5;
    twod_array[1][3] = 8'h40;
    sel = 7;
    $display("%b %b %b", twod_array[14][1][3:0], twod_array[1][3][6], twod_array[1][3][sel]);
    mema[2] = 8'h3C;
    $display("%b %b", mema[2][5:2], mema[2][0]);
    $finish(0);
  end
endmodule
