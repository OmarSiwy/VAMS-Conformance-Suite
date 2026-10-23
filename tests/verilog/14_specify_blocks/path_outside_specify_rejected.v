// IEEE 1364-2005 §14.2, p. 212: "A module path shall be defined inside a
// specify block as a connection between a source signal and a destination
// signal."
//
// The path (a => q) = 1 is written as a module item, outside any specify
// block; A.1.4 has no module_item that begins a path. Legal neighbour:
// module_paths.v, whose paths sit inside specify ... endspecify.
//! inherited IEEE 1364-2005 14.2
//! reject E0240
//! reject not a module item
//! neighbour module_paths.v
`timescale 1ns/1ns
module b_14_2_path_outside_specify_rejected(a, q);
  input a;
  output q;
  assign q = a;
  (a => q) = 1;
endmodule
