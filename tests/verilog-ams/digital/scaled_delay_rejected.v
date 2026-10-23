// AMS §2.6.2: "Scale factors are not allowed to be used in defining digital
// delays (e.g., #5u)." This is that example, independent of the runtime's
// tick rounding. Legal neighbour: digital_delay_notation.v uses #5e3 in
// 1ns units to wait five microseconds and asserts the elapsed time.
//! lrm 2.6.2
//! lrm 2.6.2:3
//! reject E0247
//! neighbour digital_delay_notation.v
`timescale 1ns/1ps
module scaled_delay_rejected;
  initial #5u $display("invalid delay ran");
endmodule
