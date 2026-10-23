// IEEE 1364-2005 §10.2.3 gives each automatic task invocation its own
// variable state; A.2.8 also permits parameter/localparam declarations.
// §4.10: "Parameters are not variables; they are constants."
//
// HAND DERIVATION. step = 2 + 1 = 3. sum(2) waits one tick before each
// recursion, reaches sum(0)=0 at t=2, and unwinds to 3 then 6. A second
// call sum(3) starts at t=2 and returns 9 at t=5. This exercises the saved
// frames of recursive timed activations and their constant values.
// Rejection neighbour: subroutine_parameter_assignment_rejected.v.
//! inherited IEEE 1364-2005 4.10 10.2.3 A.2.8
// native-required
`timescale 1ns/1ns
module b_10_timed_subroutine_parameters;
  integer result;
  task automatic sum(input integer n, output integer total);
    parameter offset = 2;
    localparam step = offset + 1;
    integer below;
    begin
      if (n == 0) total = 0;
      else begin
        #1 sum(n - 1, below);
        total = below + step;
      end
    end
  endtask
  initial begin
    sum(2, result);
    $display("t=%0d sum2=%0d", $time, result);
    sum(3, result);
    $display("t=%0d sum3=%0d", $time, result);
  end
endmodule
