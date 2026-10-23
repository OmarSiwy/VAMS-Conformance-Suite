// IEEE 1364-2005 §4.9: "An element can be assigned a value in a single
// assignment, but complete or partial array dimensions cannot." A continuous
// assignment to the whole net array `w` names no element, so it is refused;
// `assign w[0] = ...` is the legal neighbour (type_net_array.v).
//! inherited IEEE 1364-2005 4.9
//! reject an unpacked array reference requires an element index
//! neighbour type_net_array.v
`timescale 1ns/1ns
module audit_type_net_array_whole_assign_rejected;
  wire [3:0] w [0:1];
  assign w = 4'b0000;
endmodule
