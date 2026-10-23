// IEEE 1364-2005 §12.1.1, p. 165: "Top-level modules are modules that are
// included in the source text, but do not appear in any module instantiation
// statement, as described in 12.1.2." ... "A model shall contain at least one
// top-level module."
//
// a instantiates b and b instantiates a: both appear in an instantiation
// statement, so neither is top-level and the model has none. Legal neighbour:
// module_header_forms.v (one top-level module).
//! inherited IEEE 1364-2005 12.1.1
//! reject E1100
//! reject found no top-level module
//! neighbour module_header_forms.v
module a;
  b u();
endmodule
module b;
  a v();
endmodule
