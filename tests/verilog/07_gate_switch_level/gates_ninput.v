// D08 — n-input gate primitives: and, nand, or, nor, xor, xnor.
//
// Verilog-AMS 2.4 Annex A.3.4:
//     n_input_gatetype ::= and | nand | or | nor | xor | xnor
// Annex A.3.1:
//     n_input_gatetype [drive_strength] [delay2] n_input_gate_instance { , ... } ;
//     n_input_gate_instance ::= [ name_of_gate_instance ]
//         ( output_terminal , input_terminal { , input_terminal } )
// §1.1: "Verilog-AMS HDL consists of the complete IEEE Std 1364 Verilog
// specification", so the value tables of IEEE Std 1364-2005 clause 7 are the
// normative semantics for these instances. §7.8.5.1 confirms the terminal
// order by naming them: "For N-input gates (and, nand, nor, or, xnor, xor) the
// output will be named out, and the inputs reading from left to right will be
// in1, in2, in3, and so forth."
//
// HAND DERIVATION OF EVERY EXPECTED CELL. A gate input is a LOGIC VALUE, not a
// connection: a gate does not transmit high impedance, so z on an input is
// indistinguishable from x (this is exactly what separates a gate from the MOS
// switch in switch_mos.v, which does transmit z). With that coercion the
// six tables are the controlling-value rules and nothing else:
//
//   and   0 if either input is 0            1 only if both are 1   else x
//   or    1 if either input is 1            0 only if both are 0   else x
//   xor   defined only when BOTH inputs are known: a^b             else x
//   nand/nor/xnor are the bitwise complement of the above, with ~x = x.
//
// So `and(0,x) = 0` (the 0 controls) while `xor(0,x) = x` (xor has no
// controlling value) — a compiler that implements xor as "unknown in, unknown
// out" for and/or too fails the a=0 and a=1 rows here.
//
// Every line carries its own `want` literals so the assertion lives in the
// fixture, not only in the golden transcript.
//
//! lrm A.3.1
//! lrm A.3.4
//! lrm 1.1
//! lrm 7.8.5.1
//! lrm A.3.1:1000
//! lrm A.3.4:1000
//! inherited IEEE 1364-2005 7.1.6 7.2
`timescale 1ns/1ns
module d08_gates_ninput;
  reg a, b, c, d;
  wire w_and, w_nand, w_or, w_nor, w_xor, w_xnor;
  wire w_and3, w_xor4;

  and  g_and  (w_and,  a, b);
  nand g_nand (w_nand, a, b);
  or   g_or   (w_or,   a, b);
  nor  g_nor  (w_nor,  a, b);
  xor  g_xor  (w_xor,  a, b);
  xnor g_xnor (w_xnor, a, b);

  // A.3.1 lets one n_input_gate_instance take any number of input terminals
  // after the single output terminal.
  and  g_and3 (w_and3, a, b, c);
  xor  g_xor4 (w_xor4, a, b, c, d);

  initial begin
    a = 1'b0; b = 1'b0; #1
      $display("a=0 b=0 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 0 1 0 1 0 1",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'b0; b = 1'b1; #1
      $display("a=0 b=1 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 0 1 1 0 1 0",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'b0; b = 1'bx; #1
      $display("a=0 b=x got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 0 1 x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'b0; b = 1'bz; #1
      $display("a=0 b=z got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 0 1 x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'b1; b = 1'b0; #1
      $display("a=1 b=0 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 0 1 1 0 1 0",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'b1; b = 1'b1; #1
      $display("a=1 b=1 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 1 0 1 0 0 1",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'b1; b = 1'bx; #1
      $display("a=1 b=x got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x 1 0 x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'b1; b = 1'bz; #1
      $display("a=1 b=z got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x 1 0 x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bx; b = 1'b0; #1
      $display("a=x b=0 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 0 1 x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bx; b = 1'b1; #1
      $display("a=x b=1 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x 1 0 x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bx; b = 1'bx; #1
      $display("a=x b=x got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bx; b = 1'bz; #1
      $display("a=x b=z got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bz; b = 1'b0; #1
      $display("a=z b=0 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want 0 1 x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bz; b = 1'b1; #1
      $display("a=z b=1 got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x 1 0 x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bz; b = 1'bx; #1
      $display("a=z b=x got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);
    a = 1'bz; b = 1'bz; #1
      $display("a=z b=z got and=%b nand=%b or=%b nor=%b xor=%b xnor=%b want x x x x x x",
               w_and, w_nand, w_or, w_nor, w_xor, w_xnor);

    // Arity: a 3-input and and a 4-input xor. and3 = a&b&c;
    // xor4 = a^b^c^d, which is 1 exactly when an odd number of
    // inputs is 1 and x as soon as any input is unknown.
    a = 1'b1; b = 1'b1; c = 1'b1; d = 1'b0; #1
      $display("a=1 b=1 c=1 d=0 got and3=%b xor4=%b want 1 1", w_and3, w_xor4);
    a = 1'b1; b = 1'b1; c = 1'b0; d = 1'b1; #1
      $display("a=1 b=1 c=0 d=1 got and3=%b xor4=%b want 0 1", w_and3, w_xor4);
    a = 1'b1; b = 1'b1; c = 1'bx; d = 1'b1; #1
      $display("a=1 b=1 c=x d=1 got and3=%b xor4=%b want x x", w_and3, w_xor4);
    a = 1'b1; b = 1'b0; c = 1'b1; d = 1'b1; #1
      $display("a=1 b=0 c=1 d=1 got and3=%b xor4=%b want 0 1", w_and3, w_xor4);
  end
endmodule
