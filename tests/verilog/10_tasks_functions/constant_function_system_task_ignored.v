//! inherited IEEE 1364-2005 10.4.5
// A system task in a constant function is ignored when the call is evaluated
// at elaboration (constfunc13).
module triage_constant_function_system_task_ignored;
  function integer f(input integer i);
    begin
      $display("elaboration");
      f = i + 1;
    end
  endfunction

  localparam p = f(1);

  initial begin
    if (p === 2)
      $display("PASSED");
    else
      $display("FAILED %0d", p);
  end
endmodule
