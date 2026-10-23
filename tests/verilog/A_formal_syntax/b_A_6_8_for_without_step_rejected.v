// IEEE 1364-2005 A.6.8, p. 499:
//   loop_statement ::= ... | for ( variable_assignment ; expression ; variable_assignment ) statement
// A for loop's header has all three parts: an initial assignment, a
// condition and a step assignment, none optional.
//
// `for (i = 0; i < 3) ...` has no step. Legal neighbour:
// b_A_6_8_looping_statements.v (`for (i = 0; i < 4; i = i + 1)`).
//! inherited IEEE 1364-2005 A.6.8
//! reject E0207
//! reject unexpected token: found `)`
//! neighbour b_A_6_8_looping_statements.v
module b_A_6_8_for_without_step_rejected;
  integer i;
  initial begin
    for (i = 0; i < 3) i = i + 1;
    $display("unreachable");
  end
endmodule
