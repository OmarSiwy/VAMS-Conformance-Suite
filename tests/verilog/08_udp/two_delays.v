// IEEE 1364-2005 §8.6, p. 113: "Only two delays may be specified because z
// is not supported for UDPs."
// §7.14, p. 101: "When two delays are given, the first delay shall specify
// the rise delay, and the second delay shall specify the fall delay. The
// delay when the signal changes to high impedance or to unknown shall be the
// lesser of the two delay values." Table 7-9, p. 101: x to 0 uses d2.
//
// inv is an inverter. g1 has #(2,3): rise 2, fall 3; the unnamed instance
// has no delay.
//   t=0  a = 1: g1 output x -> 0 after d2 = 3 (at t=3); w -> 0 now
//        t=1 "x 0"    t=4 "0 0"
//   t=10 a = 0: g1 0 -> 1 after d1 = 2 (at t=12); w -> 1 now
//        t=11 "0 1"   t=13 "1 1"
//   t=20 a = 1: g1 1 -> 0 after d2 = 3 (at t=23); w -> 0 now
//        t=22 "1 0"   t=24 "0 0"
//   t=30 a = x: g1 0 -> x after min(2, 3) = 2 (at t=32); w -> x now
//        t=31 "0 x"   t=33 "x x"
// Every display falls strictly between a change and its delayed update.
//! inherited IEEE 1364-2005 8.6
`timescale 1ns/1ns
primitive inv(q, a);
  output q;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module b_8_6_two_delays;
  reg a;
  wire q, w;
  inv #(2, 3) g1(q, a);
  inv (w, a);
  initial begin
    a = 1;
    #1 $display("%b %b", q, w);
    #3 $display("%b %b", q, w);
    #6 a = 0;
    #1 $display("%b %b", q, w);
    #2 $display("%b %b", q, w);
    #7 a = 1;
    #2 $display("%b %b", q, w);
    #2 $display("%b %b", q, w);
    #6 a = 1'bx;
    #1 $display("%b %b", q, w);
    #2 $display("%b %b", q, w);
    $finish(0);
  end
endmodule
