// IEEE 1364-2005 §14.2.1, p. 213: "The module path destination shall have
// only one driver inside the module." §14.5: "Module path output nets
// shall not have more than one driver within the module. Therefore, wired
// logic is not allowed at module path outputs."
//
// q is a wor net with two continuous assignments inside the module, and the
// path (a => q) ends at it. Legal neighbour: module_paths.v, where
// every destination has one driver.
//! inherited IEEE 1364-2005 14.2.1 14.5
//! reject one driver
//! neighbour module_paths.v
`timescale 1ns/1ns
module b_14_2_1_destination_two_drivers_rejected(a, b, q);
  input a, b;
  output q;
  wor q;
  assign q = a;
  assign q = b;
  specify
    (a => q) = 1;
  endspecify
endmodule
