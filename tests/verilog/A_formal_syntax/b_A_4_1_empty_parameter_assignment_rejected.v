// IEEE 1364-2005 A.4.1 requires a list_of_parameter_assignments inside #(...).
// Its ordered and named alternatives are both nonempty. The runtime neighbour
// 12_hierarchy/parameter_assignment_forms.v exercises omitted lists,
// ordered lists and named empty values, which each have a legal derivation.
//! inherited IEEE 1364-2005 A.4.1
//! reject E0246
module empty_parameter_assignment_leaf;
  parameter P=7;
endmodule
module b_A_4_1_empty_parameter_assignment;
  empty_parameter_assignment_leaf #() child();
  initial $display("invalid override was accepted: %0d",child.P);
endmodule
