// IEEE 1364-2005 §4.10.2, p. 37: "Local parameters can be assigned constant
// expressions containing parameters, which can be modified with defparam
// statements or module instance parameter value assignments." "Bit-selects
// and part-selects of local parameters that are not of type real shall be
// allowed (see 5.2)." §12.2.2.1, p. 171: "Local parameters cannot be
// overridden; therefore, they are not considered part of the ordered list
// for parameter value assignment. In the following example, addr_width will
// be assigned the value 12, and data_width will be assigned the value 16.
// mem_size will not be explicitly assigned a value due to the ordered list,
// but will have the value 4096 due to its declaration expression."
//
// The clause's my_mem, instantiated #(12, 16): addr_width 12, data_width 16,
// mem_size = 1 << 12 = 4096. mask = mem_size - 1 = 4095, 32 bits wide
// (1 << addr_width takes the width of its left operand 1, 32 bits): bit 11
// is 1, bit 12 is 0, and the part-select [3:0] is 1111.
// Output: "12 16 4096 1 0 1111".
//! inherited IEEE 1364-2005 4.10.2
module b_4_10_2_my_mem;
  parameter addr_width = 16;
  localparam mem_size = 1 << addr_width;
  parameter data_width = 8;
  localparam mask = mem_size - 1;
  initial $display("%0d %0d %0d %b %b %b", addr_width, data_width, mem_size, mask[11], mask[12], mask[3:0]);
endmodule
module b_4_10_2_localparam_from_parameter;
  b_4_10_2_my_mem #(12, 16) m();
endmodule
