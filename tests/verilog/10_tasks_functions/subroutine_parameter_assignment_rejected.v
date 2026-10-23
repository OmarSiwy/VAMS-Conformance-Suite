// IEEE 1364-2005 §4.10: "Parameters are not variables; they are constants."
// §4.10.2 applies the same rule to localparams. A.2.8 allows step to be
// declared here, but assigning it procedurally cannot change its value.
// Legal neighbour: automatic_subroutine_parameters.v reads step in
// automatic task/function activations and checks their derived results.
//! inherited IEEE 1364-2005 4.10 4.10.2
//! reject E1100
//! reject a parameter is a constant; it cannot be assigned
//! neighbour automatic_subroutine_parameters.v
module b_10_subroutine_parameter_assignment_rejected;
  task automatic update;
    localparam step = 3;
    step = 4;
  endtask
  initial update;
endmodule
