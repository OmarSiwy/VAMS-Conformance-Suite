// Without an option enabling negative timing checks, the delayed arguments must still copy the original signals.
//! inherited IEEE 1364-2005 15.5.4
`timescale 1ns/1ns
module negative_copy_cell(input clk,input d,output delayed_clk,output delayed_d);
  reg note=0;
  specify $setuphold(posedge clk,d,-2,5,note,,,delayed_clk,delayed_d); endspecify
endmodule
module negative_timing_disabled_copies_signals;
  reg clk=0,d=0; wire dc,dd;
  negative_copy_cell u(clk,d,dc,dd);
  initial begin
    #10 begin clk=1; d=1; end
    #1 $display("copies=%b,%b",dc,dd);
    #1 begin clk=0; d=0; end
    #1 $display("copies=%b,%b",dc,dd); $finish(0);
  end
endmodule
