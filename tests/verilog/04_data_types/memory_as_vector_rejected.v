// IEEE 1364-2005 §4.9.3.1.3, p. 35: "A memory of n 1-bit regs is different
// from an n-bit vector reg." §4.9.3, p. 35: "An n-bit reg can be assigned a
// value in a single assignment, but a complete memory cannot."
//
// mema [1:4] is assigned 4'b1010 as though it were reg [1:4]. Legal
// neighbour: vector_and_memory.v (the same value into
// reg [1:4] rega, and into mema word by word).
//! inherited IEEE 1364-2005 4.9.3 4.9.3.1.3
//! reject E1100
//! reject requires an element index
//! neighbour vector_and_memory.v
module b_4_9_3_1_3_memory_as_vector_rejected;
  reg mema [1:4];
  initial mema = 4'b1010;
endmodule
