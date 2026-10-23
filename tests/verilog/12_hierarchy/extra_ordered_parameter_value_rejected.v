//! inherited IEEE 1364-2005 12.2.2.1
//! reject more parameter values than the module has parameters
// An ordered parameter list follows the declaration order; module sub has no
// parameter left to take a value, so #(1, 2, 3) has no meaning (param_test3).
module triage_extra_ordered_parameter_value_rejected;
  wire a;

  sub #(1, 2, 3) u(a);
endmodule

module sub(a);
  input a;
endmodule
