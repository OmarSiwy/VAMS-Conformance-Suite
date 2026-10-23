//! inherited IEEE 1364-2005 17.1.1
// A string-valued parameter passed as $display's only argument is an integral
// constant (§3.6); VerA prints it in decimal ("AB" is 16#4142 = 16706)
// (param_string).
module triage_string_parameter_prints_decimal;
  parameter P = "AB";

  initial $display(P);
endmodule
