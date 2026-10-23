// IEEE 1364-2005 A.3.2, p. 494:
//   pullup_strength ::= ( strength0 , strength1 ) | ( strength1 , strength0 ) | ( strength1 )
// A single-strength pullup names a strength1; only pulldown_strength has the
// ( strength0 ) form.
//
// `pullup (weak0) (y);` gives a pullup a lone strength0. Legal neighbour:
// b_A_3_2_primitive_strengths.v (`pullup (weak1) (p6);`,
// `pulldown (strong0) (p3);`).
//! inherited IEEE 1364-2005 A.3.2
//! reject E0207
//! reject a single-strength bracket on this gate is A.3.2
//! neighbour b_A_3_2_primitive_strengths.v
module b_A_3_2_pullup_strength0_only_rejected;
  wire y;
  pullup (weak0) (y);
  initial $display("unreachable");
endmodule
