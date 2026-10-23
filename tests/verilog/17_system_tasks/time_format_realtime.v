//! inherited IEEE 1364-2005 17.1.1.2 17.3.2
// %t of $realtime 0.6 in a 1ns/1ps module is 600 in the default unit (the
// simulation precision); VerA rounds the real to 1ns and prints 1000
// (pr1985582).
`timescale 1ns/1ps
module triage_time_format_realtime;
  initial begin
    #0.6;
    $display("[%t]", $realtime);
  end
endmodule
