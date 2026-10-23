// IEEE 1364-2005 §17.1.1.5, p. 283: "The %v format specification is used to
// display the strength of scalar nets. For each %v specification that
// appears in a string, a corresponding scalar reference shall follow the
// string in the argument list."
//
// v is a 4-bit vector net, so the argument that follows %v is not a scalar
// reference. Legal neighbour: strength_format.v, which gives %v
// only scalar nets.
//! inherited IEEE 1364-2005 17.1.1.5
//! reject E1100
//! reject scalar
//! neighbour strength_format.v
module b_17_1_1_5_strength_vector_rejected;
  wire [3:0] v;
  assign v = 4'b1010;
  initial $display("%v", v);
endmodule
