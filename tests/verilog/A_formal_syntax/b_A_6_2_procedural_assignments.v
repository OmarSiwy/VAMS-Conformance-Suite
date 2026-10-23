// IEEE 1364-2005 A.6.2, p. 497:
//   initial_construct ::= initial statement
//   always_construct ::= always statement
//   blocking_assignment ::= variable_lvalue = [ delay_or_event_control ] expression
//   nonblocking_assignment ::= variable_lvalue <= [ delay_or_event_control ] expression
//   procedural_continuous_assignments ::= assign variable_assignment
//     | deassign variable_lvalue | force variable_assignment | force net_assignment
//     | release variable_lvalue | release net_lvalue
//   variable_assignment ::= variable_lvalue = expression
//
// (The repeat form of delay_or_event_control is b_A_6_2_repeat_intra_assignment.v.)
// always: on every posedge clk, cnt <= cnt + 1 (nonblocking, no control).
// initial, times in ns:
//   t0: clk = 0, cnt = 0; a = #2 5: the right side is evaluated at t0, a = 5 at t2.
//   t2: b = @(posedge clk) a + 1: evaluated at t2 (6), assigned when clk
//       next rises, t3 (another initial raises it); cnt -> 1 at t3.
//   t4: c <= #1 b * 2: 12, landing at t5.
//   t5: assign r = 4'd9 (procedural continuous); r = 1 has no effect while
//       it holds -> r = 9; deassign r; r = 2 -> r = 2.
//       force w = 1'b1 on the net w (driven 0 by assign): w = 1; release w:
//       w = 0, its driver's value again. force v = 4'd7 on the variable v,
//       then release v: v keeps 7 (§9.3.2, p. 124: "The variable shall
//       maintain its current value until the next procedural assignment").
//       Each value is read after #0, once the statement before it has taken
//       effect.
//   t6: a, b, c and cnt, c's nonblocking update long landed.
// Output: "r=9 r=2 w=1 w=0 v=7" then "a=5 b=6 c=12 cnt=1".
//! inherited IEEE 1364-2005 A.6.2
`timescale 1ns/1ns
module b_A_6_2_procedural_assignments;
  reg clk;
  reg [3:0] a, b, c, cnt, r, v;
  wire w;
  assign w = 1'b0;
  always @(posedge clk) cnt <= cnt + 1;
  initial #3 clk = 1;
  initial begin
    clk = 0;
    cnt = 0;
    a = #2 4'd5;
    b = @(posedge clk) a + 1;
    #1 c <= #1 b * 2;
    #1;
    assign r = 4'd9;
    r = 4'd1;
    #0 $write("r=%0d ", r);
    deassign r;
    r = 4'd2;
    #0 $write("r=%0d ", r);
    force w = 1'b1;
    #0 $write("w=%b ", w);
    release w;
    #0 $write("w=%b ", w);
    force v = 4'd7;
    #0 release v;
    #0 $display("v=%0d", v);
    #1 $display("a=%0d b=%0d c=%0d cnt=%0d", a, b, c, cnt);
    $finish(0);
  end
endmodule
