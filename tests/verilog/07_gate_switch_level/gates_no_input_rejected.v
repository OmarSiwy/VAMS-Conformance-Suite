// Annex A.3.1:
//     n_input_gate_instance ::= [ name_of_gate_instance ]
//         ( output_terminal , input_terminal { , input_terminal } )
// One input terminal is mandatory, and IEEE 1364-2005 §7.2 asks for "one
// output and one or more inputs". `and g (y);` has the output and no input, so
// it is not derivable.
//
// The legal neighbour, one input, is gates_one_input.v.
//
//! lrm A.3.1
//! lrm A.3.1:1000
//! reject at least one input
//! neighbour gates_one_input.v
//! inherited IEEE 1364-2005 7.2
module d08_gates_no_input_rejected;
  wire y;
  and g (y);
endmodule
