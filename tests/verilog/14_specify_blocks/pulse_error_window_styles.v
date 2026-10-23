// Input pulse [20,24] schedules output edges [30,34]. Width 4 lies between reject 2 and error 5.
// On-detect enters X at 24; on-event enters X at 30. Both return to 0 at 34.
//! inherited IEEE 1364-2005 14.6 14.6.1 14.6.4 14.6.4.1
`timescale 1ns/1ns
module pulse_event_cell(input a,output y);
  assign y=a;
  specify
    specparam PATHPULSE$=(2,5);
    pulsestyle_onevent y;
    (a=>y)=10;
  endspecify
endmodule
module pulse_detect_cell(input a,output y);
  assign y=a;
  specify
    specparam PATHPULSE$=(2,5);
    pulsestyle_ondetect y;
    (a=>y)=10;
  endspecify
endmodule
module pulse_error_window_styles;
  reg a=0; wire event_y,detect_y;
  pulse_event_cell e(a,event_y); pulse_detect_cell d(a,detect_y);
  initial begin
    #20 a=1; #4 a=0;
    #1 $display("detect=%b,%b",event_y,detect_y);
    #6 $display("event=%b,%b",event_y,detect_y);
    #4 $display("settled=%b,%b",event_y,detect_y); $finish(0);
  end
endmodule
