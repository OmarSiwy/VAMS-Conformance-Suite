//! inherited IEEE 1364-2005 3.5.1
// An unsized constant is at least 32 bits; 4294967312 is a legal delay and
// must not truncate to 16 (pr1388974).
module triage_unsized_wide_constant;
  initial begin
    # 4294967312 $display("FAILED -- time=%d", $time);
    $finish(0);
  end

  initial begin
    # 32 $display("PASSED");
    $finish(0);
  end
endmodule
