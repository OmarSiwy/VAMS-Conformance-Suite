//! event-budget 1000
//! inherited IEEE 1364-2005 9.9.2 11.4
// An always with no timing control is a zero-delay loop, not a compile
// error; the initial runs first and finishes (always3.1.1B).
module triage_zero_delay_always_finishes;
  reg [3:0] value1;

  initial begin
    if (value1 != 4'b1)
      $display("FAILED");
    else
      $display("PASSED");
    $finish(0);
  end

  always value1 = 1'b1 && 1'b1;
endmodule
