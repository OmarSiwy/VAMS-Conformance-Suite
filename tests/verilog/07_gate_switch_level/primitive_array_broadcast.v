// IEEE1364-2005 §§7.1.5–7.1.6: nonzero instance-array bounds are legal;
// scalar control broadcasts to every instance, vector terminals partition.
// Both ascending and descending instance ranges must implement the same
// vector buffer when input/output vector orders match.
//! inherited IEEE 1364-2005 7.1.5 7.1.6
`timescale 1ns/1ns
module audit_primitive_array_broadcast;
  reg [3:0] data;
  reg enable;
  wire [3:0] ascending, descending;
  bufif1 up[4:7](ascending, data, enable);
  bufif1 down[7:4](descending, data, enable);
  initial begin
    data = 4'b1010; enable = 1;
    #1 $display("enabled=%b,%b", ascending, descending);
    enable = 0;
    #1 $display("disabled=%b,%b", ascending, descending);
    data = 4'b0101; enable = 1;
    #1 $display("changed=%b,%b", ascending, descending);
    $finish(0);
  end
endmodule
