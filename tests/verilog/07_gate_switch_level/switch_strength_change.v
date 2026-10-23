//! inherited IEEE 1364-2005 7.10 7.11
// When a switch's data input changes strength only (St1 to Pu1), its output
// follows: the pmos output Pu1 against bufif0's St0 resolves 0, not x
// (resolv1).
module triage_switch_strength_change;
  wire w;
  wire q;
  reg g;

  pullup(w);
  bufif1(w, 1'b1, g);
  pmos(q, w, 1'b0);
  bufif0(q, 1'b0, g);

  initial begin
    g = 1;
    #10 $display("t10 %b %b", q, w);
    g = 0;
    #10 $display("t20 %b %b", q, w);
    if (q === 1'b0) $display("PASSED"); else $display("FAILED");
  end
endmodule
