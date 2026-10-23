// IEEE1364-2005 19.8: round each delay to local precision before scheduling.
// Unit10ns/precision1ns: each0.26-unit delay is2.6ns rounded to3ns.
// Repeated delays occur at3ns and6ns, not at rounded accumulated5.2ns=5ns.
// $realtime is in module units, giving0.3 then0.6; no midpoint tie is used.
//! lrm 9.6
//! lrm 9.10
//! inherited IEEE 1364-2005 19.8,17.7.3
//! expect stdout timescale_delay_round_each.expected.txt
`timescale 10ns/1ns
module audit_timescale_delay_round_each;
  initial begin
    #0.26 $display("first=%g", $realtime);
    #0.26 $display("second=%g", $realtime);
    $finish(0);
  end
endmodule
