// IEEE1364-2005 12.3.11: signedness is local to each side of a port.
// Both parents provide ff bits. Signed child sees -1 (<0); unsigned child
// sees 255 (not <0), irrespective of the opposite parent declaration.
//! inherited IEEE 1364-2005 12.3.11
`timescale 1ns/1ps
module audit_hierarchy_port_signedness;
  wire [7:0] parent_unsigned = 8'hff;
  wire signed [7:0] parent_signed = 8'hff;
  wire signed_negative, unsigned_negative;
  audit_signed_child a(parent_unsigned,signed_negative);
  audit_unsigned_child b(parent_signed,unsigned_negative);
  initial begin
    #1;
    $display("signed=%d unsigned=%d",signed_negative,unsigned_negative);
    $finish(0);
  end
endmodule
module audit_signed_child(input signed [7:0] value, output negative);
  assign negative = value < 0;
endmodule
module audit_unsigned_child(input [7:0] value, output negative);
  assign negative = value < 0;
endmodule
