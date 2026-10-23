//! inherited IEEE 1364-2005 4.11
// 1364-2005 has no general declare-before-use rule: v is a module-scope reg
// even though its declaration follows the initial block that assigns it
// (decl_before_use1).
module triage_forward_reference_reg;
  initial begin
    v = 1;
    if (v === 1) $display("PASSED"); else $display("FAILED %b", v);
  end

  reg v;
endmodule
