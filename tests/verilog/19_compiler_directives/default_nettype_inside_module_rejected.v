// IEEE 1364-2005 §19.2, p. 349: "The directive `default_nettype controls the
// net type created for implicit net declarations (see 4.5). It can be used
// only outside of module definitions."
//
// The `default_nettype below is inside the module definition. Legal
// neighbour: none_all_declared.v gives all three of its directives
// outside module definitions.
//! inherited IEEE 1364-2005 19.2
//! reject E0202
//! reject default_nettype
//! neighbour none_all_declared.v
module b_19_2_inside_module_rejected;
`default_nettype wire
  initial $display("accepted");
endmodule
