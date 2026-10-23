// IEEE 1364-2005 §9.2.1 evaluates the blocking assignment's lvalue at
// its intra-assignment control time. §9.7.7 evaluates the RHS before that
// delay. Here choose sets i=1,b=4 and returns a at t=0; t=2 therefore
// writes m[1][7:4], making m[1]=a0 while m[0]=00. The RHS ran once.
//
// §9.2.2 explicitly leaves evaluation order between an NBA lvalue and RHS
// undefined when there is no timing control. In the second assignment,
// choose changes b from 0 to 4. Either the old low nibble or new high nibble
// can receive a: 0a and a0 are both legal. The verdict asserts that set,
// never a particular implementation's order. The RHS still runs once.
// A legal effectful RHS needs no fabricated rejection; indexed-width
// rejection neighbours are native_select_*_rejected.v in ch05.
//! inherited IEEE 1364-2005 5.2.2 9.2.1 9.2.2 9.7.7
// native-required
`timescale 1ns/1ns
module native_select_timing;
  reg [7:0] m[0:1], v;
  integer i, b, calls;
  function [3:0] choose;
    input ignored;
    begin i = 1; b = 4; calls = calls + 1; choose = 4'ha; end
  endfunction
  initial begin
    i = 0; b = 0; calls = 0; m[0] = 0; m[1] = 0; v = 0;
    m[i][b +: 4] = #2 choose(0);
    $display("blocking %0t %h %h %0d", $time, m[0], m[1], calls);
    b = 0;
    v[b +: 4] <= choose(0);
    #1 $display("nba-order %0d %b", calls, (v === 8'h0a) || (v === 8'ha0));
    $finish(0);
  end
endmodule
