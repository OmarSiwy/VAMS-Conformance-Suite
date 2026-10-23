// IEEE 1364-2005 A.3.1, p. 493-494:
//   gate_instantiation ::=
//       cmos_switchtype [delay3] cmos_switch_instance { , cmos_switch_instance } ;
//     | enable_gatetype [drive_strength] [delay3] enable_gate_instance { , enable_gate_instance } ;
//     | mos_switchtype [delay3] mos_switch_instance { , mos_switch_instance } ;
//     | n_input_gatetype [drive_strength] [delay2] n_input_gate_instance { , n_input_gate_instance } ;
//     | n_output_gatetype [drive_strength] [delay2] n_output_gate_instance { , n_output_gate_instance } ;
//     | pass_en_switchtype [delay2] pass_enable_switch_instance { , pass_enable_switch_instance } ;
//     | pass_switchtype pass_switch_instance { , pass_switch_instance } ;
//     | pulldown [pulldown_strength] pull_gate_instance { , pull_gate_instance } ;
//     | pullup [pullup_strength] pull_gate_instance { , pull_gate_instance } ;
//   cmos_switch_instance ::= [ name_of_gate_instance ] ( output_terminal , input_terminal ,
//     ncontrol_terminal , pcontrol_terminal )
//   enable_gate_instance ::= [ name_of_gate_instance ] ( output_terminal , input_terminal , enable_terminal )
//   mos_switch_instance ::= [ name_of_gate_instance ] ( output_terminal , input_terminal , enable_terminal )
//   n_input_gate_instance ::= [ name_of_gate_instance ] ( output_terminal , input_terminal { , input_terminal } )
//   n_output_gate_instance ::= [ name_of_gate_instance ] ( output_terminal { , output_terminal } , input_terminal )
//   pass_switch_instance ::= [ name_of_gate_instance ] ( inout_terminal , inout_terminal )
//   pass_enable_switch_instance ::= [ name_of_gate_instance ] ( inout_terminal , inout_terminal , enable_terminal )
//   pull_gate_instance ::= [ name_of_gate_instance ] ( output_terminal )
//   name_of_gate_instance ::= gate_instance_identifier [ range ]
//
// All nine alternatives (pass_en_switchtype without its delay2:
// b_A_3_1_pass_enable_delay.v), with a = 1, b = 0, en = 1, nc = 1, pc = 0,
// read at t=5 after every delay has elapsed:
//   cmos #(1) (y_cmos, a, nc, pc): n on, p on -> passes a         -> 1
//   bufif1 (strong0, strong1) #(1, 1, 1) (y_bufif, a, en): en = 1 -> 1
//   nmos (y_nmos, a, en): en = 1 passes a                          -> 1
//   and (strong0, strong1) #(1, 2) g1 (y_and, a, b), g2 (y2, a, a): two
//     instances in one statement: a & b = 0, a & a = 1             -> 0, 1
//   buf (o1, o2, a): two outputs, one input                        -> 1, 1
//   and ga [1:0] (ya, {a, b}, 2'b11): an instance array; ga[1] takes the
//     msbs (ya[1], a, 1), ga[0] the lsbs (ya[0], b, 1) (§7.1.6, p. 78)    -> 10
//   tranif1 (t1, t2, en), t2 = a: en = 1 joins t1 to t2           -> 1
//   tran (s1, s2), s2 = b                                          -> 0
//   pulldown (strong0) (pd), pullup (strong1) (pu)                 -> 0, 1
// Output: "1 1 1 0 1 1 1 10 1 0 0 1".
//! inherited IEEE 1364-2005 A.3.1
// native-required
`timescale 1ns/1ns
module b_A_3_1_gate_instantiations;
  reg a, b, en, nc, pc;
  wire y_cmos, y_bufif, y_nmos, y_and, y2, o1, o2, t1, t2, s1, s2, pd, pu;
  wire [1:0] ya;
  cmos #(1) c1 (y_cmos, a, nc, pc);
  bufif1 (strong0, strong1) #(1, 1, 1) bi (y_bufif, a, en);
  nmos n1 (y_nmos, a, en);
  and (strong0, strong1) #(1, 2) g1 (y_and, a, b), g2 (y2, a, a);
  buf (o1, o2, a);
  and ga [1:0] (ya, {a, b}, 2'b11);
  tranif1 tf (t1, t2, en);
  tran (s1, s2);
  pulldown (strong0) (pd);
  pullup (strong1) (pu);
  assign t2 = a;
  assign s2 = b;
  initial begin
    a = 1; b = 0; en = 1; nc = 1; pc = 0;
    #5 $display("%b %b %b %b %b %b %b %b %b %b %b %b",
                y_cmos, y_bufif, y_nmos, y_and, y2, o1, o2, ya, t1, s1, pd, pu);
    $finish(0);
  end
endmodule
