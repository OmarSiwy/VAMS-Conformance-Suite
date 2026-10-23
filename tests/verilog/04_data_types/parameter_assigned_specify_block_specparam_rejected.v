// IEEE 1364-2005 §4.10.3, p. 38: "module parameters shall not be assigned a
// constant expression that includes any specify parameters." Table 4-7: a
// parameter "May not be assigned specparams".
//
// The specparam here is declared inside the specify block, not in the module
// body (parameter_assigned_specparam_rejected.v is that form). Being
// visible to the body (09_behavioral_modeling/specify_block_specparam.v,
// the legal neighbour, uses one as a delay) does not make it a parameter's
// operand.
//! inherited IEEE 1364-2005 4.10.3
//! reject E1100
//! reject includes a specify parameter
module b_4_10_3_parameter_assigned_specify_block_specparam_rejected;
  specify
    specparam dhold = 1;
  endspecify
  parameter regsize = dhold + 1;
  initial $display("%0d", regsize);
endmodule
