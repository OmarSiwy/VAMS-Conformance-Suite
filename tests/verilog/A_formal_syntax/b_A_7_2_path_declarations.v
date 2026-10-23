// IEEE 1364-2005 A.7.2, p. 500:
//   path_declaration ::= simple_path_declaration ; | edge_sensitive_path_declaration ;
//     | state_dependent_path_declaration ;
//   simple_path_declaration ::= parallel_path_description = path_delay_value
//     | full_path_description = path_delay_value
//   parallel_path_description ::= ( specify_input_terminal_descriptor [ polarity_operator ] =>
//     specify_output_terminal_descriptor )
//   full_path_description ::= ( list_of_path_inputs [ polarity_operator ] *> list_of_path_outputs )
//   list_of_path_inputs ::= specify_input_terminal_descriptor { , specify_input_terminal_descriptor }
//   list_of_path_outputs ::= specify_output_terminal_descriptor { , specify_output_terminal_descriptor }
// A.7.4, p. 501:
//   edge_sensitive_path_declaration ::= parallel_edge_sensitive_path_description = path_delay_value
//     | full_edge_sensitive_path_description = path_delay_value
//   parallel_edge_sensitive_path_description ::= ( [ edge_identifier ] specify_input_terminal_descriptor =>
//     ( specify_output_terminal_descriptor [ polarity_operator ] : data_source_expression ) )
//   full_edge_sensitive_path_description ::= ( [ edge_identifier ] list_of_path_inputs *>
//     ( list_of_path_outputs [ polarity_operator ] : data_source_expression ) )
//   edge_identifier ::= posedge | negedge
//   state_dependent_path_declaration ::= if ( module_path_expression ) simple_path_declaration
//     | if ( module_path_expression ) edge_sensitive_path_declaration
//     | ifnone simple_path_declaration
//   polarity_operator ::= + | -
//
// (The edge-sensitive and state-dependent productions are printed in A.7.4
// in the standard; they are A.7.2's path_declaration alternatives.)
// b_A_7_2_cell's specify block declares: a parallel path with + polarity; a
// full path from two inputs to two outputs with - polarity; a parallel
// posedge path with a data source; a full negedge path; a state-dependent
// simple path (if), a state-dependent edge path (if) and an ifnone path.
// Every input transitions at time 0, and each output's change takes its active
// paths' smallest delay (§14.3.3), at most 7, so by t=10 the cell shows its
// assignments: a = 1, b = 0, clk = 1 -> y = a & b = 0, z = a | b = 1, q = a = 1.
// Output: "y=0 z=1 q=1".
//! inherited IEEE 1364-2005 A.7.2
`timescale 1ns/1ns
module b_A_7_2_cell (a, b, clk, y, z, q);
  input a, b, clk;
  output y, z, q;
  assign y = a & b;
  assign z = a | b;
  assign q = a;
  specify
    (a + => y) = 1;
    (a, b - *> y, z) = 2;
    (posedge clk => (q + : a)) = 3;
    (negedge clk *> (q, z - : b)) = 4;
    if (a) (b => z) = 5;
    if (!b) (posedge clk => (q : a)) = 6;
    ifnone (b => y) = 7;
  endspecify
endmodule
module b_A_7_2_path_declarations;
  wire y, z, q;
  b_A_7_2_cell c (1'b1, 1'b0, 1'b1, y, z, q);
  initial #10 begin
    $display("y=%b z=%b q=%b", y, z, q);
    $finish(0);
  end
endmodule
