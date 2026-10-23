// IEEE 1364-2005 §14.2.1, p. 213: "The module path source shall be a net
// that is connected to a module input port or inout port."
// Syntax 14-3 (p. 213) says the same in the grammar:
//   specify_input_terminal_descriptor ::= input_identifier [ ... ]
//   input_identifier ::= input_port_identifier | inout_port_identifier
//
// The path (q => y) takes its source from q, an output port. Legal neighbour:
// module_paths.v, whose sources are input ports and the inout io.
//! inherited IEEE 1364-2005 14.2.1
//! reject module path source
//! neighbour module_paths.v
`timescale 1ns/1ns
module b_14_2_1_source_output_port_rejected(a, q, y);
  input a;
  output q, y;
  assign q = a;
  assign y = ~q;
  specify
    (q => y) = 1;
  endspecify
endmodule
