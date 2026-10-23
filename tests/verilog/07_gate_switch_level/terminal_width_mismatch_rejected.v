// IEEE 1364-2005 §7.1.6, p. 78: "If bit lengths are different, each instance
// shall get a part-select of the port expression as specified in the range,
// starting with the right-hand index. — Too many or too few bits to connect to
// all the instances shall be considered an error."
//
// g[3:0] is four and gates, each with 1-bit terminals. o and b are 4 bits
// (one per instance), but a is 3 bits: too few for four instances.
// Legal neighbour: two_named_arrays.v (4-bit terminals on [0:3]).
//! inherited IEEE 1364-2005 7.1.6
//! reject E1100
//! reject a gate's input terminal is one bit, or one per instance of an array
//! neighbour two_named_arrays.v
module b_7_1_6_terminal_width_mismatch_rejected;
  reg [2:0] a;
  reg [3:0] b;
  wire [3:0] o;
  and g[3:0] (o, a, b);
  initial $finish(0);
endmodule
