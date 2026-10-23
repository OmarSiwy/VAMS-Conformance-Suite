// IEEE 1364-2005 §19.6, p. 356: "It shall be illegal for the `resetall
// directive to be specified within a module or UDP declaration."
//
// The `resetall below sits between `module` and `endmodule`. Legal
// neighbour: resetall_restores_defaults.v places its `resetall
// between two module declarations.
//! inherited IEEE 1364-2005 19.6
//! reject E0236
//! reject `resetall inside a module
//! neighbour resetall_restores_defaults.v
module b_19_6_resetall_in_module_rejected;
`resetall
  initial $display("accepted");
endmodule
