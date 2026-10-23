// An event-based skew check cannot fire while no data event occurs; a late data event then toggles it.
//! inherited IEEE 1364-2005 15.3.1
`timescale 1ns/1ns
module skew_wait_cell(input clk,input d);
  reg note=0;
  specify $skew(posedge clk,d,3,note); endspecify
endmodule
module skew_waits_for_data_event;
  reg clk=0,d=0; skew_wait_cell u(clk,d);
  initial begin
    #10 clk=1; #20 $display("no_data=%b",u.note);
    d=1; #1 $display("late_data=%b",u.note); $finish(0);
  end
endmodule
