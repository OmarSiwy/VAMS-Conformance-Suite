// IEEE 1364-2005 A.7.2, p. 500:
//   parallel_path_description ::= ( specify_input_terminal_descriptor [ polarity_operator ] =>
//     specify_output_terminal_descriptor )
//   full_path_description ::= ( list_of_path_inputs [ polarity_operator ] *> list_of_path_outputs )
// A list of inputs belongs to the full (*>) connection; a parallel (=>) path
// has exactly one input terminal and one output terminal.
//
// `(a, b => y) = 1;` gives a parallel path two inputs. Legal neighbour:
// b_A_7_2_path_declarations.v (`(a, b - *> y, z) = 2;`, `(a + => y) = 1;`).
//! inherited IEEE 1364-2005 A.7.2
//! reject E0207
//! reject a parallel path (`=>`) connects one source to one destination
//! neighbour b_A_7_2_path_declarations.v
module b_A_7_2_parallel_path_two_inputs_rejected (a, b, y);
  input a, b;
  output y;
  assign y = a & b;
  specify
    (a, b => y) = 1;
  endspecify
endmodule
