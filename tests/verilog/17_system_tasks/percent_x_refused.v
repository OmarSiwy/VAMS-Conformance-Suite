//! inherited IEEE 1364-2005 17.1.1.2
//! reject Table 9-22 conversions
// %x is not a 1364-2005 format specification (IEEE 1800 added it as an alias
// for %h), so the call has no meaning (string13).
module triage_percent_x_refused;
  reg [7:0] a;
  initial begin
    a = 8'h5a;
    $display("%x", a);
  end
endmodule
