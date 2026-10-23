// IEEE 1364-2005 A.6.4, p. 498:
//   statement_or_null ::= statement | { attribute_instance } ;
// A.6.2, p. 497: initial_construct ::= initial statement
// A.6.4 keeps statement (never empty) apart from statement_or_null (which
// may be a lone `;`); an initial construct takes a statement.
//
// `initial ;` gives an initial construct the null statement. Legal
// neighbour: b_A_6_4_statements.v, whose `wait (m) ;` puts the null
// statement where statement_or_null allows it.
//! inherited IEEE 1364-2005 A.6.4
//! reject E0209
//! neighbour b_A_6_4_statements.v
module b_A_6_4_null_initial_statement_rejected;
  initial ;
  initial $display("unreachable");
endmodule
