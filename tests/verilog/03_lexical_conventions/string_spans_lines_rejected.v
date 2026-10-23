// IEEE 1364-2005 §3.6, p. 12: "A string is a sequence of characters enclosed
// by double quotes ("") and contained on a single line."
//
// The string below opens on one line and closes on the next. Legal
// neighbour: lexical_packed_strings.v, which writes the newline as the
// \n escape (Table 3-1) inside a one-line string.
//! inherited IEEE 1364-2005 3.6
//! reject E0138
//! reject may not span lines
//! neighbour lexical_packed_strings.v
module b_3_6_string_spans_lines_rejected;
  reg [23:0] s;
  initial begin
    s = "a
b";
    $display("%h", s);
  end
endmodule
