// IEEE1364-2005 §§11.6.1/11.6.6: constant explicit and implicit port
// assignments evaluate at time0. #0 observes after active propagation, still
// at time0; no operand changes can rescue a missing initial evaluation.
//! inherited IEEE 1364-2005 11.6.1 11.6.6
`timescale 1ns/1ns
module audit_sched_constant_ports;
  wire [3:0] direct, through_port;
  assign direct = 4'b1010;
  audit_sched_constant_child c(4'b0110, through_port);
  initial begin
    #0 $display("t=%0d direct=%b port=%b", $time, direct, through_port);
    #1 $finish(0);
  end
endmodule
module audit_sched_constant_child(input [3:0] a, output [3:0] y);
  assign y = a ^ 4'b0011;
endmodule
