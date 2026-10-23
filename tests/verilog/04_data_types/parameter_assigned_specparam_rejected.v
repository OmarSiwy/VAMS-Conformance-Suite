// IEEE 1364-2005 §4.10.3, p. 38: "Specify parameters and module parameters
// are not interchangeable. In addition, module parameters shall not be
// assigned a constant expression that includes any specify parameters."
// Table 4-7: a parameter "May not be assigned specparams".
//
// regsize's value names the specparam dhold. Legal neighbour: the specparam
// tpd = dhold + 1 reads it, since a specparam "May be assigned specparams
// and parameters" (Table 4-7).
//! inherited IEEE 1364-2005 4.10.3
//! reject E1100
//! reject includes a specify parameter
module b_4_10_3_parameter_assigned_specparam_rejected;
  specparam dhold = 1;
  specparam tpd = dhold + 1;
  parameter regsize = dhold + 1;
  initial $display("%0d %0d", tpd, regsize);
endmodule
