// IEEE 1364-2005 A.8.7, p. 506-507, and its Details, p. 509: "2) Embedded
// spaces are illegal." (the footnote on real_number, unsigned_number and the
// value and base productions). A.9.4, p. 509: white_space ::= space | tab
// | newline | eof separates tokens; it cannot sit inside one.
//
// `8'b1010 0101` puts a space inside a binary_value, so the number ends at
// 1010 and 0101 is a stray token. Legal neighbour: b_A_9_4_white_space.v, and
// b_A_8_7_numbers.v (`8'B1010_zZXx`, the underscore that does separate digits).
//! inherited IEEE 1364-2005 A.9.4
//! reject E0207
//! reject unexpected token: found 0101
//! neighbour b_A_8_7_numbers.v
//! neighbour b_A_9_4_white_space.v
module b_A_9_4_embedded_space_rejected;
  reg [7:0] v;
  initial begin
    v = 8'b1010 0101;
    $display("%b", v);
  end
endmodule
