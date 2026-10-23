// IEEE 1364-2005 A.8.5, p. 506:
//   variable_lvalue ::= hierarchical_variable_identifier [ { [ expression ] } [ range_expression ] ]
//     | { variable_lvalue { , variable_lvalue } }
// An lvalue is a (selected) variable or a concatenation of lvalues; an
// operator expression is neither.
//
// `a + b = 4'd1;` assigns to the expression a + b. Legal neighbour:
// b_A_8_5_lvalues.v (`v[i +: 2] = 2'b01;`).
//! inherited IEEE 1364-2005 A.8.5
//! reject E0214
//! reject found `+`
//! neighbour b_A_8_5_lvalues.v
module b_A_8_5_expression_lvalue_rejected;
  reg [3:0] a, b;
  initial begin
    a + b = 4'd1;
    $display("unreachable");
  end
endmodule
