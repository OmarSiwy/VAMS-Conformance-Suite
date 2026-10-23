// IEEE1364-2005 17.3.2 Syntax17-10 permits the argumentless task.
// Table17-11 defaults: global finest precision1ps, fractional digits0,
// empty suffix and width20. Literal2 in this module means2ns=2000ps;
// four digits require sixteen leading spaces. Call before any custom format.
//! lrm 9.6
//! inherited IEEE 1364-2005 17.3.2
//! expect stdout timeformat_default_call.expected.txt
`timescale 1ns/1ps
module audit_timeformat_default_call;
  initial begin
    $timeformat;
    $display("[%t]", 2);
    $finish(0);
  end
endmodule
