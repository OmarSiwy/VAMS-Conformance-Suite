// IEEE 1364-2005 §4.3.2, p. 24: "Vectored and scalared shall be optional
// advisory keywords to be used in vector net or reg declaration." Syntax 4-1
// (p. 22) admits them only in the alternatives that carry a range:
//   net_type [ vectored | scalared ] [ signed ] range [ delay3 ] ...
//
// `tri scalared w;` puts scalared on a scalar net, with no range. Legal
// neighbour: scalared_vectored.v's `tri1 scalared [63:0] bus64;`.
//! inherited IEEE 1364-2005 4.3.2
//! reject range
//! neighbour scalared_vectored.v
module b_4_3_2_scalared_without_range_rejected;
  tri scalared w;
  initial $display("%b", w);
endmodule
