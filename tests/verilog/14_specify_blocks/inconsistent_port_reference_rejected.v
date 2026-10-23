// IEEE 1364-2005 §14.2.4.3, p. 217: "Different delays can be assigned to the
// same edge-sensitive path as long as the following criteria are met:" ...
// "— The port is referenced in the same way in all path declarations (entire
// port, bit-select, or part-select)." Its Example 4 (p. 218): "The two
// state-dependent path declarations shown below are not legal because even
// though they have different conditions, the destinations are not specified
// in the same way: the first destination is a part-select, the second is a
// bit-select.
//   specify
//     if (reset)
//       (posedge clk => (q[3:0]:data)) = (10,5);
//     if (!reset)
//       (posedge clk => (q[0]:data)) = (15,8);
//   endspecify"
//
// The cell is that example. Legal neighbour:
// edge_state_dependent_paths.v, whose Example 3 names q[0] alike
// in both declarations.
//! inherited IEEE 1364-2005 14.2.4.3
//! reject referenced in the same way
//! neighbour edge_state_dependent_paths.v
`timescale 1ns/1ns
module b_14_2_4_3_inconsistent_port_reference_rejected(clk, reset, data, q);
  input clk, reset, data;
  output [3:0] q;
  reg [3:0] q;
  always @(posedge clk) q <= {4{data}};
  specify
    if (reset)
      (posedge clk => (q[3:0]:data)) = (10,5);
    if (!reset)
      (posedge clk => (q[0]:data)) = (15,8);
  endspecify
endmodule
