//! inherited IEEE 1364-2005 5.1.13
// An x/z condition over z and z gives x, not z (pr2172606b).
module triage_conditional_z_select;
  reg sel;
  wire out;

  assign out = sel ? 1'bz : 1'bz;

  initial begin
    sel = 1'bx;
    #1 if (out === 1'bx) $display("PASSED"); else $display("FAILED %b", out);
  end
endmodule
