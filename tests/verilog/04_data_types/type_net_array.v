// IEEE 1364-2005 §4.9: "An array declaration for a net or a variable declares
// an element type that is either scalar or vector", as in its table's
// `wire [0:7] y[5:0];`, and A.2.3 `list_of_net_identifiers ::= net_identifier
// { dimension }`. §4.9.1: "Elements of net arrays can be used in the same
// fashion as a scalar or vector net. They are useful for connecting to ports
// of module instances inside loop generate constructs (see 12.4.1)." §4.9:
// "To assign a value to an element of an array, an index for every dimension
// shall be specified. The index can be an expression."
//
// So each element below is a net of its own: driven by a continuous
// assignment, by a gate, or by an instance's output port, and read with a
// constant or a variable index. `m`'s undriven elements stay z (§4.2.1: a net
// with no driver is high impedance).
//
// HAND DERIVATION: r <- 0101 at t=0.
//   w[0] = r = 0101; w[1] = r + 1 = 0110
//   q[i] = ~w[i] (one `inv` per generate iteration): q[0] = 1010, q[1] = 1001
//   m[1][0] = r[0] & r[1] = 1 & 0 = 0; m[0][1] = 1; m[0][0], m[1][1] = z
//   t=1 prints "0101 0110 1010 1001 z10z"; k <- 1, q[k] prints "1001"
//   r <- 0011: w[1] = 0100, q[1] = 1011, m[1][0] = 1 & 1 = 1
//   t=2 prints "0100 1011 1"
//
//! inherited IEEE 1364-2005 4.9.1
`timescale 1ns/1ns
module inv(input [3:0] a, output [3:0] y);
  assign y = ~a;
endmodule
module audit_type_net_array;
  reg [3:0] r;
  wire [3:0] w [0:1];
  wire [3:0] q [1:0];
  wire m [0:1][0:1];
  integer k;
  genvar i;
  assign w[0] = r;
  assign w[1] = r + 1;
  generate
    for (i = 0; i < 2; i = i + 1) begin : g
      inv u(.a(w[i]), .y(q[i]));
    end
  endgenerate
  and a0(m[1][0], r[0], r[1]);
  assign m[0][1] = 1'b1;
  initial begin
    r = 4'b0101;
    #1 $display("%b %b %b %b %b%b%b%b", w[0], w[1], q[0], q[1], m[0][0], m[0][1], m[1][0], m[1][1]);
    k = 1;
    $display("%b", q[k]);
    r = 4'b0011;
    #1 $display("%b %b %b", w[1], q[1], m[1][0]);
    $finish(0);
  end
endmodule
