// With event_based and remain_active both set, late data at t=14 and t=16 each toggle the notifier.
//! inherited IEEE 1364-2005 15.3.2
`timescale 1ns/1ns
module timeskew_active_cell(input clk,input d);
  reg note=0;
  specify $timeskew(posedge clk,d,3,note,1,1); endspecify
endmodule
module timeskew_remain_active;
  reg clk=0,d=0; timeskew_active_cell u(clk,d);
  initial begin
    #10 clk=1; #4 d=1; #1 $display("first=%b",u.note);
    #1 d=0; #1 $display("second=%b",u.note); $finish(0);
  end
endmodule
