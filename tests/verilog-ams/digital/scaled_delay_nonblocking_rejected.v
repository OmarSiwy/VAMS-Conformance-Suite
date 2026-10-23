// AMS §2.6.2 forbids a scale factor in a digital delay, including an operand
// inside a delay expression. A.6.2's intra-assignment delay is still a delay.
// Legal neighbour: digital_delay_notation.v schedules an NBA with #1.25e-1
// and observes both its delivered value and the time.
//! lrm 2.6.2
//! lrm 2.6.2:3
//! reject E0247
//! neighbour digital_delay_notation.v
module scaled_delay_nonblocking_rejected;
  reg q;
  initial q <= #(2 + 5u) 1;
endmodule
