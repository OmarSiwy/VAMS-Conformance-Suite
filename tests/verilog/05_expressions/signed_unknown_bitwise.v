// IEEE 1364-2005 §5.5.4, p. 66: "If any bit of a signed value is X or Z, then
// any nonlogical operation involving the value shall result in the entire
// resultant value being an X". "Nonlogical" is not defined; VerA's reading
// (specification/Vague_Decisions.md VD-037) is that arithmetic and resizing go all x
// (signed_unknown_bits.v) while the bitwise operators keep §5.1.10's
// bit tables and an ambiguous `?:` keeps §5.1.13's Table 5-21: signedness
// changes no bit those tables read.
//
// Every operand is 4 bits and the target is `reg signed [3:0]`, so nothing is
// resized and only the operator's own rule acts:
//   4'sb10x1 & 4'sb0000 -> 0 & anything is 0, bit by bit:   0000
//   4'sb10x1 | 4'sb0000 -> b | 0 is b:                       10x1
//   4'sb10x1 ^ 4'sb0000 -> b ^ 0 is b (x ^ 0 is x):          10x1
//   ~4'sb10x1           -> ~0 = 1, ~1 = 0, ~x = x:           01x0
//   1'bx ? 4'sb10x1 : 4'sb10x1 -> Table 5-21 combines equal
//                         bits to themselves, x with x to x: 10x1
// Under the all-x reading every line would print xxxx.
//! inherited IEEE 1364-2005 5.5.4
module b_5_5_4_signed_unknown_bitwise;
  reg signed [3:0] e;
  initial begin
    e = 4'sb10x1 & 4'sb0000; $write("%b ", e);
    e = 4'sb10x1 | 4'sb0000; $write("%b ", e);
    e = 4'sb10x1 ^ 4'sb0000; $write("%b ", e);
    e = ~4'sb10x1; $write("%b ", e);
    e = 1'bx ? 4'sb10x1 : 4'sb10x1; $display("%b", e);
    $finish(0);
  end
endmodule
