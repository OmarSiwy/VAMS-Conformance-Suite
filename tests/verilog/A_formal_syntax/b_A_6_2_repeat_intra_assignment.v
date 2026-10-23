// IEEE 1364-2005 A.6.2, p. 497:
//   blocking_assignment ::= variable_lvalue = [ delay_or_event_control ] expression
//   nonblocking_assignment ::= variable_lvalue <= [ delay_or_event_control ] expression
// A.6.5, p. 498: delay_or_event_control ::= delay_control | event_control
//   | repeat ( expression ) event_control
//
// clk starts 0 and toggles every 1 ns, so it rises at t1, t3, t5. At t0, a = repeat (2) @(posedge clk) 7 evaluates 7 and
// assigns it after two rising edges, at t3; b <= repeat (3) @(posedge clk) 9
// assigns at t5. Read at t4: a = 7, b not yet (x); at t6: b = 9.
// Output: "a=7 b=x" then "b=9".
//! inherited IEEE 1364-2005 A.6.2
`timescale 1ns/1ns
module b_A_6_2_repeat_intra_assignment;
  reg clk;
  reg [3:0] a, b;
  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end
  initial a = repeat (2) @(posedge clk) 4'd7;
  initial b <= repeat (3) @(posedge clk) 4'd9;
  initial begin
    #4 $display("a=%0d b=%0d", a, b);
    #2 $display("b=%0d", b);
    $finish(0);
  end
endmodule
