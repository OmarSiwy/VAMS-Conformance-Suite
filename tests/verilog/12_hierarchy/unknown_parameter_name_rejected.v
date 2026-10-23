// IEEE 1364-2005 §12.2.2.2, p. 171: "Parameter assignment by name consists of
// explicitly linking the parameter name and its new value. The name of the
// parameter shall be the name specified in the instantiated module."
//
// vdff has no parameter named width. Legal neighbour:
// parameter_assignment_forms.v (.size and .delay).
//! lrm 6.3.3
//! lrm 6.3.3:1
//! inherited IEEE 1364-2005 12.2.2.2
//! reject E1100
//! reject no such parameter
//! neighbour parameter_assignment_forms.v
module vdff;
  parameter size=5, delay=1;
  initial $display("%0d %0d", size, delay);
endmodule
module b_12_2_2_2_unknown_parameter_name_rejected;
  vdff #(.width(10)) mod_a();
endmodule
