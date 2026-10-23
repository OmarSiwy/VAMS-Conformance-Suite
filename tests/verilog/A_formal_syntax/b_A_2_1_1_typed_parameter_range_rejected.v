// IEEE 1364-2005 A.2.1.1, p. 489:
//   local_parameter_declaration ::=
//       localparam [ signed ] [ range ] list_of_param_assignments
//     | localparam parameter_type list_of_param_assignments
//   parameter_type ::= integer | real | realtime | time
// A range follows only `localparam [ signed ]`; after a parameter_type the
// list_of_param_assignments comes at once.
//
// `localparam real [3:0] R` puts a range after the type `real`: neither
// alternative derives it. Legal neighbour: b_A_2_1_1_parameter_declarations.v
// (`localparam signed [3:0] LS`) and b_A_2_1_1_real_parameters.v (`localparam real LR`).
//! inherited IEEE 1364-2005 A.2.1.1
//! reject E0208
//! neighbour b_A_2_1_1_parameter_declarations.v
//! neighbour b_A_2_1_1_real_parameters.v
module b_A_2_1_1_typed_parameter_range_rejected;
  localparam real [3:0] R = 1.0;
  initial $display("unreachable");
endmodule
