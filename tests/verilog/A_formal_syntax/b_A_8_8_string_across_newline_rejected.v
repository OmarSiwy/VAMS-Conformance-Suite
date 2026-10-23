// IEEE 1364-2005 A.8.8, p. 507:
//   string ::= " { Any_ASCII_Characters_except_new_line } "
// A string ends on the line it starts on.
//
// The string below opens on one line and closes on the next. Legal
// neighbour: b_A_8_8_strings.v.
//! inherited IEEE 1364-2005 A.8.8
//! reject E0138
//! reject a string literal may not span lines
//! neighbour b_A_8_8_strings.v
module b_A_8_8_string_across_newline_rejected;
  initial $display("one
two");
endmodule
