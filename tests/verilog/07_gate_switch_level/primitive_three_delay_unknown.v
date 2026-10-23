// IEEE1364-2005 §§7.4/7.14 Table7-9: bufif1 #(5,7,2) uses fall7,
// rise5, turnoff2 and min(5,7,2)=2 for x. Samples avoid update-time races.
//! inherited IEEE 1364-2005 7.4 7.14
`timescale 1ns/1ns
module audit_primitive_three_delay_unknown;
  reg data, enable;
  wire y;
  bufif1 #(5,7,2) g(y, data, enable);
  initial begin
    data = 0; enable = 0;
    #10 enable = 1;
    #6 $display("before_fall=%b", y);
    #2 $display("after_fall=%b", y);
    #2 data = 1;
    #4 $display("before_rise=%b", y);
    #2 $display("after_rise=%b", y);
    data = 1'bx;
    #3 $display("unknown_min_delay=%b", y);
    enable = 0;
    #3 $display("turned_off=%b", y);
    $finish(0);
  end
endmodule
