// IEEE 1364-2005 §4.8, p. 33: "The time variables shall behave the same
// as a reg of at least 64 bits, with the least significant bit being bit 0.
// They shall be unsigned quantities, and unsigned arithmetic shall be
// performed on them. In contrast, integer variables shall be treated as
// signed regs with the least significant bit being zero. Arithmetic
// operations performed on integer variables shall produce twos-complement
// results. Bit-selects and part-selects of vector regs, integer variables,
// and time variables shall be allowed (see 5.2)." ... "Real variables shall
// default to an initial value of zero. The realtime declarations shall be
// treated synonymously with real declarations and can be used
// interchangeably."
//
// integer i = -6: signed, twos complement: i / 4 -> -1 (truncation toward
//   zero, §5.1.5); i[0] -> 0 (LSB is bit 0: -6 = ...1010); i[3:0] -> 1010
// time t = 5: t[0] -> 1 (LSB is bit 0); t[2:0] -> 101; t[63] exists
//   (at least 64 bits) -> 0; unsigned: t - 6 is 2**64-1 or larger, so
//   t - 6 > 0 -> 1 (a signed result would be -1 > 0 -> 0)
// real re, realtime rt, never assigned -> 0.000000 each; rt = 1.25 and
//   re = rt interchangeably -> 1.250000
//! inherited IEEE 1364-2005 4.8
module b_4_8_integer_time_real;
  integer i;
  time t;
  real re;
  realtime rt;
  initial begin
    $display("%f %f", re, rt);
    i = -6;
    t = 5;
    $display("%0d %b %b", i / 4, i[0], i[3:0]);
    $display("%b %b %b %b", t[0], t[2:0], t[63], t - 6 > 0);
    rt = 1.25;
    re = rt;
    $display("%f", re);
    $finish(0);
  end
endmodule
