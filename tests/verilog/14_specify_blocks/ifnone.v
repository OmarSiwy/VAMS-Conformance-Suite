// IEEE 1364-2005 §14.2.4.4, p. 218: "The ifnone keyword is used to specify a
// default state-dependent path delay when all other conditions for the path
// are false. The ifnone condition shall specify the same module path source
// and destination as the state-dependent module paths." ... "— Only simple
// module paths may be described with an ifnone condition. — The
// state-dependent paths that correspond to the ifnone path may be either
// simple module paths or edge-sensitive paths. — If there are no
// corresponding state-dependent module paths to the ifnone module path, then
// the ifnone module path shall be treated the same as an unconditional simple
// module path."
// Its Example 1, "the following are valid state-dependent path combinations",
// is three combinations, one cell each here:
//   c1:  if (C1) (IN => OUT) = (1,1);
//        ifnone (IN => OUT) = (2,2);
//   alu: the three `if (opcode == ...)` paths of §14.2.4.2's ALU, and
//        ifnone (i2 => o1) = (15.0, 15.0);
//   ff:  (posedge CLK => (Q +: D)) = (1,1);
//        ifnone (CLK => Q) = (2,2);
// plus a fourth cell, lone, whose ifnone path has no state-dependent partner,
// the third rule's case: ifnone (A => Y) = 3;
//
// Logic: c1 OUT = IN; alu as in state_dependent_paths.v (00 add,
// 01 i1, 10 i2, 11 zero); ff Q takes D on posedge CLK; lone Y = ~A.
// Each output change takes the delay its active paths select, an ifnone
// path only while its state-dependent paths are not active (§14.2.4.4,
// §14.3.3); the transcript is sampled 40 or more after each change, past the
// longest delay (25.0):
//   t = 1:   IN=1 C1=0; i1=8'h05 i2=8'h07 opcode=11; D=1 CLK x -> 0; A=0
//   t = 11:  CLK rises: Q <= 1.
//   t = 51:  prints OUT=1 o1=00 Q=1 Y=1. Then IN=0 C1=1 opcode=10 D=0 A=1.
//   t = 61:  CLK falls (Q keeps 1).
//   t = 101: prints OUT=0 o1=07 Q=1 Y=0.
//! inherited IEEE 1364-2005 14.2.4.4
`timescale 1ns/1ns
module b_14_2_4_4_ifnone_c1(C1, IN, OUT);
  input C1, IN;
  output OUT;
  assign OUT = IN;
  specify
    if (C1) (IN => OUT) = (1,1);
    ifnone (IN => OUT) = (2,2);
  endspecify
endmodule

module b_14_2_4_4_ifnone_alu(o1, i1, i2, opcode);
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
    // all other operations
    ifnone (i2 => o1) = (15.0, 15.0);
  endspecify
endmodule

module b_14_2_4_4_ifnone_ff(CLK, D, Q);
  input CLK, D;
  output Q;
  reg Q;
  always @(posedge CLK) Q <= D;
  specify
    (posedge CLK => (Q +: D)) = (1,1);
    ifnone (CLK => Q) = (2,2);
  endspecify
endmodule

module b_14_2_4_4_ifnone_lone(A, Y);
  input A;
  output Y;
  assign Y = ~A;
  specify
    ifnone (A => Y) = 3;
  endspecify
endmodule

module b_14_2_4_4_ifnone;
  reg C1, IN, CLK, D, A;
  reg [7:0] i1, i2;
  reg [2:1] opcode;
  wire OUT, Q, Y;
  wire [7:0] o1;
  b_14_2_4_4_ifnone_c1 u1(C1, IN, OUT);
  b_14_2_4_4_ifnone_alu u2(o1, i1, i2, opcode);
  b_14_2_4_4_ifnone_ff u3(CLK, D, Q);
  b_14_2_4_4_ifnone_lone u4(A, Y);
  initial begin
    #1 IN = 1; C1 = 0; i1 = 8'h05; i2 = 8'h07; opcode = 2'b11; D = 1; CLK = 0; A = 0;
    #10 CLK = 1;
    #40 $display("t=51 OUT=%b o1=%h Q=%b Y=%b", OUT, o1, Q, Y);
    IN = 0; C1 = 1; opcode = 2'b10; D = 0; A = 1;
    #10 CLK = 0;
    #40 $display("t=101 OUT=%b o1=%h Q=%b Y=%b", OUT, o1, Q, Y);
  end
endmodule
