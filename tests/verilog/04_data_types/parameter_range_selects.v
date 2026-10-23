//! inherited IEEE 1364-2005 4.10.1 5.2.1
// A part-select of a parameter indexes its declared range: b is [9:1], so
// b[1] is the LSB and b[9] is the 9th bit (pr1913918b).
module triage_parameter_range_selects;
  parameter [9:1] b = 9'b0_0000_0010;
  wire a;

  assign a = b[1] ^ b[9];

  initial #1 if (a === 1'b0) $display("PASSED"); else $display("FAILED %b", a);
endmodule
