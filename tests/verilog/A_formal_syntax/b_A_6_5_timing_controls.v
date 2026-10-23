// IEEE 1364-2005 A.6.5, p. 498-499:
//   delay_control ::= # delay_value | # ( mintypmax_expression )
//   delay_or_event_control ::= delay_control | event_control | repeat ( expression ) event_control
//   disable_statement ::= disable hierarchical_task_identifier ; | disable hierarchical_block_identifier ;
//   event_control ::= @ hierarchical_event_identifier | @ ( event_expression ) | @* | @ (*)
//   event_trigger ::= -> hierarchical_event_identifier { [ expression ] } ;
//   event_expression ::= expression | posedge expression | negedge expression
//     | event_expression or event_expression | event_expression , event_expression
//   procedural_timing_control ::= delay_control | event_control
//   procedural_timing_control_statement ::= procedural_timing_control statement_or_null
//   wait_statement ::= wait ( expression ) statement_or_null
//
// (The repeat form is b_A_6_2_repeat_intra_assignment.v.) Driver, times in ns:
//   #1 a = 1   (# delay_value, a number)
//   #(D) b = 1 (# ( mintypmax_expression ), D = 1: t2)
//   #D c = 1   (# delay_value, an identifier: t3)
//   #1 -> e    (event_trigger: t4)
// Watchers, each counting into its own variable:
//   @(posedge a) : p = 1                     (t1)
//   @(negedge a or b) : o = 1   (a's x -> 0 at t0 is a negedge, and b
//                                 changes at t2: o = 1 either way)
//   @(a, c) twice: w = 2 whichever process §11 runs first at t0. If the
//     watcher is waiting when the driver sets a and c from x at t0, it wakes
//     once for that and once at t1 (a); otherwise it wakes at t1 (a) and t3
//     (c). Either way the driver's zeroing of the counters at t0 precedes
//     every wake-up, since no watcher runs until the driver yields at #1.
//   @e : fe = 1                                (t4)
//   always @* s = a & b;  always @(*) t = b | c: combinational, s = 1, t = 1
//   wait (c) ; then y = 1                      (t3)
//   a task `hang` that waits forever on an event nobody triggers, disabled
//   from outside by `disable hang` at t5 (disable_statement, task form);
//   `disable wblk` ends a named block (block form) before it sets z.
// At t6: "p=1 o=1 w=2 fe=1 s=1 t=1 y=1 h=1 z=0".
//! inherited IEEE 1364-2005 A.6.5
`timescale 1ns/1ns
module b_A_6_5_timing_controls;
  parameter D = 1;
  reg a, b, c;
  reg s, t;
  integer p, o, w, fe, y, h, z;
  event e, never;
  task hang;
    @never h = 0;
  endtask
  initial begin
    a = 0; b = 0; c = 0;
    p = 0; o = 0; w = 0; fe = 0; y = 0; h = 0; z = 0;
    #1 a = 1;
    #(D) b = 1;
    #D c = 1;
    #1 -> e;
  end
  initial @(posedge a) p = 1;
  initial @(negedge a or b) o = 1;
  initial begin
    @(a, c) w = w + 1;
    @(a, c) w = w + 1;
  end
  initial @e fe = 1;
  always @* s = a & b;
  always @(*) t = b | c;
  initial begin
    wait (c) ;
    y = 1;
  end
  initial begin
    hang;
    h = 1;
  end
  initial #5 disable hang;
  initial begin : wblk
    disable wblk;
    z = 1;
  end
  initial #6 begin
    $display("p=%0d o=%0d w=%0d fe=%0d s=%b t=%b y=%0d h=%0d z=%0d", p, o, w, fe, s, t, y, h, z);
    $finish(0);
  end
endmodule
