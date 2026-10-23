// IEEE 1364-2005 §4.10.1, p. 36: "If any param_assignments appear in a
// module_parameter_port_list, then any param_assignments that appear in the
// module become local parameters and shall not be overridden by any method."
// §4.10.2, p. 37, of local parameters: "they cannot directly be modified by
// defparam statements".
//
// leaf has the module_parameter_port_list #(parameter P = 1), so its body
// parameter Q is local; the defparam overrides Q. Legal neighbour:
// port_list_parameter_defparam.v (the same leaf, its port-list
// parameter P overridden by a defparam).
//! inherited IEEE 1364-2005 4.10.1
//! reject E1100
//! reject local parameter
//! neighbour port_list_parameter_defparam.v
module b_4_10_1_leaf2 #(parameter P = 1) ();
  parameter Q = 2;
  initial $display("%0d %0d", P, Q);
endmodule
module b_4_10_1_port_list_body_parameter_override_rejected;
  b_4_10_1_leaf2 u();
  defparam u.Q = 5;
endmodule
