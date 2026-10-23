// native-required
// IEEE 1364-2005 §9.7.2, p. 133: "An implicit event shall be detected on any
// change in the value of the expression. An edge event shall be detected only
// on the least significant bit of the expression." §11.2: "Every change in
// value of a net or variable ... is considered an update event. Processes are
// sensitive to update events. When an update event is executed, all the
// processes that are sensitive to that event are evaluated". §11.6.3: a
// blocking assignment "performs the assignment to the left-hand side and
// enables any events based upon the update of the left-hand side".
//
// So a select term sees every update of its vector, as the vector's own term
// does: two blocking writes in a row that put a bit back where it was (a
// zero-width pulse) still make the edge between them, and a process waiting
// on it is enabled at the first write. §11.4.2 lets the writer be suspended
// between the two writes or not, so the waiter may run before or after the
// second one; either way it was enabled. Each waiter therefore records the
// step it saw, which no interleaving changes, instead of a count, which a
// second change of the same bit could raise.
//   step 1  v[0] 0->1->0  posedge v[0]; posedge v (its LSB)   -> pb=1 pw=1
//   step 2  v[2] 1->0->1  negedge v[2] at the first write;
//                         v[3:2]'s LSB v[2] rises at the second -> nb=2 pp=2
//   step 3  v[1] 0->1->0  a change of v[1]                     -> ab=3
// No other step moves the bit any of these watches. A select term evaluated
// once after the writer (the value v[0] had settled at, 0 -> 0) would see no
// event at all: pb=0 nb=0 ab=0 pp=0, and only pw=1. Lines print only for
// step > 0: the time-0 x -> 0100 initialisation races the first waits.
//! inherited IEEE 1364-2005 9.7.2
`timescale 1ns/1ns
module b_9_7_2_select_edge_glitch;
  reg [3:0] v;
  integer step, pb, nb, ab, pp, pw;

  always @(posedge v[0]) if (step > 0) pb = step;
  always @(negedge v[2]) if (step > 0) nb = step;
  always @(v[1]) if (step > 0) ab = step;
  always @(posedge v[3:2]) if (step > 0) pp = step;
  always @(posedge v) if (step > 0) pw = step;

  initial begin
    step = 0;
    pb = 0; nb = 0; ab = 0; pp = 0; pw = 0;
    v = 4'b0100;
    #1 step = 1; v[0] = 1'b1; v[0] = 1'b0;
    #1 step = 2; v[2] = 1'b0; v[2] = 1'b1;
    #1 step = 3; v[1] = 1'b1; v[1] = 1'b0;
    #1 $display("pb=%0d nb=%0d ab=%0d pp=%0d pw=%0d", pb, nb, ab, pp, pw);
    $finish(0);
  end
endmodule
