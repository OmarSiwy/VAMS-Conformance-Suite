//! inherited IEEE 1364-2005 4.2 A.2.1.3
//! reject expected an identifier: found `real`
// A net declaration takes no data type, so `wire real` is not 1364-2005
// (ca_time_real).
module triage_wire_real_rejected;
  wire real r;
  initial r = 0.0;
endmodule
