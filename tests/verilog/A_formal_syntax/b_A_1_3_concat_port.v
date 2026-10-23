// IEEE 1364-2005 A.1.3, p. 487-488:
//   port ::= [ port_expression ] | . port_identifier ( [ port_expression ] )
//   port_expression ::= port_reference | { port_reference { , port_reference } }
// A port whose port_expression is `{hi, lo}` is one 2-bit port. §12.3.2,
// p. 174 (quoted for context): the port reference "can be one of the
// following: ... A concatenation of any of the above".
//
// The top connects 2'b10 to it (hi = 1, lo = 0) and cold drives
// q = {6'b0, hi, lo} = 8'd2 -> "q=2".
//! inherited IEEE 1364-2005 A.1.3
`timescale 1ns/1ns
module b_A_1_3_cold ({hi, lo}, q);
  input hi, lo;
  output [7:0] q;
  assign q = {6'b0, hi, lo};
endmodule
module b_A_1_3_concat_port;
  wire [7:0] q;
  b_A_1_3_cold c (2'b10, q);
  initial #1 begin
    $display("q=%0d", q);
    $finish(0);
  end
endmodule
