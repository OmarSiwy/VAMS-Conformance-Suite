// IEEE 1364-2005 §9.7.3: An event holds no data and cannot be an assignment target.
// Legal neighbor: event_arrays.v triggers/waits on selected elements.
//! inherited IEEE 1364-2005 9.7.3
//! reject E1100
//! reject holds no data; it cannot be assigned
//! neighbour event_arrays.v
module event_array_assign_rejected;
  event e[0:1]; initial e[0] = 1;
endmodule
