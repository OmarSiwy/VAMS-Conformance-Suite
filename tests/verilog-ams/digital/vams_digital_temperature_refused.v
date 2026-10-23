// VAMS §9.2 Table 9-12 gives `$temperature` "Supported in digital context:
// Yes". VerA's digital engine does not evaluate it, so the call is refused by
// name (E0829, citing its table) rather than as an unknown expression form
// (#58: it was E1100 "this digital expression form is not implemented").
// Legal neighbour: vams_digital_abstime_math.v runs $abstime, $ln1p and
// $expm1, Table 9-7 and 9-11 functions with the same Yes, in an `initial`.
//! lrm 9.2
//! reject E0829
//! reject Table 9-12
//! neighbour vams_digital_abstime_math.v
module vams_digital_temperature_refused;
  initial $display("%g", $temperature);
endmodule
