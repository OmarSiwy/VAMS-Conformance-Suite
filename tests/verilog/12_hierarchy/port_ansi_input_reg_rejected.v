// IEEE 1364-2005 §12.3.4 puts the declarations of Syntax 12-4 in the header
// unchanged, and there only `output_declaration` has a variable arm:
//     input_declaration ::= input [ net_type ] [ signed ] [ range ]
//                           list_of_port_identifiers
// §12.3.9.1 Rule 1: "An input or inout port shall be of type net." So
// `input reg a` in a header is a syntax error, the neighbour of `output reg`.
//! inherited IEEE 1364-2005 12.3.4
//! reject E0207
`timescale 1ns/1ns
module audit_port_ansi_input_reg_rejected(input reg a);
endmodule
