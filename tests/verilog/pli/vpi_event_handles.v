`timescale 1ns/1ns
module audit_vpi_event_handles;
  reg a,b;
  reg [1:0] c;
  initial #10 $finish(0);
endmodule
