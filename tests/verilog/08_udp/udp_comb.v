// D08 — combinational UDP: declaration, table execution, `?`, z-as-x, and the
// unmatched-row rule.
//
// Verilog-AMS 2.4 Annex A.5.1:
//     udp_declaration ::= { attribute_instance } primitive udp_identifier
//         ( udp_port_list ) ; udp_port_declaration { udp_port_declaration }
//         udp_body endprimitive
// Annex A.5.2:
//     udp_port_list ::= output_port_identifier , input_port_identifier
//         { , input_port_identifier }
// Annex A.5.3:
//     udp_body ::= combinational_body | sequential_body
//     combinational_body ::= table combinational_entry { combinational_entry }
//         endtable
//     combinational_entry ::= level_input_list : output_symbol ;
//     level_input_list ::= level_symbol { level_symbol }
//     output_symbol ::= 0 | 1 | x | X
//     level_symbol  ::= 0 | 1 | x | X | ? | b | B
// Annex A.5.4:
//     udp_instantiation ::= udp_identifier [ drive_strength ] [ delay2 ]
//         udp_instance { , udp_instance } ;
//     udp_instance ::= [ name_of_udp_instance ]
//         ( output_terminal , input_terminal { , input_terminal } )
// §1.1 makes IEEE Std 1364-2005 clause 8 the normative execution rules.
//
// THE UDP UNDER TEST is a 2:1 multiplexer whose table also states what happens
// when the select is unknown but both data inputs agree. IEEE1364-2005
// §5.1.13/Table5-21 also preserves matching known bits for `sel ? b : a`;
// that expression is not a contrasting x-valued oracle. These observations
// exercise UDP table matching, independently of conditional-expression support.
//
// FOUR RULES, AND THE ROW THAT PINS EACH.
//
// 1. `?` is a LEVEL wildcard covering 0, 1 and x — and only those three; the
//    UDP value set has no z. Row `sel=0 a=1 b=x : 1` matches `0 1 ?` on a b
//    that is x, so a compiler that restricts `?` to the known values 0 and 1
//    falls through to no match and prints x.
//
// 2. A z on a UDP INPUT is converted to x before the table is consulted. Row
//    `sel=0 a=0 b=z : 0` therefore matches `0 0 ?` exactly as the x case does,
//    and row `sel=z a=1 b=1 : 1` matches the `x 1 1` entry — that last row is
//    the strongest form of the rule, because it needs the conversion to happen
//    on a column whose table symbol is the literal `x`, not a wildcard.
//
// 3. When NO entry matches, the output is x. Row `sel=x a=0 b=1` has no entry:
//    the four `0`/`1` select entries need a known select, and the two `x`
//    entries need a and b to agree. Expected x.
//
// 4. A UDP output is never z (A.5.3: output_symbol ::= 0 | 1 | x | X). Rule 3's
//    row is also the assertion for this one: an unmatched combinational UDP
//    must report x, not leave its output net floating at z.
//
// HAND-DERIVED EXPECTED VALUES, one per stimulus row, each naming the table
// entry it selects:
//
//   sel a b | entry matched | out
//   0   1 x | 0 1 ?         | 1
//   0   0 z | 0 0 ?   (z->x)| 0
//   1   x 1 | 1 ? 1         | 1
//   1   z 0 | 1 ? 0   (z->x)| 0
//   x   0 0 | x 0 0         | 0
//   x   1 1 | x 1 1         | 1
//   x   0 1 | none          | x
//   z   1 1 | x 1 1   (z->x)| 1
//   z   0 1 | none    (z->x)| x
//
//! lrm A.5.1
//! lrm A.5.2
//! lrm A.5.3
//! lrm A.5.4
//! lrm 1.1
//! lrm A.5.1:1000
//! lrm A.5.2:1000
//! lrm A.5.3:1000
//! lrm A.5.4:1000
//! inherited IEEE 1364-2005 8.1.4 8.1.5 8.2
`timescale 1ns/1ns

primitive udp_mux (out, sel, a, b);
  output out;
  input  sel, a, b;
  table
  // sel  a  b  :  out
       0  1  ?  :   1  ;
       0  0  ?  :   0  ;
       1  ?  1  :   1  ;
       1  ?  0  :   0  ;
       x  0  0  :   0  ;
       x  1  1  :   1  ;
  endtable
endprimitive

module d08_udp_comb;
  reg  sel, a, b;
  wire out;

  udp_mux u1 (out, sel, a, b);

  initial begin
    sel = 1'b0; a = 1'b1; b = 1'bx; #1
      $display("sel=0 a=1 b=x got out=%b want 1", out);
    sel = 1'b0; a = 1'b0; b = 1'bz; #1
      $display("sel=0 a=0 b=z got out=%b want 0", out);
    sel = 1'b1; a = 1'bx; b = 1'b1; #1
      $display("sel=1 a=x b=1 got out=%b want 1", out);
    sel = 1'b1; a = 1'bz; b = 1'b0; #1
      $display("sel=1 a=z b=0 got out=%b want 0", out);
    sel = 1'bx; a = 1'b0; b = 1'b0; #1
      $display("sel=x a=0 b=0 got out=%b want 0", out);
    sel = 1'bx; a = 1'b1; b = 1'b1; #1
      $display("sel=x a=1 b=1 got out=%b want 1", out);
    sel = 1'bx; a = 1'b0; b = 1'b1; #1
      $display("sel=x a=0 b=1 got out=%b want x", out);
    sel = 1'bz; a = 1'b1; b = 1'b1; #1
      $display("sel=z a=1 b=1 got out=%b want 1", out);
    sel = 1'bz; a = 1'b0; b = 1'b1; #1
      $display("sel=z a=0 b=1 got out=%b want x", out);
  end
endmodule
