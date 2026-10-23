// IEEE 1364-2005 A.5.1, p. 496:
//   udp_declaration ::= { attribute_instance } primitive udp_identifier ( udp_port_list ) ;
//       udp_port_declaration { udp_port_declaration } udp_body endprimitive
//     | { attribute_instance } primitive udp_identifier ( udp_declaration_port_list ) ;
//       udp_body endprimitive
// A.5.2, p. 496:
//   udp_port_list ::= output_port_identifier , input_port_identifier { , input_port_identifier }
//   udp_declaration_port_list ::= udp_output_declaration , udp_input_declaration { , udp_input_declaration }
//   udp_port_declaration ::= udp_output_declaration ; | udp_input_declaration ; | udp_reg_declaration ;
//   udp_output_declaration ::= { attribute_instance } output port_identifier
//     | { attribute_instance } output reg port_identifier [ = constant_expression ]
//   udp_input_declaration ::= { attribute_instance } input list_of_port_identifiers
//   udp_reg_declaration ::= { attribute_instance } reg variable_identifier
//
// b_A_5_1_mux: the first form, a udp_port_list of one output and three
// inputs, then udp_port_declarations: an output, an input list of two, an
// input of one. Combinational: y = s ? b : a.
// b_A_5_1_tff: the first form with a udp_reg_declaration `reg q;` and a
// udp_initial_statement q = 0. Sequential: q toggles on each rising t; every
// other transition of t ((?0), t's first step x -> 0 among them) and of the
// unused input keeps q (§8.4, p. 110: "All unspecified transitions default
// to the output value x.").
// b_A_5_1_hold: the second form, a udp_declaration_port_list whose output is
// `output reg q = 1'b0` and whose inputs are two udp_input_declarations. q
// follows d while en = 1 and holds while en = 0. The printed value is set by
// d before it is read, so it does not depend on what the `= 1'b0` means.
// Run: a = 0, b = 1, s = 1 -> y = 1. t rises once -> q: 0 -> 1.
// d = 1, en = 1 -> h = 1; then en = 0, d = 0 -> h holds 1.
// Output: "y=1 q=1 h=1".
//! inherited IEEE 1364-2005 A.5.1,A.5.2
`timescale 1ns/1ns
primitive b_A_5_1_mux (y, a, b, s);
  output y;
  input a, b;
  input s;
  table
    // a b s : y
       0 ? 0 : 0;
       1 ? 0 : 1;
       ? 0 1 : 0;
       ? 1 1 : 1;
  endtable
endprimitive
primitive b_A_5_1_tff (q, t, unused);
  output q;
  reg q;
  input t, unused;
  initial q = 0;
  table
    // t    unused : q : q+
       (01) ?      : 0 : 1;
       (01) ?      : 1 : 0;
       (?0) ?      : ? : -;
       ?    (??)   : ? : -;
  endtable
endprimitive
primitive b_A_5_1_hold (output reg q = 1'b0, input d, input en);
  table
    // d en : q : q+
       0 1  : ? : 0;
       1 1  : ? : 1;
       ? 0  : ? : -;
  endtable
endprimitive
module b_A_5_1_udp_declarations;
  reg a, b, s, t, d, en;
  wire y, q, h;
  b_A_5_1_mux m (y, a, b, s);
  b_A_5_1_tff f (q, t, 1'b0);
  b_A_5_1_hold k (h, d, en);
  initial begin
    a = 0; b = 1; s = 1; t = 0; d = 1; en = 1;
    #1 t = 1;
    #1 en = 0;
    #1 d = 0;
    #1 $display("y=%b q=%b h=%b", y, q, h);
    $finish(0);
  end
endmodule
