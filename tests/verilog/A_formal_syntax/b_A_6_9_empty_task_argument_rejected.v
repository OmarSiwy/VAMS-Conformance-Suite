// IEEE 1364-2005 A.6.9, p. 499:
//   system_task_enable ::= system_task_identifier [ ( [ expression ] { , [ expression ] } ) ] ;
//   task_enable ::= hierarchical_task_identifier [ ( expression { , expression } ) ] ;
// A system task's arguments may be empty ([ expression ]); a user task's
// may not (every expression is required).
//
// `add(2, )` leaves a user task argument empty. Legal neighbour:
// b_A_6_9_task_enables.v (`add(2, 3)`, and `$display("a", , "b")` for the
// empty system task argument).
//! lrm A.6.9
//! lrm A.6.9:1000
//! inherited IEEE 1364-2005 A.6.9
//! reject E1100
//! reject null task arguments are not permitted
//! neighbour b_A_6_9_task_enables.v
module b_A_6_9_empty_task_argument_rejected;
  integer n;
  task add(input integer x, input integer y);
    n = x + y;
  endtask
  initial begin
    add(2, );
    $display("unreachable");
  end
endmodule
