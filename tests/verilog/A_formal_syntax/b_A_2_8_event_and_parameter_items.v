// IEEE 1364-2005 A.2.8, p. 493:
//   block_item_declaration ::= ...
//     | { attribute_instance } event_declaration
//     | { attribute_instance } local_parameter_declaration ;
//     | { attribute_instance } parameter_declaration ;
//
// A task's block items: event e, localparam L = 2, parameter P = 3. The task
// computes L + P = 5 and triggers e (nothing waits on it).
// Output: "s=5".
//! inherited IEEE 1364-2005 A.2.8
module b_A_2_8_event_and_parameter_items;
  task run ();
    event e;
    localparam L = 2;
    parameter P = 3;
  begin
    -> e;
    $display("s=%0d", L + P);
  end
  endtask
  initial begin
    run;
    $finish(0);
  end
endmodule
