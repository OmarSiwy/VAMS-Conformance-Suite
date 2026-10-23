// IEEE 1364-2005 §12.2.2.2, p. 171: "Once a parameter is assigned a value,
// there shall not be another assignment to this parameter name."
//
// size is assigned twice in one parameter value assignment. Legal neighbour:
// parameter_assignment_forms.v (#(.size(10),.delay(15))).
//! lrm 6.3.3
//! lrm 6.3.3:3
//! inherited IEEE 1364-2005 12.2.2.2
//! reject E1100
//! reject assigned twice
//! neighbour parameter_assignment_forms.v
module vdff;
  parameter size=5, delay=1;
  initial $display("%0d %0d", size, delay);
endmodule
module b_12_2_2_2_parameter_assigned_twice_rejected;
  vdff #(.size(10), .size(12)) mod_a();
endmodule
