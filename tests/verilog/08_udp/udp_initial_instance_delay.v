// IEEE1364-2005 8.5: a UDP instance delay does not postpone its initial value.
// The declared state1 must be visible at t1, before the instance delay5.
// Inputs remain untouched x; no input transition requests a table update.
//! lrm A.5.3
//! lrm A.5.4
//! lrm A.5.3:1000
//! lrm A.5.4:1000
//! inherited IEEE 1364-2005 8.5
`timescale 1ns/1ns
primitive audit_initial_udp(q, clock, data);
  output q;
  reg q;
  input clock, data;
  initial q = 1'b1;
  table
    r 0 : ? : 0;
    r 1 : ? : 1;
  endtable
endprimitive
module audit_udp_initial_instance_delay;
  reg clock, data;
  wire q;
  audit_initial_udp #5 dut(q, clock, data);
  initial begin
    #1 $display("before-delay=%b", q);
    $finish(0);
  end
endmodule
