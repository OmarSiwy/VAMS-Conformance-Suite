//! inherited IEEE 1364-2005 12.3
//! reject identifier is not a port of this module
// `module test;` has no list of ports, so `output reg a;` names a port the
// module does not have (module_output_port_var2).
module triage_output_port_without_module_port_list_rejected;
  output reg a;

  initial a = 0;
endmodule
