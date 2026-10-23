// Runtime design for subroutines.c. W=8 sizes the first function
// and its formal/local variables. The module local_value=99 deliberately
// has the same name as local variables, exposing accidental upward lookup.
// first(5): local_value=count=6, scratch=2.5, later(6)=12.
// recur(3): 1 + 1 + 2 + 3 = 7; its activations are automatic.
// adjust(4, task_out, 1): local_value=7, output y=8.
// negate(3)=-3 and real_id(1.5)=1.5.
`timescale 1ns/1ns
module b26_subroutines;
  parameter W = 8;
  integer local_value, result, recursive_result, task_out, negative_result;
  real real_result;

  function [W-1:0] first(input [W-1:0] x);
    reg [W-1:0] local_value;
    integer count;
    real scratch;
    begin
      local_value = x + 1;
      count = local_value;
      scratch = 2.5;
      first = later(local_value);
    end
  endfunction

  function [W-1:0] later(input [W-1:0] x);
    later = x * 2;
  endfunction

  function automatic integer recur(input integer n);
    integer local_value;
    begin
      local_value = n;
      if (n == 0) recur = 1;
      else recur = recur(n - 1) + local_value;
    end
  endfunction

  task adjust(input integer n, output integer y, input flag);
    integer local_value;
    begin
      local_value = n + 3;
      y = local_value + flag;
    end
  endtask

  function signed [3:0] negate(input signed [3:0] x);
    negate = -x;
  endfunction

  function real real_id(input real x);
    real_id = x;
  endfunction

  initial begin
    local_value = 99;
    result = first(5);
    recursive_result = recur(3);
    adjust(4, task_out, 1);
    negative_result = negate(3);
    real_result = real_id(1.5);
    #1 $finish(0);
  end
endmodule
