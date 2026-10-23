// IEEE 1364-2005 §5.2.2, p. 58: "The syntax for access to the array shall
// consist of the name of the memory or array and an integer expression for
// each addressed dimension" ... "To express bit-selects or part-selects of
// array elements, the desired word shall first be selected by supplying an
// address for each dimension."
//
// twod has two unpacked dimensions; twod[1] supplies one address and so
// names a row of words, not a word, and cannot be read into w (§4.9, p. 34:
// "Nor can complete or partial array dimensions be used to provide a value to
// an expression."). Legal neighbour: twod_array[row][col] in
// memory_indirection.v.
//! inherited IEEE 1364-2005 5.2.2 4.9
//! reject E1100
//! reject an unpacked array reference requires an element index
//! neighbour memory_indirection.v
module b_5_2_2_partial_address_rejected;
  reg [7:0] twod[0:3][0:3];
  reg [7:0] w;
  initial begin
    w = twod[1];
    $display("%h", w);
  end
endmodule
