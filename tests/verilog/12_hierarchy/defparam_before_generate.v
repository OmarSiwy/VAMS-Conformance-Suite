// IEEE 1364-2005 §12.8.1, p. 197: "b) The hierarchy below each starting point is
// expanded as much as possible without elaborating generate constructs. All
// parameters encountered during this expansion are given their final values by
// applying initial values, parameter overrides, and defparam statements." "c)
// Each generate construct encountered in step b) is revisited, and the
// generate scheme is evaluated." §12.8.2, p. 198: "It shall be an error if a
// hierarchical name in a defparam is resolved before the hierarchy is
// completely elaborated and that name would resolve differently once the
// model is completely elaborated."
//
// leaf's if-generate chooses by p. l1 keeps p = 1 -> block "one" at t = 1.
// l2's p is set by a defparam in the parent to 7; the defparam is applied in
// step b), before the generate scheme is evaluated in step c), so l2 takes the
// else block -> "other 7" at t = 2. l2.p is resolved early, and no generate
// block in this module is named l2, so the complete hierarchy resolves it to
// the same parameter: not the §12.8.2 error.
//! lrm 6.9.4
//! lrm 6.9.4:1
//! inherited IEEE 1364-2005 12.8.1 12.8.2
`timescale 1ns/1ns
module leaf;
  parameter p = 1, D = 1;
  if (p == 1) begin : a
    initial #D $display("one");
  end else begin : a
    initial #D $display("other %0d", p);
  end
endmodule
module b_12_8_1_defparam_before_generate;
  leaf #(.D(1)) l1();
  leaf #(.D(2)) l2();
  defparam l2.p = 7;
endmodule
