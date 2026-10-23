// IEEE 1364-2005 §12.2.2, p. 170: "The two types of module instance parameter
// value assignment shall not be mixed; parameter assignments to a particular
// module instance shall be entirely by order or entirely by name." §12.2.2.2,
// pp. 172-173: "It shall be illegal to instantiate any module using a mixture of
// parameter redefinitions by order and by name as shown in the instantiation
// of mod_a below: ... vdff #(10, .delay(15)) mod_a".
//
// Legal neighbour: parameter_assignment_forms.v (#(10,15) and
// #(.size(10),.delay(15)) on separate instances).
// The shared parser now reports E0246 for this A.4.1 violation before the
// digital engine's former E1100 check; the required refusal is unchanged.
//! inherited IEEE 1364-2005 12.2.2 12.2.2.2
//! reject E0246
//! reject mixes ordered and named parameter assignments
//! neighbour parameter_assignment_forms.v
module vdff;
  parameter size=5, delay=1;
  initial $display("%0d %0d", size, delay);
endmodule
module b_12_2_2_mixed_order_and_name_rejected;
  vdff #(10, .delay(15)) mod_a();
endmodule
