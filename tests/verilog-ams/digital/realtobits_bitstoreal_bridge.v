// Verilog-AMS LRM 2.4 §3.7, the escape hatch sentence, verbatim:
//
//   "They cannot be connected to any other wires, although connection to
//    explicitly declared 64-bit wires can be done via system tasks $realtobits
//    and $bitstoreal."
//
// and §9.11 Conversion System Functions:
//
//   "Verilog AMS HDL extends the conversion functions defined in IEEE Std
//    1364-2005 Verilog HDL so that $bitstoreal and $realtobits can be used in
//    the analog context."
//
// This is the ONLY sanctioned path from a wreal to an ordinary four-state bus,
// and it is a lossless one: the 64 bits are the IEEE-754 encoding of the
// double, so $bitstoreal($realtobits(x)) is x for every finite x, bit for bit.
//
// WHAT IS PINNED, AND WHY THE VALUES ARE THESE. 0.1 is not representable in
// binary, so it is the value that catches any implementation that round-trips
// through a decimal string or a 32-bit float: its double is
// 0x3FB999999999999A, a full 52-bit mantissa of repeating 1001, and the
// printed pattern shows every one of them. -0.25 is exact but NEGATIVE and a
// power of two, so its pattern isolates the two fields the first value does not
// exercise — the sign bit and an all-zero mantissa.
//
// The bit-SELECT assertions are the part a "return a real and hope" shim
// cannot fake: packed[63] is the sign, packed[62:52] is the 11-bit biased
// exponent, and those are properties of the encoding rather than of the value.
//
//! lrm 3.7
//! lrm 9.11
//! timescale 1ns/1ns
//
// HAND DERIVATION — IEEE-754 binary64, sign(1) exponent(11) mantissa(52).
//
//   0.1  = +1.6 x 2^-4.  biased exponent = -4 + 1023 = 1019 = 11'b01111111011
//        mantissa = 0.6 in binary = 1001 1001 1001 ... rounded up at bit 52
//        -> 0x3FB999999999999A
//        -> 0011111110111001100110011001100110011001100110011001100110011010
//        sign bit = 0, exponent field = 01111111011
//
//   -0.25 = -1.0 x 2^-2.  biased exponent = -2 + 1023 = 1021 = 11'b01111111101
//        mantissa = 0
//        -> 0xBFD0000000000000
//        -> 1011111111010000000000000000000000000000000000000000000000000000
//        sign bit = 1, exponent field = 01111111101
//
//   `back` is $bitstoreal of those same 64 bits, so it is the identical double;
//   %g prints "0.1" and "-0.25", and the re-encoding of `back` reproduces the
//   pattern exactly — which is the round-trip claim, stated on all 64 bits
//   rather than on six significant decimal digits.

`timescale 1ns/1ns
module m04_realtobits_bitstoreal_bridge;
  real feed;
  wreal w;
  wire [63:0] packed_bits;
  wreal back;

  assign w = feed;
  assign packed_bits = $realtobits(w);
  assign back = $bitstoreal(packed_bits);

  initial begin
    feed = 0.1;
    #1;
    $display("nonrepresentable_encodes %b", packed_bits);
    $display("sign_bit_is_bit63 %b", packed_bits[63]);
    $display("biased_exponent %b", packed_bits[62:52]);
    $display("round_trip_value %g", back);
    $display("round_trip_is_bit_exact %b", $realtobits(back));

    feed = -0.25;
    #1;
    $display("negative_power_of_two_encodes %b", packed_bits);
    $display("sign_bit_is_bit63 %b", packed_bits[63]);
    $display("biased_exponent %b", packed_bits[62:52]);
    $display("round_trip_value %g", back);
    $display("round_trip_is_bit_exact %b", $realtobits(back));
    $finish(0);
  end
endmodule
