// IEEE 1364-2005 §9.7.2 detects changes of the event expression's value,
// not every change of its operands; an edge examines the expression's LSB.
// §5.2.2 gives m[i][b +:2] the same packed-select rules as a vector.
// §9.7.5 @* includes the array and both indices. The continuous assignment
// (§6.1) and @* block must both track changes, under either native scheduler.
//
// Starting with m[0]=00, m[1]=0a, i=b=0, the selected values after each
// write are 2,3,3,1,1,2,0. Thus change counts are 1,2,2,3,3,4,5, and
// posedge counts are 0,1,1,1,1,1,1. Changing m[0][7] is irrelevant;
// changing i from 0 to 1 at base 1 keeps the selected value 1. The final
// m[1][1:0]=0 changes 2 to 0 but leaves the LSB zero. Displays run a tick
// after each update, avoiding active-region races with the observers.
// There is no invalid event value here; select syntax rejections live in
// ch05's native_select_*_rejected and b_5_2_2_partial_address_rejected.
//! inherited IEEE 1364-2005 5.2.2 6.1 9.7.2 9.7.5
// native-required
// native-state: 2
`timescale 1ns/1ns
module native_select_events;
  reg [7:0] m[0:1];
  integer i, b, changes, rises, active;
  wire [1:0] driven;
  reg [1:0] star;
  assign driven = m[i][b +: 2];
  always @* star = m[i][b +: 2];
  always @(m[i][b +: 2]) if (active) changes = changes + 1;
  always @(posedge m[i][b +: 2]) if (active) rises = rises + 1;
  initial begin
    active = 0; changes = 0; rises = 0; i = 0; b = 0;
    m[0] = 0; m[1] = 8'h0a;
    #1 active = 1;
    m[0][1] = 1;
    #1 $display("%d %d %h %h", changes, rises, driven, star);
    m[0][0] = 1;
    #1 $display("%d %d %h %h", changes, rises, driven, star);
    m[0][7] = 1;
    #1 $display("%d %d %h %h", changes, rises, driven, star);
    b = 1;
    #1 $display("%d %d %h %h", changes, rises, driven, star);
    i = 1;
    #1 $display("%d %d %h %h", changes, rises, driven, star);
    b = 0;
    #1 $display("%d %d %h %h", changes, rises, driven, star);
    m[1][b +: 2] = 0;
    #1 $display("%d %d %h %h", changes, rises, driven, star);
    $finish(0);
  end
endmodule
