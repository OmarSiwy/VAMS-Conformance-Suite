// IEEE 1364-2005 §10.4.5, p. 156: "Constant function calls are used to support
// the building of complex calculations of values at elaboration time (see
// 12.8). A constant function call shall be a function invocation of a
// constant function local to the calling module where the arguments to the
// function are constant expressions." ... "Constant function calls are
// evaluated at elaboration time. Their execution has no effect on the initial
// values of the variables used either at simulation time or among multiple
// invocations of a function at elaboration time."
//
// The clause's clogb2 (ceiling of log base 2), as in ram_model:
//   clogb2(v): value = v - 1, then count right shifts until value is 0.
//   clogb2(256): 255 = 8'b1111_1111 needs 8 shifts -> 8 (ram_depth 256).
//   clogb2(421): 420 = 9'b1_1010_0100 needs 9 shifts -> 9 (the #(32,421)
//     instance ram_a0).
// addr_width = clogb2(ram_depth) sizes the address port, driven all ones, so
// the width is observable as its value: 8 ones = 255, 9 ones = 511.
// A run-time call of the same function is unaffected by the elaboration-time
// calls: clogb2(5): 4 = 3'b100 needs 3 shifts -> 3.
// Each instance prints at t = data_width (8 and 32), so no two lines race:
//   "8 255 3" then "9 511 3".
//! inherited IEEE 1364-2005 10.4.5
`timescale 1ns/1ns
module b_10_4_5_constant_function_clogb2;
  wire [7:0] w0;
  wire [8:0] w1;
  ram_model ram_d(w0);
  ram_model #(32, 421) ram_a0(w1);
  initial #33 $finish(0);
endmodule

module ram_model (address);
  parameter data_width = 8;
  parameter ram_depth = 256;
  localparam addr_width = clogb2(ram_depth);
  output [addr_width - 1:0] address;
  //define the clogb2 function
  function integer clogb2;
    input [31:0] value;
    begin
      value = value - 1;
      for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
        value = value >> 1;
    end
  endfunction
  assign address = {addr_width{1'b1}};
  initial #(data_width) $display("%0d %0d %0d", addr_width, address, clogb2(5));
endmodule
