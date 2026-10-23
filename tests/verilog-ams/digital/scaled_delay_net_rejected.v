// AMS §2.6.2 forbids a scale factor in a digital delay. All three members of
// a min:typ:max expression are source expressions: choosing typ must not
// conceal a forbidden scale factor in min. The legal net #0.25 neighbour
// runs and brackets its update in digital_delay_primitive_notation.v.
//! lrm 2.6.2
//! lrm 2.6.2:3
//! reject E0247
//! neighbour digital_delay_primitive_notation.v
module scaled_delay_net_rejected;
  wire #(1u:2:3) q;
endmodule
