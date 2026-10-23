// IEEE 1364-2005 §14.2.4, p. 215: "A state-dependent path makes it possible
// to assign a delay to a module path that affects signal propagation delay
// through the path only if specified conditions are true." Syntax 14-5:
//   state_dependent_path_declaration ::=
//       if ( module_path_expression ) simple_path_declaration
//     | if ( module_path_expression ) edge_sensitive_path_declaration
//     | ifnone simple_path_declaration
// §14.2.4.1, pp. 215-216: "The operands in the conditional expression shall
// be constructed from the following: — Scalar or vector module input ports or
// inout ports or their bit-selects or part-selects — Locally defined
// variables or nets or their bit-selects or part-selects — Compile time
// constants (constant numbers and specify parameters)" and "Table 14-1
// contains a list of valid operators that may be used in conditional
// expressions." Table 14-1 lists ~ & | ^ ^~ ~^ == != && || ! (bitwise and
// logical), the reductions & | ^ ~& ~| ^~ ~^, {} { {} } and ?:.
// §14.2.4.2, p. 216: "If the path description of a state-dependent path is a
// simple path, then it is called a simple state-dependent path."
//
// Three cells: §14.2.4.2's Example 1 (XORgate) and Example 2 (ALU) verbatim
// but for the names, the ALU given the functional description the clause
// omits (00 add, 01 pass i1, 10 pass i2, 11 zero); and a cell whose
// conditions use every Table 14-1 operator on each operand kind §14.2.4.1
// admits: input ports (a, b), a bit-select and a part-select of the vector
// input v, the locally defined net t, a constant number and the specparam ON.
// (A.8.4's module_path_primary has no select; the bit- and part-selects rest
// on §14.2.4.1's text, which names them.)
//
// The conditions select each output change's delay (§14.3.3), but the
// transcript samples 50 after each input change, past the longest delay
// (25.0), so it is the cells' logic whichever is chosen:
//   t = 1:   a=0 b=1; i1=8'h12 i2=8'h34 opcode=00; v=4'b1010
//            xor = 0^1 = 1; o1 = 12+34 = 46; y = a^b = 1
//   t = 51:  a=1, opcode=01: xor = 1^1 = 0; o1 = i1 = 12; y = 0
//   t = 101: opcode=10: o1 = i2 = 34
//   t = 151: opcode=11: o1 = 00
//! inherited IEEE 1364-2005 14.2.4 14.2.4.1 14.2.4.2
`timescale 1ns/1ns
module b_14_2_4_state_dependent_paths_xor(a, b, out);
  input a, b;
  output out;
  xor x1 (out, a, b);
  specify
    specparam noninvrise = 1, noninvfall = 2;
    specparam invertrise = 3, invertfall = 4;
    if (a) (b => out) = (invertrise, invertfall);
    if (b) (a => out) = (invertrise, invertfall);
    if (~a)(b => out) = (noninvrise, noninvfall);
    if (~b)(a => out) = (noninvrise, noninvfall);
  endspecify
endmodule

module b_14_2_4_state_dependent_paths_alu(o1, i1, i2, opcode);
  input [7:0] i1, i2;
  input [2:1] opcode;
  output [7:0] o1;
  assign o1 = opcode == 2'b00 ? i1 + i2 : opcode == 2'b01 ? i1 : opcode == 2'b10 ? i2 : 8'h00;
  specify
    // add operation
    if (opcode == 2'b00) (i1,i2 *> o1) = (25.0, 25.0);
    // pass-through i1 operation
    if (opcode == 2'b01) (i1 => o1) = (5.6, 8.0);
    // pass-through i2 operation
    if (opcode == 2'b10) (i2 => o1) = (5.6, 8.0);
    // delays on opcode changes
    (opcode *> o1) = (6.1, 6.5);
  endspecify
endmodule

module b_14_2_4_state_dependent_paths_ops(a, b, v, y);
  input a, b;
  input [3:0] v;
  output y;
  wire t = a | b;
  assign y = a ^ b;
  specify
    specparam ON = 1'b1;
    if (~a & b | (a ^ t) ^~ (b ~^ 1'b0)) (a => y) = 1;
    if (!(a != b) && v[1] == ON || a == 1'b0) (b => y) = 2;
    if (&v[3:2] | |v ^ ^v & ~&v | ~|v) (v *> y) = 3;
    if (^~{a, b} ~^ v[0]) (a => y) = 4;
    if ({2{t}} == {a, ON} ? ~^v : v[2]) (b => y) = 5;
  endspecify
endmodule

module b_14_2_4_state_dependent_paths;
  reg a, b;
  reg [7:0] i1, i2;
  reg [2:1] opcode;
  reg [3:0] v;
  wire out, y;
  wire [7:0] o1;
  b_14_2_4_state_dependent_paths_xor gx(a, b, out);
  b_14_2_4_state_dependent_paths_alu ga(o1, i1, i2, opcode);
  b_14_2_4_state_dependent_paths_ops go(a, b, v, y);
  initial begin
    #1 a = 0; b = 1; i1 = 8'h12; i2 = 8'h34; opcode = 2'b00; v = 4'b1010;
    #50 $display("t=51 xor=%b o1=%h y=%b", out, o1, y);
    a = 1; opcode = 2'b01;
    #50 $display("t=101 xor=%b o1=%h y=%b", out, o1, y);
    opcode = 2'b10;
    #50 $display("t=151 o1=%h", o1);
    opcode = 2'b11;
    #50 $display("t=201 o1=%h", o1);
  end
endmodule
