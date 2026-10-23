// IEEE 1364-2005 §12.3.4: "The same syntax for input, inout, and output
// declarations is used in the module header as would be used for the list of
// port style declaration", and its own example writes
// `output reg signed [7:0] f, g,` in a header. Syntax 12-4 gives `output`
// three arms: `output [ net_type ] [ signed ] [ range ]`, `output reg
// [ signed ] [ range ] list_of_variable_port_identifiers`, and `output
// output_variable_type list_of_variable_port_identifiers` with
// `output_variable_type ::= integer | time`. A list_of_variable_port_identifiers
// admits `port_identifier [ = constant_expression ]` (A.2.3).
//
// So `f` and `g` are signed 8-bit variables, `h` a 1-bit variable
// initialized to 1, `k` an integer and `t` a time, each driving the net its
// output port connects to (§12.3.3's "declared as a variable").
//
// HAND DERIVATION: t=0 a<-3, so the always block runs: f = 3, g = -3 (signed
// 8-bit, printed signed through the signed wire), k = 3 * 1000 = 3000,
// t = 2^40 = 1099511627776. h keeps its initializer, 1. At t=1 the display
// prints "3 -3 1 3000 1099511627776".
//
//! inherited IEEE 1364-2005 12.3.4
`timescale 1ns/1ns
module ports(input [7:0] a,
             output reg signed [7:0] f, g,
             output reg h = 1'b1,
             output integer k,
             output time t);
  always @(a) begin f = a; g = -a; k = a * 1000; t = 64'd1 << 40; end
endmodule
module audit_port_ansi_output_reg;
  reg [7:0] a;
  wire signed [7:0] f, g;
  wire h;
  wire [31:0] k;
  wire [63:0] t;
  ports u(.a(a), .f(f), .g(g), .h(h), .k(k), .t(t));
  initial begin a = 3; #1 $display("%0d %0d %b %0d %0d", f, g, h, k, t); $finish(0); end
endmodule
