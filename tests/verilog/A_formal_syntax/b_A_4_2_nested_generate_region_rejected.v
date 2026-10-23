// IEEE 1364-2005 A.4.2, p. 495:
//   generate_region ::= generate { module_or_generate_item } endgenerate
// A.1.4, p. 488: generate_region is a non_port_module_item, and it is not a
// module_or_generate_item. So a generate region holds module_or_generate_items
// and cannot hold another generate region.
//
// A `generate ... endgenerate` inside a generate region derives nothing.
// Legal neighbour: b_A_4_2_generate_constructs.v (one region holding a loop).
//! inherited IEEE 1364-2005 A.4.2
//! reject E0228
//! reject a generate region inside another generate region
//! neighbour b_A_4_2_generate_constructs.v
module b_A_4_2_nested_generate_region_rejected;
  wire w;
  generate
    generate
      assign w = 1'b1;
    endgenerate
  endgenerate
  initial $display("unreachable");
endmodule
