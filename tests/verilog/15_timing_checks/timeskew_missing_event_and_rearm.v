// No data after t=10 expires the timer. Data at t=22 satisfies the rearmed timer; later data cannot retrigger a dormant check.
//! inherited IEEE 1364-2005 15.3.2
`timescale 1ns/1ns
module timeskew_cell(input clk,input d);
  reg note=0;
  specify $timeskew(posedge clk,d,3,note); endspecify
endmodule
module timeskew_missing_event_and_rearm;
  reg clk=0,d=0; timeskew_cell u(clk,d);
  initial begin
    #10 clk=1; #5 $display("missing=%b",u.note);
    #1 clk=0; #4 clk=1; #2 d=1;
    #3 $display("in_time=%b",u.note);
    #5 d=0; #1 $display("dormant=%b",u.note); $finish(0);
  end
endmodule
