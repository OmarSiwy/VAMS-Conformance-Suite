//! inherited IEEE 1364-2005 9.7.1 19.8
// A real-valued parameter delay is scaled into the time unit: Delay = 0.1 in
// 1ns/1ps is 100ps, not zero (br_gh732).
`timescale 1ns/1ps
module triage_real_parameter_delay;
  parameter real Delay = 0.1;
  reg a;
  wire x, y;

  assign x = a;
  assign #Delay y = a;

  initial begin
    a = 1'b0;
    #1;
    a = 1'b1;
    #0.05;
    if (y !== 1'b0) $display("FAILED too early y=%b", y);
    else begin
      #0.06;
      if (y !== 1'b1) $display("FAILED too late y=%b", y);
      else $display("PASSED");
    end
  end
endmodule
