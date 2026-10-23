// IEEE 1364-2005 §4.8.1 prohibits posedge/negedge applied to a real.
// a[0] is a valid whole real array element; only the edge descriptor is
// invalid. native_real_events.v exercises the legal value-change event.
//! inherited IEEE 1364-2005 4.8.1
//! reject E1100
//! reject posedge and negedge do not apply to a real variable
module native_real_edge_rejected;
  real a[0:1];
  initial @(posedge a[0]) $finish(0);
endmodule
