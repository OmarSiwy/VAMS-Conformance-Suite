// IEEE 1364-2005 §17.2.4.3, p. 292, under the v conversion: "strength values
// are really only usefully assigned to nets and $fscanf can only assign
// values to regs". $sscanf is the same reader over a string (p. 291: "Both
// functions read characters, interpret them according to a format, and store
// the results."), and a scan result is stored like a procedural assignment:
// §9.2 (p. 117), "The left-hand side shall be a variable".
//
// w is a net. Legal neighbour: sscanf_conversions.v, whose $sscanf
// stores into reg variables.
//! inherited IEEE 1364-2005 17.2.4.3
//! reject E1100
//! reject there is no procedural assignment to a net
//! neighbour sscanf_conversions.v
module b_17_2_4_3_sscanf_to_net_rejected;
  wire [7:0] w;
  integer code;
  initial code = $sscanf("12", "%d", w);
endmodule
