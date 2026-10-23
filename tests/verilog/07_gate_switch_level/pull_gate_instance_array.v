//! inherited IEEE 1364-2005 7.8 A.3.1
// A.3.1's name_of_gate_instance takes a range, so a pull gate array is legal
// (pullupdown2/3).
module triage_pull_gate_instance_array;
  wire [7:0] n;

  pullup u8 [7:0] (n);

  initial #1 $display("%b", n);
endmodule
