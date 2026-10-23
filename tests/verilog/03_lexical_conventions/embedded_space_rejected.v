// IEEE 1364-2005 §3.5, p. 9, Syntax 3-1, footnote a to binary_value (among
// others): "Embedded spaces are illegal."
//
// binary_value ::= binary_digit { _ | binary_digit } has no blank, so
// 8'b1010 0101 is the number 8'b1010 followed by a stray 0101. Legal
// neighbour: number_forms.v, which separates digits with _ as in
// 16'b0011_0101_0001_1111.
//! inherited IEEE 1364-2005 3.5
//! reject E0207
//! reject unexpected token
//! neighbour number_forms.v
module b_3_5_embedded_space_rejected;
  reg [7:0] v;
  initial begin
    v = 8'b1010 0101;
    $display("%b", v);
  end
endmodule
