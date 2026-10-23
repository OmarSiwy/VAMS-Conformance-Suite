// A falling input at 20 schedules output at 26; a rise at 21 schedules output at 25.
// With on-detect and showcancelled, detecting the negative pulse at 21 immediately gives X.
// The noshowcancelled control remains 1. The sample at 22 precedes both scheduled edges.
//! inherited IEEE 1364-2005 14.6.4 14.6.4.2
`timescale 1ns/1ns
module negative_show_cell(input a,output y);
  assign y=a;
  specify
    pulsestyle_ondetect y; showcancelled y; (a=>y)=(4,6);
  endspecify
endmodule
module negative_hide_cell(input a,output y);
  assign y=a;
  specify
    pulsestyle_ondetect y; noshowcancelled y; (a=>y)=(4,6);
  endspecify
endmodule
module negative_pulse_showcancelled;
  reg a=1; wire shown,hidden;
  negative_show_cell s(a,shown); negative_hide_cell h(a,hidden);
  initial begin
    #20 a=0; #1 a=1; #1 $display("cancelled=%b,%b",shown,hidden);
    #10 $finish(0);
  end
endmodule
