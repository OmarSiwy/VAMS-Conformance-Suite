// IEEE 1364-2005 §§4.8, 4.9.2: real/realtime array elements start at zero;
// dimensions may ascend, descend, and use negative bounds. §4.8.2 rounds
// real-to-integer ties away from zero and replaces x/z bits by zero when
// converting an integer to real: 4'b1xz1 therefore becomes 9.0.
//
// The two populated elements are 2.5 and -2.5, giving integers 3 and -3.
// §9.2.2 captures the array target and value when scheduling the NBA, so
// moving i,j afterwards leaves a[2][-1]=6.25 and a[1][0]=-2.5.
// An invalid array write changes no element but still evaluates its RHS;
// bump therefore runs twice. For invalid reads VerA converts §5.2.2's x
// reference through §4.8.2 to +0.0; Vague_Decisions.md records that boundary,
// rather than interpreting an unknown bit-plane as a host NaN.
// A valid element's explicit NaN payload is preserved by §17.8 conversions.
// Legal whole-element reads here neighbor native_real_select_rejected.v.
//! inherited IEEE 1364-2005 4.8 4.8.2 4.9.2 9.2.2
// native-required
`timescale 1ns/1ns
module native_real_arrays;
  real a[2:1][-1:0];
  realtime t[-2:-1];
  integer i, j, p, n, calls;
  function real bump(input integer unused);
    begin calls = calls + 1; bump = 8.5; end
  endfunction
  initial begin
    calls = 0;
    $display("default %.2f %.2f %.2f", a[2][-1], a[1][0], t[-2]);
    i = 2; j = -1; a[i][j] = 2.5; a[1][0] = -2.5;
    t[-2] = 4'b1xz1; t[-1] = -3;
    p = a[i][j]; n = a[1][0];
    $display("convert %0d %0d %.2f %.2f", p, n, t[-2], t[-1]);
    a[i][j] <= #2 a[i][j] + 3.75;
    i = 1; j = 0;
    #3 $display("nba %.2f %.2f", a[2][-1], a[i][j]);
    i = 3; a[i][0] = bump(0);
    $display("outside %.2f", a[i][0]);
    i = 32'bz; a[i][0] = bump(0);
    $display("unknown %.2f", a[i][0]);
    $display("unchanged %0d %.2f %.2f", calls, a[2][-1], a[1][0]);
    t[-1] = $bitstoreal(64'h7ff8000000000001);
    $display("real-bits %h", $realtobits(t[-1]));
    $finish(0);
  end
endmodule
