// IEEE1364-2005 §6.1.3: for a vector net, "If the right-hand side makes a
// transition from nonzero to zero, then the falling delay shall be used"; to
// z, the turn-off delay; "For all other cases, the rising delay shall be
// used". A declaration assignment's delay "is part of the continuous
// assignment", whose "rising and falling delays shall not be applied to the
// individual bits" (nd). A net delay (nn: `wire [7:0] #(3,5) nn;` and a
// separate `assign`) takes the same whole-value rule by VerA's reading
// (specification/Vague_Decisions.md VD-119). Before #55 both chose from
// bit 0 of the new value.
// a = 1 at t=0, 2 at t=10, 0 at t=20; delays rise 3, fall 5:
//   t=10  1 -> 2: nonzero to nonzero, rising 3 -> every view moves at 13
//         (bit 0 of 2 is 0: the bug took falling 5 -> 15 for nd and nn)
//   t=20  2 -> 0: nonzero to zero, falling 5 -> every view moves at 25
// Samples at 12 (old value), 14 (moved), 24 (old), 26 (moved).
//! inherited IEEE 1364-2005 6.1.3
`timescale 1ns/1ns
module b_6_1_3_vector_net_delay;
  reg [7:0] a;
  wire [7:0] #(3,5) nd = a;
  wire [7:0] #(3,5) nn;
  wire [7:0] ca;
  assign nn = a;
  assign #(3,5) ca = a;
  initial begin
    a = 8'd1;
    #10 a = 8'd2;
    #2 $display("t12 nd=%0d nn=%0d ca=%0d", nd, nn, ca);
    #2 $display("t14 nd=%0d nn=%0d ca=%0d", nd, nn, ca);
    #6 a = 8'd0;
    #4 $display("t24 nd=%0d nn=%0d ca=%0d", nd, nn, ca);
    #2 $display("t26 nd=%0d nn=%0d ca=%0d", nd, nn, ca);
    $finish(0);
  end
endmodule
