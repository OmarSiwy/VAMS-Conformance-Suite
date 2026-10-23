// IEEE 1364-2005 §19.11, p. 361: "The `begin_keywords and `end_keywords
// directives can only be specified outside of a design element (module,
// primitive, or configuration)."
//
// Both directives below are inside the module. Legal neighbour:
// keyword_versions.v places every one between modules.
//! inherited IEEE 1364-2005 19.11
//! reject E0202
//! reject directive is only legal outside a design element
//! neighbour keyword_versions.v
module b_19_11_inside_module_rejected;
`begin_keywords "1364-2001"
  initial $display("accepted");
`end_keywords
endmodule
