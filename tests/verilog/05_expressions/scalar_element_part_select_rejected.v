// IEEE 1364-2005 §5.2.2, p. 58, the clause's own illegal example:
//   "threed_array[14][1][3:0]                       // Illegal"
// for "wire threed_array[0:255][0:255][0:7];", of which the clause says
// "the array threed_array accesses a single bit of the three-dimensional
// array". The same clause says why [3:0] is illegal: "To express bit-selects
// or part-selects of array elements, the desired word shall first be
// selected by supplying an address for each dimension." threed_array[14][1]
// supplies two of three addresses, so [3:0] stands where the third address
// belongs: a part-select of the third dimension, not of a word.
//
// Legal neighbour: element_selects.v part-selects the 8-bit words of
// twod_array.
//! inherited IEEE 1364-2005 5.2.2
//! reject E1100
//! reject each array dimension takes an index
//! neighbour element_selects.v
module b_5_2_2_scalar_element_part_select_rejected;
  wire threed_array[0:255][0:255][0:7];
  initial $display("%b", threed_array[14][1][3:0]);
endmodule
