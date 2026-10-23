// IEEE 1364-2005 §6.2, p. 72: "In contrast, procedural assignments put values
// in variables. The assignment does not have duration; instead, the variable
// holds the value of the assignment until the next procedural assignment to
// that variable." ... "Procedural assignments occur within procedures such as
// always, initial (see 9.9), task, and function (see Clause 10) and can be
// thought of as “triggered” assignments. The trigger occurs when the flow of
// execution in the simulation reaches an assignment within a procedure.
// Reaching the assignment can be controlled by conditional statements."
//
// v is assigned from an initial block, an always block, a task and (through
// its result) a function; every read is at least one time unit after the
// assignment it expects.
//   t1: initial v = 10                               -> 10
//   t6: nothing assigned v since                     -> 10 (held)
//   t6: clk 0 -> 1 is a posedge (§9.7.2), the always block runs v = v + 1;
//       read at t7                                   -> 11
//   t7: set_v(40), the task assigns v = 40; read at t8 -> 40
//   t11: nothing assigned v since                    -> 40 (held)
//   t11: `if (v == 0) v = 99;` is not reached: v is 40 -> 40
//   t11: v = twice(v): the function's local t = 40, then t = t + 40 = 80
//        (t holds 40 between its two assignments), twice = 80; read at t12
//                                                    -> 80
// clk goes x -> 0 at time 0, which is not a posedge, so the always block
// runs only at t6.
//! inherited IEEE 1364-2005 6.2
module b_6_2_variable_holds_value;
  reg [7:0] v;
  reg clk;
  task set_v;
    input [7:0] x;
    v = x;
  endtask
  function [7:0] twice;
    input [7:0] x;
    reg [7:0] t;
    begin
      t = x;
      t = t + x;
      twice = t;
    end
  endfunction
  always @(posedge clk) v = v + 1;
  initial begin
    clk = 0;
    v = 8'd10;
    #1 $display("%0d", v);
    #5 $display("%0d", v);
    clk = 1;
    #1 $display("%0d", v);
    set_v(8'd40);
    #1 $display("%0d", v);
    #3 $display("%0d", v);
    if (v == 8'd0) v = 8'd99;
    $display("%0d", v);
    v = twice(v);
    #1 $display("%0d", v);
    $finish(0);
  end
endmodule
