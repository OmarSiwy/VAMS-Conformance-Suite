//! inherited IEEE 1364-2005 3.5.1 9.7.1
// A size and 'base are separate tokens: `#1 'h123` is delay 1 then the
// unsized constant 'h123, not the sized constant 1'h123 (const4).
module triage_delay_then_unsized_constant;
  reg [31:0] i;

  initial begin
    i = #1 'h123;
    #100;
    if (i == 32'h123)
      $display("PASSED");
    else
      $display("FAILED %0h", i);
  end
endmodule
