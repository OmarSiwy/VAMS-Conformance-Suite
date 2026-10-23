// native-required
// IEEE 1364-2005 §9.7.2, p. 133: "An implicit event shall be detected on any
// change in the value of the expression. An edge event shall be detected only
// on the least significant bit of the expression. A change of value in any
// operand of the expression without a change in the result of the expression
// shall not be detected as an event." §4.3.1: "The most significant bit
// specified by the msb constant expression is the left-hand value in the
// range, and the least significant bit specified by the lsb constant
// expression is the right-hand value in the range."
//
// So a term's expression is the select, not its vector: posedge v[2] is an
// edge of bit 2 alone; v[3:2] and v[1 +: 2] (= v[2:1]) have v[2] and v[1] as
// their least significant bits; u is declared [0:3], so u[0] is its MSB, the
// bit 4'b1000 sets; big[70] lies in the second 64-bit word of a 100-bit reg.
//   step 1  v 0000 -> 0100  v[2] 0->1          -> "posedge v[2] 1"
//   step 2  v 0100 -> 0101  v[0] 0->1, v[2] kept -> "change v[0] 2" only
//   step 3  v 0101 -> 0111  v[1] 0->1, a posedge -> nothing (D waits for a negedge)
//   step 4  v 0111 -> 0101  v[1] 1->0          -> "negedge v[1 +: 2] 4"
//   step 5  v 0101 -> 0001  v[2] 1->0          -> "negedge v[3:2] 5"
//   step 6  v 0001 -> 1001  n = v, n[3] 0->1   -> "posedge n[3] 6"
//   step 7  u 0000 -> 0001  u[3], its LSB      -> nothing
//   step 8  u 0001 -> 1001  u[0] 0->1          -> "posedge u[0] 8"
//   step 9  big[3] = 1, word 0 only            -> nothing
//   step 10 big[70] = 1                        -> "posedge big[70] 10"
//   step 11 big = 0, big[70] 1->0: the intra-assignment control that sampled
//           7 at time 1 completes              -> "intra 7 11"
//   step 12 v[2] = x, 0->x is a posedge        -> "posedge v[2] 12"
// One line per step, so no two processes race to print. Lines print only for
// step > 0: the time-0 x -> 0 initialisation races the first waits.
//! inherited IEEE 1364-2005 9.7.2
`timescale 1ns/1ns
module b_9_7_2_select_edge;
  reg [3:0] v;
  reg [0:3] u;
  reg [99:0] big;
  wire [3:0] n;
  integer step, x;

  assign n = v;

  always @(posedge v[2]) if (step > 0) $display("posedge v[2] %0d", step);
  always @(negedge v[3:2]) if (step > 0) $display("negedge v[3:2] %0d", step);
  always @(v[0]) if (step > 0) $display("change v[0] %0d", step);
  always @(negedge v[1 +: 2]) if (step > 0) $display("negedge v[1 +: 2] %0d", step);
  always @(posedge n[3]) if (step > 0) $display("posedge n[3] %0d", step);
  always @(posedge u[0]) if (step > 0) $display("posedge u[0] %0d", step);
  always @(posedge big[70]) if (step > 0) $display("posedge big[70] %0d", step);

  initial begin
    #1 x = @(negedge big[70]) 7;
    $display("intra %0d %0d", x, step);
  end

  initial begin
    step = 0;
    v = 4'b0000;
    u = 4'b0000;
    big = 100'd0;
    #1 step = 1;  v = 4'b0100;
    #1 step = 2;  v = 4'b0101;
    #1 step = 3;  v = 4'b0111;
    #1 step = 4;  v = 4'b0101;
    #1 step = 5;  v = 4'b0001;
    #1 step = 6;  v = 4'b1001;
    #1 step = 7;  u = 4'b0001;
    #1 step = 8;  u = 4'b1001;
    #1 step = 9;  big[3] = 1'b1;
    #1 step = 10; big[70] = 1'b1;
    #1 step = 11; big = 100'd0;
    #1 step = 12; v[2] = 1'bx;
    #1 $finish(0);
  end
endmodule
