// IEEE 1364-2005 §14.2.3, Syntax 14-4, p. 214, places an edge-sensitive
// path's polarity operator after the destination, never before the arrow:
//   parallel_edge_sensitive_path_description ::=
//     ( [ edge_identifier ] specify_input_terminal_descriptor =>
//       ( specify_output_terminal_descriptor [ polarity_operator ] :
//         data_source_expression ) )
// and §14.2.7.2, p. 221: "A module path with positive polarity shall be
// specified by prefixing the + polarity operator to => or *>." — which
// Syntax 14-3 allows only on the simple paths.
//
// ( posedge clock +=> ( out : in ) ) puts + before => on an edge-sensitive
// path. Legal neighbour: edge_sensitive_paths.v's
// ( posedge clock => ( out +: in ) ).
//! inherited IEEE 1364-2005 14.2.7 14.2.3
//! reject polarity
//! neighbour edge_sensitive_paths.v
`timescale 1ns/1ns
module b_14_2_7_edge_path_polarity_placement_rejected(clock, in, out);
  input clock, in;
  output out;
  reg out;
  always @(posedge clock) out <= in;
  specify
    ( posedge clock +=> ( out : in ) ) = (10, 8);
  endspecify
endmodule
