// IEEE 1364-2005 §7.1.5, pp. 77-78: "An array of instances shall have a
// continuous range. One instance identifier shall be associated with only one
// range to declare an array of instances." ... "The declaration shown below
// is illegal:
//   nand #2 t_nand[0:3] ( ... ), t_nand[4:7] ( ... );"
//
// The clause's illegal declaration: t_nand is given two ranges. Legal
// neighbour: two_named_arrays.v (one range per name).
//! inherited IEEE 1364-2005 7.1.5
//! reject E1100
//! reject t_nand
//! neighbour two_named_arrays.v
module b_7_1_5_split_array_rejected;
  reg [3:0] a1, b1, a2, b2;
  wire [3:0] o1, o2;
  nand #2 t_nand[0:3] (o1, a1, b1), t_nand[4:7] (o2, a2, b2);
  initial $finish(0);
endmodule
