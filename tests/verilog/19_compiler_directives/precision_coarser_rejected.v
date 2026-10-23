// IEEE 1364-2005 §19.8, p. 358: "The time_precision argument shall be at
// least as precise as the time_unit argument; it cannot specify a longer
// unit of time than time_unit."
//
// 10 ns is a longer unit than 1 ns. Legal neighbour:
// units_and_precision.v (1 ns / 1 ps and 10 ns / 1 ns).
//! inherited IEEE 1364-2005 19.8
//! reject E0142
//! reject the time precision is coarser than the time unit
//! neighbour units_and_precision.v
`timescale 1 ns / 10 ns
module b_19_8_precision_coarser_rejected;
  initial $display("accepted");
endmodule
