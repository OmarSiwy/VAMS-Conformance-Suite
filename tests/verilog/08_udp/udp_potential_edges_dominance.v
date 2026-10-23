// IEEE1364-2005 Table8-1: p covers01/0x/x1; n covers10/1x/x0.
// Input z is x (8.1.5). Edge rows set1/0, but level gate0 forces0 even
// during p (8.7/8.8 level dominance). gatex explicitly yieldsx.
// One input changes per stimulus; no simultaneous-edge scheduling is assumed.
//! lrm A.5.3
//! lrm A.5.3:1000
//! inherited IEEE 1364-2005 8.1.5,8.1.6,8.4,8.7,8.8
`timescale 1ns/1ns
primitive audit_edges_udp(q, clock, gate);
  output q;
  reg q;
  input clock, gate;
  initial q = 0;
  table
    p ? : ? : 1;
    n ? : ? : 0;
    ? 0 : ? : 0;
    ? x : ? : x;
  endtable
endprimitive
module audit_udp_potential_edges_dominance;
  reg clock, gate;
  wire q;
  audit_edges_udp dut(q, clock, gate);
  initial begin
    #1 gate = 1;
    #1 clock = 0;
    #1 $display("x0=%b", q);
    clock = 1'bz;
    #1 $display("0z=%b", q);
    clock = 1;
    #1 $display("z1=%b", q);
    clock = 1'bx;
    #1 $display("1x=%b", q);
    clock = 0;
    #1 gate = 0;
    #1 clock = 1;
    #1 $display("01-disabled=%b", q);
    $finish(0);
  end
endmodule
