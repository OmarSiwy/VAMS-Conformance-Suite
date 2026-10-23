// IEEE 1364-2005 §19.8, p. 358: "The integers in these arguments specify an
// order of magnitude for the size of the value; the valid integers are 1, 10,
// and 100. The character strings represent units of measurement; the valid
// character strings are s, ms, us, ns, ps, and fs."
//
// 5 is not a valid integer. Legal neighbour: units_and_precision.v
// uses 1 and 10.
//! inherited IEEE 1364-2005 19.8
//! reject E0142
//! reject malformed `timescale
//! neighbour units_and_precision.v
`timescale 5 ns / 1 ns
module b_19_8_magnitude_rejected;
  initial $display("accepted");
endmodule
