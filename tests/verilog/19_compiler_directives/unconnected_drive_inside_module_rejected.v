// IEEE 1364-2005 §19.9, p. 360: "These directives shall be specified in pairs
// outside of the module declarations."
//
// The `unconnected_drive below is inside the module declaration. Legal
// neighbour: unconnected_drive.v, whose directives all sit between
// module declarations.
//! inherited IEEE 1364-2005 19.9
//! reject E0202
//! reject unconnected_drive
//! neighbour unconnected_drive.v
module b_19_9_inside_module_rejected(input i);
`unconnected_drive pull1
  initial $display("accepted");
`nounconnected_drive
endmodule
