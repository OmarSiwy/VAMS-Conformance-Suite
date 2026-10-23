//! inherited IEEE 1364-2005 12.2.1
//! reject E0907
// A defparam names an existing parameter by hierarchical name; i_a.Z names
// none (parameter_override_invalid2).
module inner #(parameter A = 1) ();
endmodule

module triage_defparam_names_no_parameter_rejected;
  inner #(.A(10)) i_a();
  defparam i_a.Z = 10;
endmodule
