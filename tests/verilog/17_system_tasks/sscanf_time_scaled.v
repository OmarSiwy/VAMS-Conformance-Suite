//! inherited IEEE 1364-2005 17.2.4.3 17.3.2
// $sscanf %t reads a time scaled by $timeformat into the module's units;
// "8.125" with -3 units and 2 decimals is 8.13ms = 8,130,000ns (scanf2).
`timescale 1ns/100ps
module triage_sscanf_time_scaled;
  real x;
  time x_int;
  integer rc;

  initial begin
    $timeformat(-3, 2, "ms", 10);
    rc = $sscanf("8.125", "%t", x);
    x_int = x;
    if (rc === 1 && x_int == 8130000)
      $display("PASSED");
    else
      $display("FAILED %0d", x_int);
  end
endmodule
