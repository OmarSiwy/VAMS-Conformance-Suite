// IEEE 1364-2005 §9.7.3: An event-array trigger must select one index per dimension.
// Legal neighbor: event_arrays.v triggers/waits on selected elements.
//! inherited IEEE 1364-2005 9.7.3
//! reject E1100
//! reject one index per dimension
//! neighbour event_arrays.v
module event_array_rank_rejected;
  event e[0:1][2:3]; initial -> e[0];
endmodule
