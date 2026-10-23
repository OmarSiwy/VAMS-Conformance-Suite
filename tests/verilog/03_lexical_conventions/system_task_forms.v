// IEEE 1364-2005 §3.7.3, p. 15: "The dollar sign ($) introduces a language
// construct that enables development of user-defined system tasks and
// functions. ... A name following the $ is interpreted as a system task or a
// system function." Syntax 3-2: system_task_enable ::=
// system_task_identifier [ ( [ expression ] { , [ expression ] } ) ] ;
// system_function_call ::= system_function_identifier
// [ ( expression { , expression } ) ]; the identifier is
// $[ a-zA-Z0-9_$ ]{ [ a-zA-Z0-9_$ ] }.
//
// The clause's example: $display ("display a message"); (white space between
// the name and its parenthesis is ordinary token separation) prints
// "display a message".
// A system function with no argument list: $time at time 0 -> 0.
// With arguments: $signed(4'b1111) -> -1.
// An empty argument ( [ expression ] left out): §17.1.1 p. 278, "Any null
// argument produces a single space character in the display" -> "a b".
// A task enable with no argument list, as the clause's $finish;:
// $monitoroff; (§17.1.3), which prints nothing. $finish; itself is not used:
// its default argument 1 prints the simulation time and location (§17.4.1),
// which depend on the run. $finish(0) ends the run silently.
// Printed: "display a message", "0 -1", "a b".
//! inherited IEEE 1364-2005 3.7.3
module b_3_7_3_system_task_forms;
  initial begin
    $display ("display a message");
    $display("%0d %0d", $time, $signed(4'b1111));
    $display("a",,"b");
    $monitoroff;
    $finish(0);
  end
endmodule
