// IEEE1364-2005 §17.7.1, Syntax17-14, physical339–340.
// This time query takes no arguments. A supplied value cannot select another
// time; use the matching no-argument calls in the time-query positive fixtures.
// This file contains only one invalid call, independently of the other queries.
//! lrm 9.10
//! inherited IEEE 1364-2005 17.7.1
//! reject take no arguments

module audit_time_argument_rejected;
  initial begin
    $display("%0d", $time(1));
    $finish(0);
  end
endmodule
