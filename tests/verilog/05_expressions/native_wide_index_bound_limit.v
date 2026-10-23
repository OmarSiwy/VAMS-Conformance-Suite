// Implementation limit, not an IEEE 1364-2005 §5.2.1 source restriction:
// constant part-select bounds are stored as signed i64. A 130-bit bound
// whose numeric value fits that range is legal and runs in
// native_wide_index_values.v. This bound's value is 2^64, outside it, and
// must name that limit rather than falsely report that the value is x/z.
//! inherited IEEE 1364-2005 5.2.1
//! reject E1100
//! reject a part-select bound is outside the supported i64 range
//! neighbour native_wide_index_values.v
module native_wide_index_bound_limit;
  reg [7:0] v;
  initial $display("%b", v[130'h10000000000000000:130'h10000000000000000]);
endmodule
