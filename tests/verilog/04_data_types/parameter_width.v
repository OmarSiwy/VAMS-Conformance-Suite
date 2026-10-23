//! inherited IEEE 1364-2005 4.10.1 5.4.1
// An untyped parameter takes the size of its final value: a 3-bit sum, a
// 4-bit ranged sum, and a 2-bit sum after the defparams (param-width).
module triage_parameter_width;
  parameter a = 3'd4;
  parameter b = 3'd5;
  parameter c = 3'd4;
  parameter d = 3'd5;

  parameter [3:0] sum1 = a + b;
  parameter sum2 = a + b;
  parameter [3:0] sum3 = c + d;
  parameter sum4 = c + d;

  defparam c = 2'd2;
  defparam d = 2'd3;

  initial begin
    $display("%b", sum1);
    $display("%b", sum2);
    $display("%b", sum3);
    $display("%b", sum4);
  end
endmodule
