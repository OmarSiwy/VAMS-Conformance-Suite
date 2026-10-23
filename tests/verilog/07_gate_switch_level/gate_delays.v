// IEEE 1364-2005 §7.1.3, p. 77: "An optional delay specification shall
// specify the propagation delay through the gates and switches in a
// declaration. Gates and switches in declarations with no delay
// specification shall have no propagation delay. A delay specification can
// contain up to three delay values, depending on the gate type."
// §7.14, p. 101: "When one delay value is given, then this value shall be used
// for all propagation delays associated with the gate or the net. When two
// delays are given, the first delay shall specify the rise delay, and the
// second delay shall specify the fall delay." ... "The third delay refers to
// the transition to the high-impedance value." (Table 7-9.)
//
// o0 = and(a, b) with no delay; o1 = and #(10); o2 = and #(10,12) (§7.14
// Example 1); o3 = bufif1 #(10,12,14) (data a, control b).
//   t=0: a=0, b=1; every output settles to 0 by t=12.
//   t=50: a rises -> o0 at 50 (no delay), o1 and o2 at 60 (rise 10),
//     o3 at 60 (rise 10).
//   t=100: a falls -> o0 at 100, o1 at 110 (the one delay), o2 and o3 at 112
//     (fall 12).
//   t=150: b falls -> o0 0 already; bufif1 turns off: o3 goes to z at 164
//     (turn-off 14). o1 and o2 stay 0.
// Samples (o0 o1 o2 o3), each one unit away from any scheduled edge:
//   51 -> 1000; 59 -> 1000; 61 -> 1111; 101 -> 0111; 109 -> 0111;
//   111 -> 0011; 113 -> 0000; 163 -> 0000; 165 -> 000z.
//! inherited IEEE 1364-2005 7.1.3 7.14
`timescale 1ns/1ns
module b_7_1_3_gate_delays;
  reg a, b;
  wire o0, o1, o2, o3;
  and a0 (o0, a, b);
  and #(10) a1 (o1, a, b);
  and #(10,12) a2 (o2, a, b);
  bufif1 #(10,12,14) a3 (o3, a, b);
  initial begin
    a = 0; b = 1;
    #50 a = 1;
    #1 $display("51 %b%b%b%b", o0, o1, o2, o3);
    #8 $display("59 %b%b%b%b", o0, o1, o2, o3);
    #2 $display("61 %b%b%b%b", o0, o1, o2, o3);
    #39 a = 0;
    #1 $display("101 %b%b%b%b", o0, o1, o2, o3);
    #8 $display("109 %b%b%b%b", o0, o1, o2, o3);
    #2 $display("111 %b%b%b%b", o0, o1, o2, o3);
    #2 $display("113 %b%b%b%b", o0, o1, o2, o3);
    #37 b = 0;
    #13 $display("163 %b%b%b%b", o0, o1, o2, o3);
    #2 $display("165 %b%b%b%b", o0, o1, o2, o3);
    $finish(0);
  end
endmodule
