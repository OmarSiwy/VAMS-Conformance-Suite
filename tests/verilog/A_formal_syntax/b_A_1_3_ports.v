// IEEE 1364-2005 A.1.3, p. 487-488:
//   module_parameter_port_list ::= # ( parameter_declaration { , parameter_declaration } )
//   list_of_ports ::= ( port { , port } )
//   list_of_port_declarations ::= ( port_declaration { , port_declaration } ) | ()
//   port ::= [ port_expression ] | . port_identifier ( [ port_expression ] )
//   port_expression ::= port_reference | { port_reference { , port_reference } }
//   port_reference ::= port_identifier [ [ constant_range_expression ] ]
//   port_declaration ::= {attribute_instance} inout_declaration
//     | {attribute_instance} input_declaration | {attribute_instance} output_declaration
//
// b_A_1_3_old has a list_of_ports: an explicitly named port `.sel(s)` whose
// port_expression is the port_reference s, then the plain port_reference q.
// b_A_1_3_ansi has a module_parameter_port_list of two parameter_declarations
// and a list_of_port_declarations (one input, one output). The other port
// forms are pinned apart: the empty port (b_A_1_3_null_port.v), a
// concatenated port_expression (b_A_1_3_concat_port.v), a part-select
// port_reference (b_A_1_3_part_select_port.v).
//
// The top connects by position. old drives q = 8'd2 when sel = 1'b1:
// n8 = 2. ansi computes y = x + P + Q with P = 5 overridden to 7 by #(7) and
// Q = 1: x = 3 -> y = 11. Output: "n8=2 y=11".
//! inherited IEEE 1364-2005 A.1.3
`timescale 1ns/1ns
module b_A_1_3_old (.sel(s), q);
  input s;
  output [7:0] q;
  assign q = s ? 8'd2 : 8'd0;
endmodule
module b_A_1_3_ansi #(parameter P = 5, parameter Q = 1) (input [3:0] x, output [3:0] y);
  assign y = x + P + Q;
endmodule
module b_A_1_3_ports;
  wire [7:0] n8;
  wire [3:0] y;
  b_A_1_3_old o (1'b1, n8);
  b_A_1_3_ansi #(7) a (4'd3, y);
  initial #1 begin
    $display("n8=%0d y=%0d", n8, y);
    $finish(0);
  end
endmodule
