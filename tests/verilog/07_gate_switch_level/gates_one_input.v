// D08 — n-input gate primitives with ONE input.
//
// Annex A.3.1:
//     n_input_gate_instance ::= [ name_of_gate_instance ]
//         ( output_terminal , input_terminal { , input_terminal } )
// The braces are zero or more, so one input terminal is derivable. IEEE
// 1364-2005 §7.2 (VAMS §1.1 inherits it) says the same in words: "These six
// logic gates shall have one output and one or more inputs."
//
// HAND DERIVATION. Table 7-3 gives two inputs; §7.2 says versions with more
// "shall have a natural extension", which is the reduction over the input
// list. Over a list of one, with z on a gate input read as x (gates_ninput.v
// says why):
//
//   and  0 if any input is 0, 1 if all are 1, else x   -> 0 1 x x  for a = 0 1 x z
//   or   1 if any input is 1, 0 if all are 0, else x   -> 0 1 x x
//   xor  parity of the inputs, x if any is unknown     -> 0 1 x x
//   nand/nor/xnor are the complements, with ~x = x      -> 1 0 x x
//
// So a one-input and/or/xor is a buffer that turns z into x, and nand/nor/xnor
// an inverter. The illegal neighbour, a gate with no input at all, is
// gates_no_input_rejected.v.
//
//! lrm A.3.1
//! lrm 1.1
//! lrm A.3.1:1000
//! inherited IEEE 1364-2005 7.2
`timescale 1ns/1ns
module d08_gates_one_input;
  reg a;
  wire w_and, w_nand, w_or, w_nor, w_xor, w_xnor;

  and  g_and  (w_and,  a);
  nand g_nand (w_nand, a);
  or   g_or   (w_or,   a);
  nor  g_nor  (w_nor,  a);
  xor  g_xor  (w_xor,  a);
  xnor g_xnor (w_xnor, a);

  initial begin
    a = 1'b0; #1
      $display("a=0 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 0 1 0 1 0 1",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'b1; #1
      $display("a=1 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 1 0 1 0 1 0",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bx; #1
      $display("a=x got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bz; #1
      $display("a=z got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
  end
endmodule
