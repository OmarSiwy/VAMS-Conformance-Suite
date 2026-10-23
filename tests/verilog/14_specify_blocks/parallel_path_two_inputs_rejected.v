//! inherited IEEE 1364-2005 A.7.2
//! reject connects one source to one destination
// A parallel path (=>) has one input and one output terminal; a comma list
// needs the full path *> (pr1877743).
module triage_parallel_path_two_inputs_rejected(a, b, ci, co);
  input a, b, ci;
  output co;

  specify
    (a, b, ci => co) = 1;
  endspecify
endmodule
