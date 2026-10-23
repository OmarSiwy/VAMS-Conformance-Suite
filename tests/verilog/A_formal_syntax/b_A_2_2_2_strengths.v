// IEEE 1364-2005 A.2.2.2, p. 490-491:
//   drive_strength ::= ( strength0 , strength1 ) | ( strength1 , strength0 )
//     | ( strength0 , highz1 ) | ( strength1 , highz0 )
//     | ( highz0 , strength1 ) | ( highz1 , strength0 )
//   strength0 ::= supply0 | strong0 | pull0 | weak0
//   strength1 ::= supply1 | strong1 | pull1 | weak1
//   charge_strength ::= ( small ) | ( medium ) | ( large )
//
// All six drive_strength forms and all eight strength keywords, each on a
// net_decl_assignment, and all three charge_strengths on trireg nets. Where a
// second driver is added, strength decides the value (§7.10.1, p. 88: "If
// two or more signals of unequal strength combine in a wired net
// configuration, the stronger signal shall dominate all the weaker drivers
// and determine the result."):
//   a (weak0, weak1) = 1, plus assign (pull0, pull1) a = 0: pull0 wins  -> 0
//   b (strong1, weak0) = 0, plus assign (pull1, pull0) b = 1: pull1 wins -> 1
//   c (supply0, highz1) = 1: a 1 driven at highz is z                   -> z
//   d (strong1, highz0) = 1                                             -> 1
//   e (highz0, weak1) = 0: a 0 driven at highz is z                     -> z
//   f (highz1, supply0) = 0                                             -> 0
//   ts (small), tm (medium), tl (large) driven 1, 0, 1                  -> 1 0 1
// Output: "a=0 b=1 c=z d=1 e=z f=0 ts=1 tm=0 tl=1".
//! inherited IEEE 1364-2005 A.2.2.2
`timescale 1ns/1ns
module b_A_2_2_2_strengths;
  wire (weak0, weak1) a = 1'b1;
  assign (pull0, pull1) a = 1'b0;
  wire (strong1, weak0) b = 1'b0;
  assign (pull1, pull0) b = 1'b1;
  wire (supply0, highz1) c = 1'b1;
  wire (strong1, highz0) d = 1'b1;
  wire (highz0, weak1) e = 1'b0;
  wire (highz1, supply0) f = 1'b0;
  trireg (small) ts;
  trireg (medium) tm;
  trireg (large) tl;
  assign ts = 1'b1;
  assign tm = 1'b0;
  assign tl = 1'b1;
  initial #1 begin
    $display("a=%b b=%b c=%b d=%b e=%b f=%b ts=%b tm=%b tl=%b", a, b, c, d, e, f, ts, tm, tl);
    $finish(0);
  end
endmodule
