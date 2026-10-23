// IEEE 1364-2005 A.6.9, p. 499:
//   task_enable ::= hierarchical_task_identifier [ ( expression { , expression } ) ] ;
// A.9.3, p. 508: hierarchical_task_identifier ::= hierarchical_identifier
//   hierarchical_identifier ::= { identifier [ [ constant_expression ] ] . } identifier
//
// `c.inc(4)` enables the task inc declared in the instance c: c.m = 4.
// Output: "m=4".
//! inherited IEEE 1364-2005 A.6.9
module b_A_6_9_child;
  integer m;
  task inc(input integer by);
    m = by;
  endtask
endmodule
module b_A_6_9_hierarchical_task_enable;
  b_A_6_9_child c ();
  initial begin
    c.inc(4);
    $display("m=%0d", c.m);
    $finish(0);
  end
endmodule
