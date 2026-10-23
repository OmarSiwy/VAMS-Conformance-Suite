// IEEE 1364-2005 A.6.4, p. 498:
//   statement ::= { attribute_instance } blocking_assignment ;
//     | { attribute_instance } case_statement
//     | { attribute_instance } conditional_statement
//     | { attribute_instance } disable_statement
//     | { attribute_instance } event_trigger
//     | { attribute_instance } loop_statement
//     | { attribute_instance } nonblocking_assignment ;
//     | { attribute_instance } par_block
//     | { attribute_instance } procedural_continuous_assignments ;
//     | { attribute_instance } procedural_timing_control_statement
//     | { attribute_instance } seq_block
//     | { attribute_instance } system_task_enable
//     | { attribute_instance } task_enable
//     | { attribute_instance } wait_statement
//   statement_or_null ::= statement | { attribute_instance } ;
//   function_statement ::= statement
//
// One of each alternative (attribute instances: b_A_9_1_attributes.v), in
// order, with integer n counting what ran:
//   n = 1 (blocking); case (n) 1: n = n + 1 -> 2; if (n == 2) n = n * 2 -> 4;
//   a named block `blk` whose second statement is `disable blk`, so its third
//   (n = 0) never runs; -> go wakes the always block, which sets m = 1;
//   repeat (3) n = n + 1 -> 7; n <= n + 1 (nonblocking, lands in the NBA
//   region: 8); fork #1 k = 1; join (par_block, timing control statement);
//   assign/deassign q (procedural continuous); begin end (seq_block);
//   $write (system_task_enable); bump (task_enable: n = n + 10 -> 18);
//   wait (m) ; (wait_statement with a null statement_or_null);
//   dbl(n) inside a function whose function_statement is a blocking
//   assignment: 36.
// The always block reached @(go) at t0 in the active region, and -> go runs
// after `#0`, in the inactive region, so it is already waiting.
// Output: "go n=36 m=1 k=1 q=5".
//! inherited IEEE 1364-2005 A.6.4
`timescale 1ns/1ns
module b_A_6_4_statements;
  integer n, m, k;
  reg [3:0] q;
  event go;
  task bump;
    n = n + 10;
  endtask
  function integer dbl(input integer v);
    dbl = v * 2;
  endfunction
  always @(go) m = 1;
  initial begin
    n = 1;
    case (n)
      1: n = n + 1;
    endcase
    if (n == 2) n = n * 2;
    begin : blk
      n = n;
      disable blk;
      n = 0;
    end
    #0 -> go;
    repeat (3) n = n + 1;
    n <= n + 1;
    fork
      #1 k = 1;
    join
    assign q = 4'd5;
    #0 deassign q;
    begin
    end
    $write("go ");
    bump;
    wait (m) ;
    n = dbl(n);
    $display("n=%0d m=%0d k=%0d q=%0d", n, m, k, q);
    $finish(0);
  end
endmodule
