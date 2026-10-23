//! inherited IEEE 1364-2005 17.3.1
//! reject $printtimescale names a module instance
// $printtimescale takes a module path; .P names a parameter, not a module
// (pr1701855b).
`timescale 1ns/1ns
module triage_printtimescale_parameter_rejected;
  parameter P = 2;

  initial $printtimescale(triage_printtimescale_parameter_rejected.P);
endmodule
