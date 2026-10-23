// IEEE 1364-2005 §3.5.1 lets a sized constant give its size in bits and
// bounds nothing about it. VerA refused a size past 2^24 = 16777216 bits
// (E1019) until 2026-10; it now takes any size a 32-bit width holds, and
// memory is the bound. This literal is one bit past the old cap.
// literal_size_65536.v is the §4.3.1 minimum.
//
// HAND DERIVATION. 16777217'h1 has bit 0 set and the other 16777216 bits
// clear: `== 0` is 0 and `== 1` is 1 (§5.1.8, the 32-bit operand extended to
// 16777217 bits). Bit 0 is 1, and shifted down by 16777216 the top bit is
// 0. Every printed value is a 1-bit comparison, so the transcript is short.
//! inherited IEEE 1364-2005 3.5.1
//! expect stdout literal_size_over_2_24.expected.txt
//! neighbour literal_size_65536.v
module b_3_5_1_literal_size_over_2_24;
  initial begin
    $display("is_zero=%0d is_one=%0d", 16777217'h1 == 0, 16777217'h1 == 1);
    $display("bit0=%0d top=%0d", (16777217'h1 & 1) == 1, (16777217'h1 >> 16777216) == 0);
  end
endmodule
