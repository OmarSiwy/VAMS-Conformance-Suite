// IEEE 1364-2005 A.3.4, p. 494:
//   cmos_switchtype ::= cmos | rcmos
//   enable_gatetype ::= bufif0 | bufif1 | notif0 | notif1
//   mos_switchtype ::= nmos | pmos | rnmos | rpmos
//   n_input_gatetype ::= and | nand | or | nor | xor | xnor
//   n_output_gatetype ::= buf | not
//   pass_en_switchtype ::= tranif0 | tranif1 | rtranif1 | rtranif0
//   pass_switchtype ::= tran | rtran
//
// Every one of the 24 keywords instantiated once, each on its own output net,
// with a = 1, b = 0, en = 1, dis = 0 (the switches' outputs are read as logic
// values; §7.11-§7.12's strength reduction does not change a value):
//   cmos (a, en, dis) 1   rcmos (b, en, dis) 0
//   bufif0 (a, dis) 1     bufif1 (a, en) 1     notif0 (a, dis) 0   notif1 (a, en) 0
//   nmos (a, en) 1        pmos (a, dis) 1      rnmos (b, en) 0     rpmos (b, dis) 0
//   and 0  nand 1  or 1  nor 0  xor 1  xnor 0   (each over a, b)
//   buf (a) 1             not (a) 0
//   tranif0 (dis) passes a: 1   tranif1 (en): 1   rtranif1 (en): 1   rtranif0 (dis): 1
//   tran: 1               rtran: 1   (each joins its net to a)
// Output, in that order: "10 1100 1100 011010 10 1111 11".
//! inherited IEEE 1364-2005 A.3.4
// native-required
`timescale 1ns/1ns
module b_A_3_4_gate_and_switch_types;
  reg a, b, en, dis;
  wire c1, c2, e1, e2, e3, e4, m1, m2, m3, m4;
  wire g1, g2, g3, g4, g5, g6, o1, o2, p1, p2, p3, p4, q1, q2;
  wire ta;
  cmos (c1, a, en, dis);
  rcmos (c2, b, en, dis);
  bufif0 (e1, a, dis);
  bufif1 (e2, a, en);
  notif0 (e3, a, dis);
  notif1 (e4, a, en);
  nmos (m1, a, en);
  pmos (m2, a, dis);
  rnmos (m3, b, en);
  rpmos (m4, b, dis);
  and (g1, a, b);
  nand (g2, a, b);
  or (g3, a, b);
  nor (g4, a, b);
  xor (g5, a, b);
  xnor (g6, a, b);
  buf (o1, a);
  not (o2, a);
  assign ta = a;
  tranif0 (p1, ta, dis);
  tranif1 (p2, ta, en);
  rtranif1 (p3, ta, en);
  rtranif0 (p4, ta, dis);
  tran (q1, ta);
  rtran (q2, ta);
  initial begin
    a = 1; b = 0; en = 1; dis = 0;
    #1 $display("%b%b %b%b%b%b %b%b%b%b %b%b%b%b%b%b %b%b %b%b%b%b %b%b",
                c1, c2, e1, e2, e3, e4, m1, m2, m3, m4, g1, g2, g3, g4, g5, g6,
                o1, o2, p1, p2, p3, p4, q1, q2);
    $finish(0);
  end
endmodule
