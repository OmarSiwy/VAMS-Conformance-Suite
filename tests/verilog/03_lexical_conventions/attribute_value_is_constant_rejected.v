//! inherited IEEE 1364-2005 3.8
//! reject-only §3.8: an attribute value must be a constant expression
// An attr_spec value is a constant_expression; N is an integer variable
// (check_constant_4). VerA accepts it on a module item; the fixture is
// expected to FAIL, verifying the vera-bug claim.
module triage_attribute_value_is_constant_rejected;
  integer N;

  (* attr = N *)
  initial $display(N);
endmodule
