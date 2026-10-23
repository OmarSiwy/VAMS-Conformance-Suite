// IEEE 1364-2005 §5.5.4, p. 66: "If a signed operand is to be resized to a
// larger signed width and the value of the sign bit is X, the resulting value
// shall be bit-filled with Xs. If the sign bit of the value is Z, then the
// resulting value shall be bit-filled with Zs. If any bit of a signed value
// is X or Z, then any nonlogical operation involving the value shall result
// in the entire resultant value being an X and the type consistent with the
// expression’s type."
//
// Into reg signed [7:0] e:
//   e = 4'sbx010 -> sign bit x: xxxxx010
//   e = 4'sbz010 -> sign bit z: zzzzz010
// Arithmetic (nonlogical) on a signed value with an x or z bit (§5.1.5 also
// makes these all x, for any operand; only the two lines above isolate
// §5.5.4):
//   e = 4'sb10x1 + 4'sd1 -> xxxxxxxx
//   e = 4'sb1z01 * 4'sd1 -> xxxxxxxx
//! inherited IEEE 1364-2005 5.5.4
module b_5_5_4_signed_unknown_bits;
  reg signed [7:0] e;
  initial begin
    e = 4'sbx010; $write("%b ", e);
    e = 4'sbz010; $display("%b", e);
    e = 4'sb10x1 + 4'sd1; $write("%b ", e);
    e = 4'sb1z01 * 4'sd1; $display("%b", e);
    $finish(0);
  end
endmodule
