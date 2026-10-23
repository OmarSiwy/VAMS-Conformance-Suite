// IEEE 1364-2005 9.2.2; VAMS-2023 8.5.3.4: both the right-hand value and
// left-hand target are determined when the NBA is queued, not when it lands.
// At t0: bits=0000, index=0, value=1. Queue bits[0]=1 at t3; then change
// index to 2 and value to 0. t1 remains 0000; t4 must be 0001. A late index
// gives 0100, a late RHS gives 0000, an immediate write changes the t1 check.
// At t4 queue bits[2]=1 at t7, then change index to 1 and value to 0.
// At t8 bits must be 0101, retaining the first independent bit update.
// All observations are separated from NBA delivery times, so there is no
// dependency on active-region process ordering or monitor formatting.
//! lrm 8.5.3.4
//! lrm 8.5.3.4:1000
//! inherited IEEE 1364-2005 9.2.2 11.6.4
`timescale 1ns/1ns
module audit_nba_index_snapshot;
  reg [3:0] bits;
  integer index;
  reg value;
  initial begin
    bits = 4'b0000;
    index = 0;
    value = 1'b1;
    bits[index] <= #3 value;
    index = 2;
    value = 1'b0;
    #1 $display("t1 bits=%b", bits);
    #3 $display("t4 bits=%b", bits);
    value = 1'b1;
    bits[index] <= #3 value;
    index = 1;
    value = 1'b0;
    #4 $display("t8 bits=%b", bits);
    $finish(0);
  end
endmodule
