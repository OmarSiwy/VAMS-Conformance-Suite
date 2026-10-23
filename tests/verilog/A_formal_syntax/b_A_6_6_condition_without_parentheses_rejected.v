// IEEE 1364-2005 A.6.6, p. 499:
//   conditional_statement ::= if ( expression ) statement_or_null [ else statement_or_null ]
//     | if_else_if_statement
//   if_else_if_statement ::= if ( expression ) statement_or_null
//     { else if ( expression ) statement_or_null } [ else statement_or_null ]
// Every condition is parenthesized.
//
// `if a b = 1;` has no parentheses around its condition. Legal neighbour:
// grammar_nullable_statement.v (`if (1) ; else ;`) and
// b_A_6_4_statements.v (`if (n == 2) n = n * 2;`).
//! inherited IEEE 1364-2005 A.6.6
//! reject E0207
//! reject unexpected token: found a
//! neighbour grammar_nullable_statement.v
//! neighbour b_A_6_4_statements.v
module b_A_6_6_condition_without_parentheses_rejected;
  reg a, b;
  initial begin
    a = 1;
    if a b = 1;
    $display("unreachable");
  end
endmodule
