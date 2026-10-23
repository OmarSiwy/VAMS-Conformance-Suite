// IEEE1364-2005 8.1.4: table inputs follow header order, NOT declaration order.
// Header first,second; declarations reversed. Table01->1 and10->0 therefore
// distinguishes the orders. Missing00/unknown combinations default to x.
//! lrm A.5.1
//! lrm A.5.3
//! lrm A.5.1:1000
//! lrm A.5.2
//! lrm A.5.2:1000
//! inherited IEEE 1364-2005 8.1.4,8.2
`timescale 1ns/1ns
primitive audit_header_udp(out, first, second);
  output out;
  input second, first;
  table
    0 1 : 1;
    1 0 : 0;
  endtable
endprimitive
module audit_udp_header_order;
  reg a, b;
  wire y;
  audit_header_udp dut(y, a, b);
  initial begin
    a = 0; b = 1;
    #1 $display("01=%b", y);
    a = 1; b = 0;
    #1 $display("10=%b", y);
    a = 0;
    #1 $display("00=%b", y);
    a = 1'bz;
    #1 $display("z0=%b", y);
    $finish(0);
  end
endmodule
