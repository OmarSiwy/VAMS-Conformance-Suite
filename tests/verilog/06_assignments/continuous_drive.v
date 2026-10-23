// IEEE 1364-2005 §6.1, p. 68: "Continuous assignments shall drive values onto
// nets, both vector and scalar. This assignment shall occur whenever the
// value of the right-hand side changes."
//
// y = a & b (scalar net), v = r + 4'd1 (4-bit vector net). Each read is one
// time unit after the operands change, so the new value has been driven.
//   t1: a = 0, b = 1, r = 3    -> y = 0, v = 3 + 1 = 4       -> 0 0100
//   t2: a = 1                  -> y = 1 & 1 = 1, v holds     -> 1 0100
//   t3: r = 15                 -> v = 15 + 1 = 16, the add is 4 bits wide
//                                 (the widest of r, 4'd1 and v; §5.4.1), so
//                                 0000; y holds              -> 1 0000
//   t4: b = 0, r = 4'b10x0     -> y = 0; an x operand bit makes every bit of
//                                 the sum x (§5.1.5)        -> 0 xxxx
//! inherited IEEE 1364-2005 6.1
module b_6_1_continuous_drive;
  reg a, b;
  reg [3:0] r;
  wire y;
  wire [3:0] v;
  assign y = a & b;
  assign v = r + 4'd1;
  initial begin
    a = 0; b = 1; r = 4'd3;
    #1 $display("%b %b", y, v);
    a = 1;
    #1 $display("%b %b", y, v);
    r = 4'd15;
    #1 $display("%b %b", y, v);
    b = 0; r = 4'b10x0;
    #1 $display("%b %b", y, v);
    $finish(0);
  end
endmodule
