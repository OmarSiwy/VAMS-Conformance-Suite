// IEEE 1364-2005 §14.2.5, p. 219: "The operator *> shall be used to
// establish a full connection between source and destination. In a full
// connection, every bit in the source shall connect to every bit in the
// destination. The module path source need not have the same number of bits
// as the module path destination." ... "The operator => shall be used to
// establish a parallel connection between source and destination. In a
// parallel connection, each bit in the source shall connect to one
// corresponding bit in the destination. Parallel module paths can be created
// only between sources and destinations that contain the same number of
// bits." ... "Because scalars are 1 bit wide, either *> or => may be used to
// set up bit-to-bit connections between two scalars."
// Its Example 2 (p. 220), the 2:1 multiplexor:
//   module mux8 (in1, in2, s, q) ;
//   output [7:0] q;
//   input [7:0] in1, in2;
//   input s;
//   // Functional description omitted ...
//   specify
//     (in1 => q) = (3, 4) ;
//     (in2 => q) = (2, 3) ;
//     (s *> q) = 1;
//   endspecify
//   endmodule
//
// The cell is that example with q = s ? in2 : in1 as the omitted function,
// and three more paths for the clause's other cases: (in1 *> nib), a full
// connection between vectors of different sizes (8 to 4 bits, nib =
// in1[7:4]), and (s => ns) and (s *> ns2), a scalar to a scalar either way
// (ns = ns2 = ~s).
//
// Each output change takes its paths' delay (§14.3.3); the transcript is
// sampled 50 after each change, past the longest delay (4):
//   t = 1:  in1 = 8'hA5, in2 = 8'h3C, s = 0: q = in1 = a5, nib = a, ns = 1,
//           ns2 = 1
//   t = 51: s = 1: q = in2 = 3c, nib = a, ns = 0, ns2 = 0
//! inherited IEEE 1364-2005 14.2.5
`timescale 1ns/1ns
module b_14_2_5_full_parallel_paths_mux8(in1, in2, s, q, nib, ns, ns2);
  output [7:0] q;
  input [7:0] in1, in2;
  input s;
  output [3:0] nib;
  output ns, ns2;
  assign q = s ? in2 : in1;
  assign nib = in1[7:4];
  assign ns = ~s;
  assign ns2 = ~s;
  specify
    (in1 => q) = (3, 4) ;
    (in2 => q) = (2, 3) ;
    (s *> q) = 1;
    (in1 *> nib) = 2;
    (s => ns) = 1;
    (s *> ns2) = 1;
  endspecify
endmodule

module b_14_2_5_full_parallel_paths;
  reg [7:0] in1, in2;
  reg s;
  wire [7:0] q;
  wire [3:0] nib;
  wire ns, ns2;
  b_14_2_5_full_parallel_paths_mux8 u(in1, in2, s, q, nib, ns, ns2);
  initial begin
    #1 in1 = 8'hA5; in2 = 8'h3C; s = 0;
    #50 $display("t=51 q=%h nib=%h ns=%b ns2=%b", q, nib, ns, ns2);
    s = 1;
    #50 $display("t=101 q=%h nib=%h ns=%b ns2=%b", q, nib, ns, ns2);
  end
endmodule
