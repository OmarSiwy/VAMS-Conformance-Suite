// IEEE 1364-2005 §4.3.2, p. 24: "Vectored and scalared shall be optional
// advisory keywords to be used in vector net or reg declaration. If these
// keywords are implemented, certain operations on vectors may be restricted.
// If the keyword vectored is used, bit-selects and part-selects and strength
// specifications may not be permitted, and the PLI may consider the object
// unexpanded. If the keyword scalared is used, bit-selects and part-selects
// of the object shall be permitted, and the PLI shall consider the object
// expanded."
//
// The clause's two declarations (p. 25), neither driven:
//   tri1 scalared [63:0] bus64: an undriven tri1 is 1 (§4.6.4), and a
//     scalared net must allow selects: bus64[5] -> 1, bus64[63:62] -> 11
//   tri vectored [31:0] data: legal to declare; read whole (no select, which
//     vectored may forbid): undriven tri -> zzzzzzzz (%h)
//! inherited IEEE 1364-2005 4.3.2
module b_4_3_2_scalared_vectored;
  tri1 scalared [63:0] bus64;
  tri vectored [31:0] data;
  initial #1 begin
    $display("%b %b %h", bus64[5], bus64[63:62], data);
    $finish(0);
  end
endmodule
