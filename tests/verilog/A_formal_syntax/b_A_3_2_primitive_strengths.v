// IEEE 1364-2005 A.3.2, p. 494:
//   pulldown_strength ::= ( strength0 , strength1 ) | ( strength1 , strength0 ) | ( strength0 )
//   pullup_strength ::= ( strength0 , strength1 ) | ( strength1 , strength0 ) | ( strength1 )
//
// Each of the six forms drives its net against a continuous assignment of
// the opposite value, so the printed value says which strength won (§7.10.1,
// p. 88: "the stronger signal shall dominate all the weaker drivers"). §7.8,
// p. 86: "A pullup source shall place a logic value 1 on the nets connected
// in its terminal list. A pulldown source shall place a logic value 0 ...
// If there is a strength1 specification on a pullup source or a strength0
// specification on a pulldown source, the signals shall have the strength
// specified. A strength0 specification on a pullup source and a strength1
// specification on a pulldown source shall be ignored."
//   p1 pulldown (weak0, weak1): weak0    vs assign (pull0, pull1) 1:   pull1 wins    -> 1
//   p2 pulldown (supply1, supply0): supply0 vs (strong0, strong1) 1: supply0 wins  -> 0
//   p3 pulldown (strong0): strong0      vs assign (weak0, weak1) 1:   strong0 wins  -> 0
//   p4 pullup (pull0, pull1): pull1     vs (strong0, strong1) 0:      strong0 wins  -> 0
//   p5 pullup (supply1, weak0): supply1 vs (strong0, strong1) 0:      supply1 wins  -> 1
//   p6 pullup (weak1): weak1            vs assign (pull0, pull1) 0:   pull0 wins    -> 0
// Output: "100010".
//! inherited IEEE 1364-2005 A.3.2
`timescale 1ns/1ns
module b_A_3_2_primitive_strengths;
  wire p1, p2, p3, p4, p5, p6;
  pulldown (weak0, weak1) (p1);
  pulldown (supply1, supply0) (p2);
  pulldown (strong0) (p3);
  pullup (pull0, pull1) (p4);
  pullup (supply1, weak0) (p5);
  pullup (weak1) (p6);
  assign (pull0, pull1) p1 = 1'b1;
  assign (strong0, strong1) p2 = 1'b1;
  assign (weak0, weak1) p3 = 1'b1;
  assign (strong0, strong1) p4 = 1'b0;
  assign (strong0, strong1) p5 = 1'b0;
  assign (pull0, pull1) p6 = 1'b0;
  initial #1 begin
    $display("%b%b%b%b%b%b", p1, p2, p3, p4, p5, p6);
    $finish(0);
  end
endmodule
