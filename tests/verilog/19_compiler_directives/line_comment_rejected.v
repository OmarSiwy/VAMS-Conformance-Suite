// IEEE 1364-2005 §19.7, p. 357: "However, only white space may appear on the
// same line as the `line directive. Comments are not allowed on the same
// line as a `line directive. All parameters in the `line directive are
// required."
//
// The `line directive below is followed by a // comment on its line. Legal
// neighbour: line_directive.v, whose `line lines carry nothing after
// the level.
//! inherited IEEE 1364-2005 19.7
//! reject E0128
//! reject malformed `line directive
//! neighbour line_directive.v
`line 10 "orig.v" 0 // a comment
module b_19_7_line_comment_rejected;
  initial $display("accepted");
endmodule
