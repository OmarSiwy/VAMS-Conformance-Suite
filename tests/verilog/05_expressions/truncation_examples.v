// IEEE 1364-2005 §5.6, pp. 66-67: "If the width of the right-hand expression
// is larger than the width of the left-hand side in an assignment, the MSBs
// of the right-hand expression will always be discarded to match the size of
// the left-hand side. Implementations are not required to warn or report any
// errors related to assignment size mismatch or truncation. Truncating the
// sign bit of a signed expression may change the sign of the result."
//
// The clause's three examples, each value the one the clause states:
//   reg [5:0] a; reg signed [4:0] b: a = 8'hff -> 6'h3f; b = 8'hff -> 5'h1f
//   reg [0:5] a2; reg signed [0:4] b2, c2: a2 = 8'sh8f -> 6'h0f;
//     b2 = 8'sh8f -> 5'h0f; c2 = -113 -> 15 ("1000_1111 = (-'h71 = -113)
//     truncates to ('h0F = 15)"): -113 = ...1000_1111, low 5 bits 01111
//   reg [7:0] a3; reg signed [7:0] b3; reg signed [5:0] c3, d3:
//     a3 = 8'hff; c3 = a3 -> 6'h3f; b3 = -113; d3 = b3 -> 6'h0f
// %h of 6 and 5 bits is two digits: 3f 1f 0f 0f, c2 printed %0d: 15.
//! inherited IEEE 1364-2005 5.6
module b_5_6_truncation_examples;
  reg [5:0] a;
  reg signed [4:0] b;
  reg [0:5] a2;
  reg signed [0:4] b2, c2;
  reg [7:0] a3;
  reg signed [7:0] b3;
  reg signed [5:0] c3, d3;
  initial begin
    a = 8'hff;
    b = 8'hff;
    $display("%h %h", a, b);
    a2 = 8'sh8f;
    b2 = 8'sh8f;
    c2 = -113;
    $display("%h %h %0d", a2, b2, c2);
    a3 = 8'hff;
    c3 = a3;
    b3 = -113;
    d3 = b3;
    $display("%h %h", c3, d3);
    $finish(0);
  end
endmodule
