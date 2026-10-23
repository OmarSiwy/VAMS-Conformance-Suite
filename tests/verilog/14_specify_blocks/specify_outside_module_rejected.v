// IEEE 1364-2005 §14.1, p. 211: "The specify block shall be bounded by the
// keywords specify and endspecify, and it shall appear inside a module
// declaration."
//
// The specify block below stands at file level, before any module (A.1.2:
// description ::= module_declaration | udp_declaration | config_declaration).
// Legal neighbour: specify_timing_checks_named_by_w0251.v, the same kind of
// block inside a module.
//! inherited IEEE 1364-2005 14.1
//! reject outside a module
//! neighbour specify_timing_checks_named_by_w0251.v
specify
  specparam tpd = 1;
endspecify

module b_14_1_specify_outside_module_rejected;
  initial $display("ran");
endmodule
