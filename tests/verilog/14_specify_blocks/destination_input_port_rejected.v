// IEEE 1364-2005 §14.2.1, p. 213: "The module path destination shall be a
// net or variable that is connected to a module output port or inout port."
// Syntax 14-3 (p. 213):
//   specify_output_terminal_descriptor ::= output_identifier [ ... ]
//   output_identifier ::= output_port_identifier | inout_port_identifier
//
// The path (a => b) ends at b, an input port. Legal neighbour:
// module_paths.v, whose destinations are output ports.
//! inherited IEEE 1364-2005 14.2.1
//! reject module path destination
//! neighbour module_paths.v
`timescale 1ns/1ns
module b_14_2_1_destination_input_port_rejected(a, b, q);
  input a, b;
  output q;
  assign q = a & b;
  specify
    (a => b) = 1;
  endspecify
endmodule
