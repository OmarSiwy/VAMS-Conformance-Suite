// IEEE 1364-2005 §14.3.2: "If the x transition delays are not
// explicitly specified, the calculation of delay values for x transitions is
// based on the following two pessimistic rules: — Transitions from a known
// state to x shall occur as quickly as possible; that is, the shortest
// possible delay shall be used for any transition to x. — Transitions from x
// to a known state shall take as long as possible; that is, the longest
// possible delay shall be used for any transition from x."
// Table 14-3's usage row, verbatim: (C => Q) = (5, 12, 17, 10, 6, 22), so
// 0->x = min(17, 5) = 5, 1->x = min(6, 12) = 6, z->x = min(10, 22) = 10,
// x->0 = max(22, 12) = 22, x->1 = max(10, 5) = 10, x->z = max(6, 17) = 17;
// Table 14-2's six-value column gives 0->1 = 5, 1->z = 6, z->1 = 10.
//
// Q = C, and C walks Q through each of those transitions, every change long
// after the last landed, so each line is (time of C's change) + its delay:
//   t = 1:   C = 0, Q x -> 0 at 1 + 22 = 23
//   t = 50:  C = 1, Q 0 -> 1 at 55
//   t = 100: C = x, Q 1 -> x at 106
//   t = 150: C = 0, Q x -> 0 at 172
//   t = 200: C = x, Q 0 -> x at 205
//   t = 250: C = 1, Q x -> 1 at 260
//   t = 300: C = z, Q 1 -> z at 306
//   t = 350: C = x, Q z -> x at 360
//   t = 400: C = z, Q x -> z at 417
//   t = 450: C = 1, Q z -> 1 at 460
// The t = 0 settling of Q is not printed (its order against the always
// block is open, §11).
//! inherited IEEE 1364-2005 14.3.2 14.3.1
`timescale 1ns/1ns
module b_14_3_2_x_transition_delays_cell(C, Q);
  input C;
  output Q;
  assign Q = C;
  specify
    (C => Q) = (5, 12, 17, 10, 6, 22);
  endspecify
endmodule

module b_14_3_2_x_transition_delays;
  reg c;
  wire q;
  b_14_3_2_x_transition_delays_cell u(c, q);
  always @(q) if ($time > 0) $display("%0t Q=%b", $time, q);
  initial begin
    #1 c = 0;
    #49 c = 1;
    #50 c = 1'bx;
    #50 c = 0;
    #50 c = 1'bx;
    #50 c = 1;
    #50 c = 1'bz;
    #50 c = 1'bx;
    #50 c = 1'bz;
    #50 c = 1;
  end
endmodule
