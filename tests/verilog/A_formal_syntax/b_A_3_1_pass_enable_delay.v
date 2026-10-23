// IEEE 1364-2005 A.3.1, p. 493:
//   gate_instantiation ::= ...
//     | pass_en_switchtype [delay2] pass_enable_switch_instance { , pass_enable_switch_instance } ;
// A.2.2.3, p. 491: delay2 ::= # delay_value | # ( mintypmax_expression [ , mintypmax_expression ] )
// §7.6, p. 85 (quoted for context): "If only one delay is specified, it shall
// specify both the turn-on and the turn-off delays."
//
// tranif1 #(1) (t1, t2, en) and tranif0 #(1, 2) (u1, t2, en): a delay2 of one
// and of two values. t2 = 1 throughout; en rises at t=10, so tranif1 turns on
// by t=11 and tranif0 turns off by t=12: at t=20, t1 = 1 and u1 is z
// (nothing else drives it). Output: "t1=1 u1=z".
//! inherited IEEE 1364-2005 A.3.1
// native-required
`timescale 1ns/1ns
module b_A_3_1_pass_enable_delay;
  reg en;
  wire t1, t2, u1;
  assign t2 = 1'b1;
  tranif1 #(1) (t1, t2, en);
  tranif0 #(1, 2) (u1, t2, en);
  initial begin
    en = 0;
    #10 en = 1;
    #10 $display("t1=%b u1=%b", t1, u1);
    $finish(0);
  end
endmodule
