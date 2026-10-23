// IEEE 1364-2005 A.8.4, p. 506:
//   primary ::= ... | hierarchical_identifier [ { [ expression ] } [ range_expression ] ] | ...
// Selects on an identifier are index selects first and at most one
// range_expression last; nothing follows the range_expression.
//
// `v[7:4][1]` selects a bit of a part-select. Legal neighbour:
// b_A_8_4_primaries.v (`m[2][7:4]`: an index, then the range).
//! inherited IEEE 1364-2005 A.8.4
//! reject E1100
//! reject a select is of a whole vector or an unpacked array element
//! neighbour b_A_8_4_primaries.v
module b_A_8_4_select_after_range_rejected;
  reg [7:0] v;
  initial begin
    v = 8'hA5;
    $display("%b", v[7:4][1]);
  end
endmodule
