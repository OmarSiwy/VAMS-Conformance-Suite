// IEEE 1364-2005 A.2.2.1, p. 490:
//   net_type ::= supply0 | supply1 | tri | triand | trior | tri0 | tri1
//     | uwire | wire | wand | wor
//   output_variable_type ::= integer | time
//   real_type ::= real_identifier { dimension } | real_identifier = constant_expression
//   variable_type ::= variable_identifier { dimension } | variable_identifier = constant_expression
//
// One net of each of the eleven net_types. The two-driver nets take a 1 and
// a 0 (continuous assignments of equal strength), resolved per §7.10.4's wired
// logic: wand/triand -> 0, wor/trior -> 1. tri0/tri1 are undriven -> 0/1
// (§7.13.1). supply0/supply1 -> 0/1. tri, uwire, wire have one driver each,
// driving 1, 0, 1.
// Variables: v is a variable_type with an initializer (= 4'd3); m is a
// variable_type with a dimension (m[0:1]); ra = 0.25 is a real_type with an
// initializer and rm a real_type with a dimension (rm[0:1], rm[1] = 1.5).
// b_A_2_2_1_ovt's ports are the two output_variable_types (integer 5, time 6).
// In $display order s0 s1 wa ta wo to z0 z1 tr uw w, then the variables:
// "0 1 0 0 1 1 0 1 1 0 1 v=3 m1=7 ra=0.25 rm1=1.50 oi=5 ot=6".
//! inherited IEEE 1364-2005 A.2.2.1
// native-required
`timescale 1ns/1ns
module b_A_2_2_1_ovt (oi, ot);
  output integer oi;
  output time ot;
  initial begin
    oi = 5;
    ot = 6;
  end
endmodule
module b_A_2_2_1_net_and_variable_types;
  supply0 s0;
  supply1 s1;
  wand wa;
  triand ta;
  wor wo;
  trior to;
  tri0 z0;
  tri1 z1;
  tri tr;
  uwire uw;
  wire w;
  assign wa = 1'b1, wa = 1'b0;
  assign ta = 1'b1, ta = 1'b0;
  assign wo = 1'b1, wo = 1'b0;
  assign to = 1'b1, to = 1'b0;
  assign tr = 1'b1;
  assign uw = 1'b0;
  assign w = 1'b1;
  reg [3:0] v = 4'd3, m [0:1];
  real ra = 0.25, rm [0:1];
  wire [31:0] oi;
  wire [63:0] ot;
  b_A_2_2_1_ovt o (oi, ot);
  initial begin
    m[1] = 4'd7;
    rm[1] = 1.5;
    #1 $display("%b %b %b %b %b %b %b %b %b %b %b v=%0d m1=%0d ra=%.2f rm1=%.2f oi=%0d ot=%0d",
                s0, s1, wa, ta, wo, to, z0, z1, tr, uw, w, v, m[1], ra, rm[1], oi, ot);
    $finish(0);
  end
endmodule
