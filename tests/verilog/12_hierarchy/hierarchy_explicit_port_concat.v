// IEEE1364-2005 12.3.2 and 12.3.6: explicit external name can associate
// a concatenation of internal ports. Input1001 splits a=10,b=01;
// output {b,a}=0110. The named connection uses joined, not a or b.
//! inherited IEEE 1364-2005 12.3.2
//! inherited IEEE 1364-2005 12.3.6
`timescale 1ns/1ps
module audit_hierarchy_explicit_port_concat;
  wire [3:0] result;
  audit_explicit_child u(.joined(4'b1001),.out(result));
  initial begin
    #1;
    $display("swapped=%b",result);
    $finish(0);
  end
endmodule
module audit_explicit_child(.joined({a,b}),out);
  input [1:0] a,b;
  output [3:0] out;
  assign out={b,a};
endmodule
