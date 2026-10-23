// IEEE 1364-2005 A.3.1, p. 494:
//   n_input_gate_instance ::= [ name_of_gate_instance ]
//     ( output_terminal , input_terminal { , input_terminal } )
// An n-input gate names an output terminal and at least one input terminal.
//
// `and a1 (y);` has an output terminal and no input terminal. Legal
// neighbour: b_A_3_1_gate_instantiations.v (`g1 (y_and, a, b)`).
//! inherited IEEE 1364-2005 A.3.1
//! reject E0209
//! reject an n-input gate takes an output and at least one input
//! neighbour b_A_3_1_gate_instantiations.v
module b_A_3_1_missing_input_terminal_rejected;
  wire y;
  and a1 (y);
  initial $display("unreachable");
endmodule
