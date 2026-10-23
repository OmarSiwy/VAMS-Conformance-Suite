// IEEE 1364-2005 §12.2.2.1, p. 170: "The order of the assignments in the module
// instance parameter value assignment by ordered list shall follow the order
// of declaration of the parameters within the module." p. 171: "Local
// parameters cannot be overridden; therefore, they are not considered part of
// the ordered list for parameter value assignment."
//
// my_mem's ordered list is (addr_width, data_width): two entries, the
// localparam mem_size not among them. #(12, 16, 8) supplies a third value that
// no parameter follows. Legal neighbour: parameter_assignment_forms.v
// (my_mem #(12, 16)).
//! inherited IEEE 1364-2005 12.2.2.1
//! reject E1100
//! reject more parameter values than the module has parameters
//! neighbour parameter_assignment_forms.v
module my_mem;
  parameter addr_width = 16;
  localparam mem_size = 1 << addr_width;
  parameter data_width = 8;
  initial $display("%0d %0d %0d", addr_width, mem_size, data_width);
endmodule
module b_12_2_2_1_extra_ordered_value_rejected;
  my_mem #(12, 16, 8) m();
endmodule
