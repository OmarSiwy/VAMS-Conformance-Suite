// IEEE1364-2005 §7.6: tran unconditionally conducts in BOTH directions,
// unlike a directed buffer. One driver is z in each observation, so no
// strength resolution ambiguity is involved.
//! inherited IEEE 1364-2005 7.6
// native-required
`timescale 1ns/1ns
module audit_primitive_tran_both_directions;
  reg left, right;
  wire a, b;
  assign a = left;
  assign b = right;
  tran link(a, b);
  initial begin
    left = 1; right = 1'bz;
    #1 $display("left_to_right=%b,%b", a, b);
    left = 1'bz; right = 0;
    #1 $display("right_to_left=%b,%b", a, b);
    left = 1'bz; right = 1'bz;
    #1 $display("undriven=%b,%b", a, b);
    $finish(0);
  end
endmodule
