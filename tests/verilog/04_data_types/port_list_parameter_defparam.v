// IEEE 1364-2005 §4.10.1, p. 36: "The list_of_param_assignments can appear in
// a module as a set of module_items or in the module declaration in the
// module_parameter_port_list (see 12.1). If any param_assignments appear in a
// module_parameter_port_list, then any param_assignments that appear in the
// module become local parameters and shall not be overridden by any method."
// "A parameter can be modified with the defparam statement or in the module
// instance statement."
//
// leaf's P is in its module_parameter_port_list, so it is no local parameter:
// the defparam sets it to 5. Q, in the body, keeps 2.
// Output: "5 2".
//! inherited IEEE 1364-2005 4.10.1
module b_4_10_1_leaf3 #(parameter P = 1) ();
  parameter Q = 2;
  initial $display("%0d %0d", P, Q);
endmodule
module b_4_10_1_port_list_parameter_defparam;
  b_4_10_1_leaf3 u();
  defparam u.P = 5;
endmodule
