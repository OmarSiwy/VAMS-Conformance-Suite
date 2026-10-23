// IEEE 1364-2005 17.2.9: "Either task can be executed at any time during
// simulation", and Syntax 17-7 writes `start_addr` and `finish_addr` as
// plain arguments, with no constant_ requirement (contrast `" file_name "`,
// which the box prints as a string literal). So bounds held in variables
// are legal and are read when the task runs.
// By hand, with `reg [3:0] m [0:7]` and 09_readmemb_range.bin (0001, 0010,
// x1z0, 1111): first = 5 and last = 2 are assigned before the call, so the
// load runs downward over 5, 4, 3, 2 exactly as readmemb_range.v's
// literal bounds do, and m[1], m[6] keep x. Printed ascending m[1]..m[6]:
//     xxxx 1111 x1z0 0010 0001 xxxx
// A refusal of the variable bounds (the defect this pins) compiles nothing.
// readmem_unknown_bound_rejected.v is the invalid neighbour.
//! lrm 9.5 (Table 9-2)
//! inherited IEEE 1364-2005 17.2.9
//! data 09_readmemb_range.bin
//! expect stdout readmem_variable_bounds.expected.txt
`timescale 1ns/1ns
module b_17_2_9_readmem_variable_bounds;
  reg [3:0] m [0:7];
  integer first, last;
  initial begin
    first = 5;
    last = first - 3;
    $readmemb("09_readmemb_range.bin", m, first, last);
    $display("%b %b %b %b %b %b", m[1], m[2], m[3], m[4], m[5], m[6]);
    $finish(0);
  end
endmodule
