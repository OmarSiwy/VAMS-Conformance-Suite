// IEEE1364-2005 17.11.1: operands are interpreted unsigned, including signed
// vectors and integers. Signed -1 in 8 bits is unsigned255 (ceiling log2=8);
// Explicit signed32-bit -1 is unsigned2^32-1 (ceiling32). 8'sh80 is unsigned128
// (exact power, result7). Zero explicitly returns0; one returns0.
// Runtime variables keep these checks distinct from literal constant folding.
// IEEE4.8 permits integer width>=32, so native integer -1 has result>=32,
// not necessarily exactly32. The explicit packed operand fixes its width.
//! lrm 9.14
//! lrm 9.14:1
//! inherited IEEE 1364-2005 17.11.1
module audit_ieee_math_clog2_unsigned;
  reg signed [7:0] octet;
  reg signed [31:0] packed_word;
  integer whole;
  initial begin
    octet = -1;
    whole = -1;
    packed_word = -1;
    $display("unsigned %0d %0d integer-width %0d", $clog2(octet),
             $clog2(packed_word), $clog2(whole) >= 32);
    octet = 8'sh80;
    $display("power %0d zero %0d one %0d", $clog2(octet), $clog2(0), $clog2(1));
    $finish(0);
  end
endmodule
