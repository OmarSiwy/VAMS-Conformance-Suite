// IEEE 1364-2005 §5.2.2, p. 58: "The addr_expr can be any integer
// expression; therefore, memory indirections can be specified in a single
// expression." ... "If the index is out of the address bounds or if any bit
// in the address is x or z, then the value of the reference shall be x." ...
// "The syntax for access to the array shall consist of the name of the memory
// or array and an integer expression for each addressed dimension"
//
// reg [7:0] mem_name[0:1023]; mem_name[3] = 5, mem_name[5] = 8'hAB:
//   mem_name[mem_name[3]] = mem_name[5] -> ab
//   out of bounds: mem_name[a], a = 1024 -> xx (all 8 bits x)
//   an x address bit: mem_name[{9'd0, 1'bx}] -> xx
// Two dimensions, reg [7:0] twod_array[0:255][0:255], twod_array[14][1] =
// 8'h5C, addressed with a run-time index for each dimension: row = 14,
// col = 1 -> 5c; col = 256 (out of bounds) -> xx.
// The out-of-bounds indices are variables, so NOTE 2 of §5.2.1 (constant
// indices "may be flagged as a compile time error") does not apply.
//! inherited IEEE 1364-2005 5.2.2
module b_5_2_2_memory_indirection;
  reg [7:0] mem_name[0:1023];
  reg [7:0] twod_array[0:255][0:255];
  integer a, row, col;
  initial begin
    mem_name[3] = 5;
    mem_name[5] = 8'hAB;
    a = 1024;
    $display("%h %h %h", mem_name[mem_name[3]], mem_name[a], mem_name[{9'd0, 1'bx}]);
    twod_array[14][1] = 8'h5C;
    row = 14;
    col = 1;
    $write("%h ", twod_array[row][col]);
    col = 256;
    $display("%h", twod_array[row][col]);
    $finish(0);
  end
endmodule
