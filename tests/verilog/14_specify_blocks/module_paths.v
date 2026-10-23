// IEEE 1364-2005 §14.2, p. 212: "A module path may be described as a simple
// path, an edge-sensitive path, or a state-dependent path. A module path shall
// be defined inside a specify block as a connection between a source signal
// and a destination signal. Module paths can connect any combination of
// vectors and scalars."
// §14.2.1, p. 213: "The module path source shall be a net that is connected
// to a module input port or inout port." "The module path destination shall
// be a net or variable that is connected to a module output port or inout
// port." "The module path destination shall have only one driver inside the
// module."
// §14.2.2, pp. 213-214: "Simple paths can be declared in one of two forms:
// — Source *> destination — Source => destination" and "The following three
// examples illustrate valid simple module path declarations:
//   (A => Q) = 10;
//   (B => Q) = (12);
//   (C, D *> Q) = 18;"
// §14.2.6, p. 220: "Multiple module paths may be described in a single
// statement by using the symbol *> to connect a comma-separated list of
// sources to a comma-separated list of destinations. When describing multiple
// module paths in one statement, the lists of sources and destinations may
// contain a mix of scalars and vectors of any size." Its example:
//   (a, b, c *> q1, q2) = 10;
//
// The cell carries the §14.2.2 examples verbatim, the §14.2.6 example with q2
// a 2-bit vector (the mix of scalars and vectors), and one path whose source
// is the inout io and whose destination is the variable qr on an output port
// (§14.2.1's other legal terminals). Every destination has one driver.
//
// Each output change takes its paths' delay (§14.3.3; the variable qr's at
// the net its output port drives); every input settles at t = 1 or t = 51,
// the longest path delay is 18, and each $display runs 50 later.
//
// The functions (Q = A&B | C^D, qr = ~io, q1 = a&b&c, q2 = {a|b, c}):
//   t = 1:  A=1 B=1 C=0 D=0 io=0 a=1 b=0 c=0
//           Q = 1 | 0 = 1; qr = ~0 = 1; q1 = 1&0&0 = 0; q2 = {1|0, 0} = 10
//   t = 51: A=0 C=1 D=1 io=1 b=1 c=1
//           Q = 0 | (1^1) = 0; qr = 0; q1 = 1&1&1 = 1; q2 = {1, 1} = 11
// Stimulus starts at t = 1, not 0, so `always @(io)` is already waiting when
// io first changes (§11 leaves the t = 0 order of the two processes open).
//! inherited IEEE 1364-2005 14.2 14.2.1 14.2.2 14.2.6
`timescale 1ns/1ns
module b_14_2_module_paths_cell(A, B, C, D, Q, io, qr, a, b, c, q1, q2);
  input A, B, C, D;
  output Q;
  inout io;
  output qr;
  reg qr;
  input a, b, c;
  output q1;
  output [1:0] q2;
  assign Q = (A & B) | (C ^ D);
  always @(io) qr = ~io;
  assign q1 = a & b & c;
  assign q2 = {a | b, c};
  specify
    (A => Q) = 10;
    (B => Q) = (12);
    (C, D *> Q) = 18;
    (io => qr) = 5;
    (a, b, c *> q1, q2) = 10;
  endspecify
endmodule

module b_14_2_module_paths;
  reg A, B, C, D, iod, a, b, c;
  wire io, Q, qr, q1;
  wire [1:0] q2;
  assign io = iod;
  b_14_2_module_paths_cell u(A, B, C, D, Q, io, qr, a, b, c, q1, q2);
  initial begin
    #1 A = 1; B = 1; C = 0; D = 0; iod = 0; a = 1; b = 0; c = 0;
    #50 $display("t=51 Q=%b qr=%b q1=%b q2=%b", Q, qr, q1, q2);
    A = 0; C = 1; D = 1; iod = 1; b = 1; c = 1;
    #50 $display("t=101 Q=%b qr=%b q1=%b q2=%b", Q, qr, q1, q2);
  end
endmodule
