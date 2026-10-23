// IEEE 1364-2005 A.5.3, p. 496-497:
//   udp_body ::= combinational_body | sequential_body
//   combinational_body ::= table combinational_entry { combinational_entry } endtable
//   combinational_entry ::= level_input_list : output_symbol ;
//   sequential_body ::= [ udp_initial_statement ] table sequential_entry { sequential_entry } endtable
//   udp_initial_statement ::= initial output_port_identifier = init_val ;
//   init_val ::= 1'b0 | 1'b1 | 1'bx | 1'bX | 1'B0 | 1'B1 | 1'Bx | 1'BX | 1 | 0
//   sequential_entry ::= seq_input_list : current_state : next_state ;
//   seq_input_list ::= level_input_list | edge_input_list
//   level_input_list ::= level_symbol { level_symbol }
//   edge_input_list ::= { level_symbol } edge_indicator { level_symbol }
//   edge_indicator ::= ( level_symbol level_symbol ) | edge_symbol
//   current_state ::= level_symbol
//   next_state ::= output_symbol | -
//   output_symbol ::= 0 | 1 | x | X
//   level_symbol ::= 0 | 1 | x | X | ? | b | B
//   edge_symbol ::= r | R | f | F | p | P | n | N | *
//
// b_A_5_3_xor: a combinational_body whose entries use level symbols 0 1 x b
// and output symbols 0 1 x X; an x input gives x:
//   xor(1, 0) = 1, xor(1, 1) = 0, xor(x, 1) = x.
// b_A_5_3_ff: a sequential_body with udp_initial_statement `initial q = 1'B1;`
// and edge entries written with an edge_symbol (r, f, *, N) and an
// edge_indicator ((0x) and (x1)); current_state ? and b; next_state - and
// output symbols. d is sampled on a rising clk (r), held on a falling one
// (f, and N, which also covers clk's first step x -> 0 at t=0: Table 8-1,
// p. 108: n is "Iteration of (10), (1x)and (x0"), and any d change (*) keeps q. Each
// value is read after #0, once the UDP's same-time output update has landed.
// Sequence (q starts 1):
//   t=1 d = 0; t=2 clk 0 -> 1 (r): q = d = 0; t=3 clk falls (f): q holds 0;
//   t=4 d = 1 (*): q holds 0; t=5 clk rises: q = 1.
// Output: "c=10x q=0 0 0 1".
//! inherited IEEE 1364-2005 A.5.3
`timescale 1ns/1ns
primitive b_A_5_3_xor (y, a, b);
  output y;
  input a, b;
  table
    // a b : y
       0 0 : 0;
       0 1 : 1;
       1 0 : 1;
       1 1 : 0;
       x b : X;
       b x : x;
  endtable
endprimitive
primitive b_A_5_3_ff (q, clk, d);
  output q;
  reg q;
  input clk, d;
  initial q = 1'B1;
  table
    // clk  d : q : q+
       r    0 : ? : 0;
       r    1 : b : 1;
       (0x) ? : ? : -;
       (x1) ? : ? : -;
       f    ? : ? : -;
       N    ? : ? : -;
       ?    * : ? : -;
  endtable
endprimitive
module b_A_5_3_udp_body;
  reg clk, d;
  wire y1, y2, y3, q;
  b_A_5_3_xor x1 (y1, 1'b1, 1'b0);
  b_A_5_3_xor x2 (y2, 1'b1, 1'b1);
  b_A_5_3_xor x3 (y3, 1'bx, 1'b1);
  b_A_5_3_ff f (q, clk, d);
  reg [3:0] seen;
  initial begin
    clk = 0;
    #1 d = 0;
    #1 clk = 1;
    #0 seen[3] = q;
    #1 clk = 0;
    #0 seen[2] = q;
    #1 d = 1;
    #0 seen[1] = q;
    #1 clk = 1;
    #0 seen[0] = q;
    $display("c=%b%b%b q=%b %b %b %b", y1, y2, y3, seen[3], seen[2], seen[1], seen[0]);
    $finish(0);
  end
endmodule
