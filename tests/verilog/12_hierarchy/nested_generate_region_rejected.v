// IEEE 1364-2005 §12.4, p. 181: "Generate regions do not nest, and they may only
// occur directly within a module."
//
// A generate region is opened inside another. Legal neighbour:
// generate_region_optional.v (one region, in g2b1).
//! lrm 6.6
//! lrm 6.6:7
//! inherited IEEE 1364-2005 12.4
//! reject E0228
//! reject a generate region inside another generate region
//! neighbour generate_region_optional.v
module b_12_4_nested_generate_region_rejected;
  generate
    generate
      if (1) begin : g
        initial $display("x");
      end
    endgenerate
  endgenerate
endmodule
