//! inherited IEEE 1364-2005 19.2
// `default_nettype uwire is legal: the implicit net below is a uwire with one
// driver.
`default_nettype uwire
module triage_default_nettype_uwire;
  assign uw = 1'b0;

  initial #1 if (uw === 1'b0) $display("PASSED"); else $display("FAILED %b", uw);
endmodule
