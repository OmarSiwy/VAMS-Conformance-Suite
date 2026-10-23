// IEEE 1364-2005 §19.5, p. 356: "Only white space or a comment may appear on
// the same line as the `include compiler directive."
//
// The identifier `wire_after` follows the file name on the `include line.
// Legal neighbour: include_inserts_contents.v, whose `include line
// ends in a comment.
//! inherited IEEE 1364-2005 19.5
//! reject E0144
//! reject text after the `include file name
//! neighbour include_inserts_contents.v
`include "constants.vams" wire_after
module b_19_5_include_trailing_text_rejected;
  initial $display("accepted");
endmodule
