// IEEE 1364-2005 §9.9.1, p. 143 (Syntax 9-15): "initial_construct ::= initial
// statement". A.6.4 (p. 498) keeps the null statement out of `statement`:
// "statement_or_null ::= statement | { attribute_instance } ;".
//
// `initial ;` gives the construct a null statement, which only
// statement_or_null derives. Legal neighbour: initial_and_always.v,
// whose initial constructs each carry a statement.
//! inherited IEEE 1364-2005 9.9.1
//! reject E0209
//! reject statement
//! neighbour initial_and_always.v
module b_9_9_1_initial_without_statement_rejected;
  initial ;
endmodule
