// IEEE 1364-2005 §9.2 evaluates the right-hand-side expression of a
// procedural assignment. §5.2.1's out-of-range/x select prevents the write,
// not that evaluation; §5.2.2 applies this to packed array-element selects.
// Under §9.2.2 an NBA evaluates its RHS when encountered, not when deposited.
//
// Every bump call increments calls once and returns a. The first seven
// targets have no valid selected storage, so calls=7 while v and both m
// words stay 00. The partial write uses a's low pair 10 at v[7:6], giving
// 80 with calls=8. The delayed NBA evaluates bump immediately (calls=9),
// then writes a to m[1][5:2] at t=2 (28), despite later index changes.
// The function does not modify any index, avoiding an unspecified ordering
// between LHS and RHS evaluations. Width-invalid neighbours are in ch05.
//! inherited IEEE 1364-2005 5.2.1 5.2.2 9.2 9.2.2
// native-required
`timescale 1ns/1ns
module native_select_assignment_effects;
  reg [7:0] v, m[0:1];
  integer calls, b, i;
  function [3:0] bump;
    input ignored;
    begin calls = calls + 1; bump = 4'ha; end
  endfunction
  initial begin
    calls = 0; v = 0; m[0] = 0; m[1] = 0;
    b = 32'bx; i = 32'bx;
    v[b +: 4] = bump(0);
    m[i][0 +: 4] = bump(0);
    m[0][b +: 4] = bump(0);
    m[i] = bump(0);
    v[100 +: 4] = bump(0);
    m[7][3:0] <= bump(0);
    v[b] <= bump(0);
    $display("ignored %0d %h %h %h", calls, v, m[0], m[1]);
    b = 6; v[b +: 4] = bump(0);
    i = 1; b = 2; m[i][b +: 4] <= #2 bump(0);
    i = 0; b = 0;
    $display("scheduled %0d", calls);
    #3 $display("stored %0d %h %h %h", calls, v, m[0], m[1]);
    $finish(0);
  end
endmodule
