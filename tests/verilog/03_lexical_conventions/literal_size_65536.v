// IEEE 1364-2005 §4.3.1: "Implementations may set a limit on the maximum
// length of a vector, but the limit shall be at least 65536 (2^16) bits."
// A sized constant (§3.5.1) of that width is legal source, and VerA takes
// sizes up to 2^24 bits (specification/Vague_Decisions.md, E1019 past it).
//
// HAND DERIVATION. 65536'h1 has bit 0 set and the other 65535 bits clear. r
// holds it, so r[0] is 1 and r[65535] is 0.
//! inherited IEEE 1364-2005 4.3.1
//! expect stdout literal_size_65536.expected.txt
module b_3_5_1_literal_size_65536;
  reg [65535:0] r;
  initial begin
    r = 65536'h1;
    $display("low=%b high=%b", r[0], r[65535]);
  end
endmodule
