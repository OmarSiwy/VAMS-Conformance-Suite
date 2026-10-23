// IEEE 1364-2005 §18.2.3.7, pp. 334-335: "The $var section prints the names
// and identifier codes of the variables being dumped." Syntax 18-15:
//   vcd_declaration_vars ::= $var var_type size identifier_code reference $end
//   var_type ::= event | integer | parameter | real | realtime | reg | supply0
//     | supply1 | time | tri | triand | trior | trireg | tri0 | tri1 | wand
//     | wire | wor
//   reference ::= identifier | identifier [ bit_select_index ]
//     | identifier [ msb_index : lsb_index ]
// "Size specifies how many bits are in the variable." ... "a) The msb index
// indicates the most significant index; the lsb index indicates the least
// significant index." ... "In the $var section, a net of net type uwire shall
// have a variable type of wire."
// §18.2.3.4, p. 333: "The $scope section defines the scope of the variables
// being dumped." (module: "Top-level module and module instances").
// §18.2.3.6, p. 334: "The $upscope section indicates a change of scope to the
// next higher level in the design hierarchy."
// §18.2.3.3, p. 333: "The $enddefinitions section marks the end of the header
// information and definitions."
// §18.2.3.5, p. 334: "The $timescale keyword specifies what timescale was used
// for the simulation." Syntax 18-13: `$timescale time_number time_unit $end`,
// time_number 1 | 10 | 100.
// §18.2.3, p. 332: "The general information in the VCD file is presented as a
// series of sections surrounded by keywords."
//
// HAND DERIVATION (the d09_11 CONVENTION: codes from `!` in $var order, and
// a scope's variables in declaration order, nets before variables; the
// comparison joins the $timescale body, so `100 ps` and `100ps` agree).
// Also pinned, as writer choices §18.2 leaves open: value changes in $var
// order, x/z in lower case, a range as its own token (`up [0:3]`), no empty
// time record:
//   $timescale: the `timescale is 100ps/100ps, so a time step is 100ps and
//     `#1` records as #1: $timescale 100ps $end.
//   $scope module b_18_2_3_7_var_sections: its nets in declaration order,
//     each var_type the net's own type, uwire as wire, size 1:
//     wire ! w, tri " tr, triand # ta, trior $ to, trireg % tg, tri0 & t0,
//     tri1 ' t1, wand ( wa, wor ) wo, supply0 * s0, supply1 + s1, wire , uw;
//     then its variables: reg 1 - a; reg 4 . up [0:3] (msb index 0, lsb 3,
//     as declared); integer 32 / i; time 64 0 t.
//   $scope module u (the instance of b_18_2_3_7_leaf) nested inside it:
//     reg 2 1 q [1:0], then $upscope for u and $upscope for the top.
//   $enddefinitions $end.
//   #0 $dumpvars, values at the end of time 0: w, tr, ta, to, wa, wo, uw
//     have no driver -> z; trireg with no driver ever holds x (§4.2.1, p. 23:
//     "The trireg net shall default to the value x"); tri0 -> 0, tri1 -> 1
//     (pulled); supply0 0, supply1 1;
//     a = 0; up = 4'b0101 -> b101 (0 extends 1, Table 18-1); i = 7 -> b111;
//     t = 0 -> b0; q = 2'b10 -> b10.
//   #1 up = 4'b1100 -> b1100; i = -1 -> 32 ones; q = 2'bx1 -> bx1.
//! inherited IEEE 1364-2005 18.2.3.7 18.2.3 18.2.3.3 18.2.3.4 18.2.3.5 18.2.3.6
//! expect vcd var_sections.vcd == var_sections.expected.vcd
`timescale 100ps/100ps
module b_18_2_3_7_leaf;
  reg [1:0] q;
endmodule

module b_18_2_3_7_var_sections;
  wire w;
  tri tr;
  triand ta;
  trior to;
  trireg tg;
  tri0 t0;
  tri1 t1;
  wand wa;
  wor wo;
  supply0 s0;
  supply1 s1;
  uwire uw;
  reg a;
  reg [0:3] up;
  integer i;
  time t;
  b_18_2_3_7_leaf u();
  initial begin
    $dumpfile("var_sections.vcd");
    $dumpvars(0, b_18_2_3_7_var_sections);
    a = 1'b0;
    up = 4'b0101;
    i = 7;
    t = 0;
    u.q = 2'b10;
    #1 up = 4'b1100;
       i = -1;
       u.q = 2'bx1;
    $finish(0);
  end
endmodule
