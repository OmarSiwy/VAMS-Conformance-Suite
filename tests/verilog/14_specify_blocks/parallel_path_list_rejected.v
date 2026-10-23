// IEEE 1364-2005 §14.2.2, Syntax 14-3, p. 213:
//   parallel_path_description ::=
//     ( specify_input_terminal_descriptor [ polarity_operator ] =>
//       specify_output_terminal_descriptor )
//   full_path_description ::=
//     ( list_of_path_inputs [ polarity_operator ] *> list_of_path_outputs )
// Only the full form takes a list; the parallel form takes one terminal on
// each side.
//
// (C, D => Q) writes a list of two sources before =>. Legal neighbour:
// module_paths.v's (C, D *> Q) = 18, the clause's own example.
//! inherited IEEE 1364-2005 14.2.2
//! reject E0207
//! reject a parallel path
//! neighbour module_paths.v
`timescale 1ns/1ns
module b_14_2_2_parallel_path_list_rejected(C, D, Q);
  input C, D;
  output Q;
  assign Q = C ^ D;
  specify
    (C, D => Q) = 18;
  endspecify
endmodule
