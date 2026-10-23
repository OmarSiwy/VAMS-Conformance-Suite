// IEEE 1364-2005 §4.10: "Parameters are not variables; they are constants."
// §4.10.2 gives localparams the same value rules. A.2.8 permits both in a
// task or function. §10.2.3 initializes automatic VARIABLES on entry, not
// these constants; §10.4.2 likewise gives automatic functions fresh locals.
//
// HAND DERIVATION. offset = 2, step = offset + 1 = 3 in each subroutine.
// add(4) = 4 + 3 = 7, and add(5) = 8 on the next activation; add_task
// computes the same values through an output formal. sum(2) returns
// sum(1)+3 = sum(0)+6 = 6; sum(3) returns 9. Calling both checks that a
// recursive activation neither initializes nor restores constants as
// unknown variable storage. The rejection neighbour
// subroutine_parameter_assignment_rejected.v forbids writing step.
//! inherited IEEE 1364-2005 4.10 4.10.2 10.2.3 10.4.2 A.2.8
module b_10_automatic_subroutine_parameters;
  integer result;
  function automatic integer add(input integer n);
    parameter offset = 2;
    localparam step = offset + 1;
    add = n + step;
  endfunction
  function automatic integer sum(input integer n);
    parameter offset = 2;
    localparam step = offset + 1;
    sum = (n == 0) ? 0 : sum(n - 1) + step;
  endfunction
  task automatic add_task(input integer n, output integer total);
    parameter offset = 2;
    localparam step = offset + 1;
    total = n + step;
  endtask
  initial begin
    $display("add4=%0d add5=%0d", add(4), add(5));
    add_task(4, result);
    $display("task4=%0d", result);
    add_task(5, result);
    $display("task5=%0d", result);
    $display("sum2=%0d sum3=%0d", sum(2), sum(3));
  end
endmodule
