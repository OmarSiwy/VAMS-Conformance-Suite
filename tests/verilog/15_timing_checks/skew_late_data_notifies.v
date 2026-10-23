// The first separation is 2 <= 3; the second is 5 > 3. Only the second toggles the notifier.
//! inherited IEEE 1364-2005 15.3.1
`timescale 1ns/1ns
module skew_cell(input clk, input d);
  reg note = 0;
  specify $skew(posedge clk, d, 3, note); endspecify
endmodule
module skew_late_data_notifies;
  reg clk=0, d=0;
  skew_cell u(clk,d);
  initial begin
    #10 clk=1; #2 d=1; #2 $display("within=%b",u.note);
    #2 clk=0; #4 clk=1; #5 d=0; #1 $display("late=%b",u.note);
    $finish(0);
  end
endmodule
