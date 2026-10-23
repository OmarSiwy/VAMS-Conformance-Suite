//! inherited IEEE 1364-2005 4.10.1
// An untyped parameter takes the size of its final value, so the addition in
// sum2 is 3 bits and in sum4 2 bits; a range makes sum1 and sum3 4 bits
// (param-width).
module triage_untyped_parameter_width;
  parameter a = 3'd4;
  parameter b = 3'd5;
  parameter c = 2'd2;
  parameter d = 2'd3;
  parameter [3:0] sum1 = a + b;
  parameter       sum2 = a + b;
  parameter [3:0] sum3 = c + d;
  parameter       sum4 = c + d;

  initial begin
    if (sum1 === 4'b1001 && sum2 === 3'b001 && sum3 === 4'b0101 && sum4 === 2'b01)
      $display("PASSED");
    else
      $display("FAILED %b %b %b %b", sum1, sum2, sum3, sum4);
  end
endmodule
