// IEEE 1364-2005 §12.5, p. 192: "This expression selects a particular instance
// of the array and is, therefore, called an instance select. The expression
// shall evaluate to one of the legal index values of the array."
//
// arr is declared [1:0]; arr[5] selects no instance. Legal neighbour:
// instance_select.v (arr[0], arr[1]).
//! inherited IEEE 1364-2005 12.5
//! reject E1100
//! reject instance select out of range
//! neighbour instance_select.v
module leaf;
  integer x;
  initial x = 1;
endmodule
module b_12_5_instance_select_out_of_range_rejected;
  leaf arr[1:0] ();
  initial #1 $display("%0d", arr[5].x);
endmodule
