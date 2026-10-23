// IEEE1364-2005 17.3.2 specifies integer settings, not constant expressions.
// Evaluate settings when the task is invoked; this does not request tracking.
// At2ns with settings(-9,1,"ns",0), literal2 ->2.0ns.
// Changing variable precision alone cannot change the installed setting;
// reinvoking with precision2 then gives2.00ns.
//! lrm 9.6
//! lrm 9.6:1000
//! inherited IEEE 1364-2005 17.3.2
//! expect stdout timeformat_runtime_arguments.expected.txt
`timescale 1ns/1ps
module audit_timeformat_runtime_arguments;
  integer unit_code, precision, width;
  initial begin
    unit_code = -9;
    precision = 1;
    width = 0;
    $timeformat(unit_code, precision, "ns", width);
    $display("[%t]", 2);
    precision = 2;
    $display("[%t]", 2);
    $timeformat(unit_code, precision, "ns", width);
    $display("[%t]", 2);
    $finish(0);
  end
endmodule
