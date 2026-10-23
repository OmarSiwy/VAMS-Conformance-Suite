// IEEE 1364-2005 §9.7.3: An event holds no data and cannot be read as an integer.
// Legal neighbor: event_arrays.v triggers/waits on selected elements.
//! inherited IEEE 1364-2005 9.7.3
//! reject E1100
//! reject holds no data; it can only be triggered and waited on
//! neighbour event_arrays.v
module event_array_value_rejected;
  event e[0:1]; integer n; initial n = e[0];
endmodule
