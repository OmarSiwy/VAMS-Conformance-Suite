// IEEE 1364-2005 A.6.9, p. 499:
//   system_task_enable ::= system_task_identifier [ ( [ expression ] { , [ expression ] } ) ] ;
//   task_enable ::= hierarchical_task_identifier [ ( expression { , expression } ) ] ;
//
// System task enables: `$write;` with no parentheses (prints nothing), and
// `$display("a", , "b")` whose middle argument is empty. §17.1.1, p. 278
// (quoted for context): "Any null argument produces a single space character
// in the display. (A null argument is characterized by two adjacent commas in
// the argument list.)" So it prints "a b".
// Task enables: `tick;` with no arguments and `add(2, 3)` with two (a
// hierarchical task name is b_A_6_9_hierarchical_task_enable.v).
// tick: n = n + 1 -> 1; add: n = n + 2 + 3 -> 6.
// Output: "a b" then "n=6".
//! inherited IEEE 1364-2005 A.6.9
module b_A_6_9_task_enables;
  integer n;
  task tick;
    n = n + 1;
  endtask
  task add(input integer x, input integer y);
    n = n + x + y;
  endtask
  initial begin
    n = 0;
    $write;
    $display("a", , "b");
    tick;
    add(2, 3);
    $display("n=%0d", n);
    $finish(0);
  end
endmodule
