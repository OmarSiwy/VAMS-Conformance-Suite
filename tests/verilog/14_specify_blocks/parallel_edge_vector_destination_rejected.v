// IEEE 1364-2005 §14.2.3, p. 214: "For parallel connections (=>), the
// destination shall be any scalar output or inout port or the bit-select of
// a vector output or inout port."
//
// The parallel edge-sensitive path ends at q, a whole 2-bit output: neither a
// scalar nor a bit-select. Legal neighbour: edge_state_dependent_paths.v's
// ( posedge clk => ( q[0] : data ) ), the bit-select the clause allows.
//! inherited IEEE 1364-2005 14.2.3
//! reject destination
//! neighbour edge_state_dependent_paths.v
`timescale 1ns/1ns
module b_14_2_3_parallel_edge_vector_destination_rejected(clk, data, q);
  input clk, data;
  output [1:0] q;
  reg [1:0] q;
  always @(posedge clk) q <= {data, data};
  specify
    ( posedge clk => ( q : data ) ) = (10, 5);
  endspecify
endmodule
