// IEEE 1364-2005 A.1.2, p. 487: a module_declaration takes either
// "list_of_ports ;" or "[ list_of_port_declarations ] ;". A.1.3, p. 487-488:
//   list_of_ports ::= ( port { , port } )
//   list_of_port_declarations ::= ( port_declaration { , port_declaration } ) | ()
//   port ::= [ port_expression ] | . port_identifier ( [ port_expression ] )
//   port_declaration ::= {attribute_instance} inout_declaration
//     | {attribute_instance} input_declaration
//     | {attribute_instance} output_declaration
//
// `(a, input b)` starts a list_of_ports with the port `a`, and `input b` is
// no port; read as a list_of_port_declarations, `a` is no port_declaration.
// Neither list derives it. Legal neighbour: b_A_1_3_ports.v, one module with
// a list_of_ports and one with a list_of_port_declarations.
//! inherited IEEE 1364-2005 A.1.3
//! reject E0207
//! neighbour b_A_1_3_ports.v
module b_A_1_3_port_mixed_forms_rejected (a, input b);
  input a;
  initial $display("unreachable");
endmodule
