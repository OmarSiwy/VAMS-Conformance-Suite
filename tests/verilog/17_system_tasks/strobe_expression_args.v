//! inherited IEEE 1364-2005 17.1.3
// $strobe takes expression arguments and shows their end-of-step values:
// value is 2 and value+1 is 3 when the line prints (br916a).
module triage_strobe_expression_args;
  integer value;

  initial begin
    value = 0;
    $strobe("%0d %0d", value, value + 1);
    value = 2;
  end
endmodule
