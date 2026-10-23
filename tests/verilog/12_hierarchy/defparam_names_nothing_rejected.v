//! inherited IEEE 1364-2005 12.2.1
//! reject E0901
// `defparam foo = 3;` names no item of this design; a defparam's hierarchical
// name must resolve to a parameter (pr498b).
module test;
  parameter foo = 10;
endmodule

module triage_defparam_names_nothing_rejected;
  test tt();
  defparam foo = 3;
endmodule
