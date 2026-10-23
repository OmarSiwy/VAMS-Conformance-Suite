// IEEE 1364-2005 §19.7, p. 357: "The number parameter shall be a positive
// integer that specifies the newline number of the following text line."
//
// 0 is not positive. Legal neighbour: line_directive.v uses 3, 20
// and 7.
//! inherited IEEE 1364-2005 19.7
//! reject E0128
//! reject the line number must be a positive integer
//! neighbour line_directive.v
`line 0 "orig.v" 0
module b_19_7_line_number_rejected;
  initial $display("accepted");
endmodule
