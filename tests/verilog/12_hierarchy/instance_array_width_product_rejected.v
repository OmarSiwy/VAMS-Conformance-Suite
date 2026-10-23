// IEEE 1364-2005 §12.1.2 applies §7.1.6's port-expression rules to arrays
// of module instances. An expression is either as wide as one port or as
// wide as that port times the number of instances; other widths are errors.
// §7.1.6: "Too many or too few bits to connect to all the instances shall
// be considered an error."
//
// HAND DERIVATION. Port width = 65536 and instance count = 65536, whose
// product is 4294967296, outside u32. The actual has width 2, matching
// neither width. This must be the normal width diagnostic, never an integer
// overflow while calculating the rejected size; no child need be allocated.
// Legal neighbour: instance_array_width_product.v uses width 2 times
// two elements = a four-bit actual and checks both array directions.
//! inherited IEEE 1364-2005 12.1.2 7.1.6
//! reject E1100
//! reject as wide as the port or as the port times the array size
//! neighbour instance_array_width_product.v
module wide_leaf(input [65535:0] p);
endmodule
module b_12_instance_array_width_product_rejected;
  wire [1:0] p;
  wide_leaf u[65535:0](p);
endmodule
