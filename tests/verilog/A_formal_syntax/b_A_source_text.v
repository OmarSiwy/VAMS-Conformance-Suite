// IEEE 1364-2005 Annex A, p. 487: "The syntax of Verilog HDL source is derived
// from the starting symbol source_text." A.1.2, p. 487:
//   source_text ::= { description }
//   description ::= module_declaration | udp_declaration | config_declaration
//   module_keyword ::= module | macromodule
//
// Three descriptions in one file: a udp_declaration (b_A_inv), a
// module_declaration opened with macromodule (b_A_leaf, ANSI ports) and one
// opened with module (the top). The top drives r = 0 then r = 1 through the
// leaf's inverter, so w is its complement:
//   t=1: w = ~0 = 1 -> "w=1";   t=2: w = ~1 = 0 -> "w=0".
//! inherited IEEE 1364-2005 A
`timescale 1ns/1ns
primitive b_A_inv (y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive
macromodule b_A_leaf (output o, input i);
  b_A_inv u (o, i);
endmodule
module b_A_source_text;
  reg r;
  wire w;
  b_A_leaf l (w, r);
  initial begin
    r = 0;
    #1 $display("w=%b", w);
    r = 1;
    #1 $display("w=%b", w);
    $finish(0);
  end
endmodule
