//! inherited IEEE 1364-2005 4.5 4.11
//! reject-only duplicate digital variable
// assign w = 1; before any declaration of w implies a scalar net, so the
// later wire [7:0] w; redeclares it (decl_before_use2), which the engine's
// duplicate-binding check owns. VerA instead binds the assign to the later
// 8-bit wire; the fixture is expected to FAIL, verifying the vera-bug claim.
module triage_assign_before_net_declaration_rejected;
  assign w = 1;

  initial $display("%b", w);

  wire [7:0] w;
endmodule
