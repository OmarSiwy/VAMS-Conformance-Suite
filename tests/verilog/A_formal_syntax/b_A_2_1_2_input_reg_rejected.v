// IEEE 1364-2005 A.2.1.2, p. 489:
//   input_declaration ::= input [ net_type ] [ signed ] [ range ] list_of_port_identifiers
//   output_declaration ::= ... | output reg [ signed ] [ range ] list_of_variable_port_identifiers
// Only an output_declaration has a `reg` alternative; an input's optional
// word is a net_type, and A.2.2.1's net_type does not include reg.
//
// `input reg a;` derives no input_declaration. Legal neighbour:
// b_A_2_1_2_port_declarations.v (`output reg signed [3:0] q`, `input en`).
//! inherited IEEE 1364-2005 A.2.1.2
//! reject E0207
//! reject gives a variable type to `output` only
//! neighbour b_A_2_1_2_port_declarations.v
module b_A_2_1_2_input_reg_rejected (a);
  input reg a;
  initial $display("unreachable");
endmodule
