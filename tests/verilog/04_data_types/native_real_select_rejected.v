// IEEE 1364-2005 §4.8.1 prohibits packed bit/part selects of real values.
// Supplying the array dimension is legal (native_real_arrays.v); the
// additional index below illegally tries to select a bit of that real.
//! inherited IEEE 1364-2005 4.8.1
//! reject E1100
//! reject a real has no bits to select
//! neighbour native_real_arrays.v
module native_real_select_rejected;
  real a[0:1];
  initial $display("%b", a[0][1]);
endmodule
