// IEEE 1364-2005 §§5.2.2 and 9.7.3 require an integral array index.
// A real index is invalid even if its current value is exactly representable
// as an integer. native_wide_event_indices.v runs the legal integral form,
// including wide negative indices, beside this isolated refusal.
//! inherited IEEE 1364-2005 5.2.2 9.7.3
//! reject E1100
//! reject an event array index must be integral
//! neighbour native_wide_event_indices.v
module native_wide_event_real_index_rejected;
  event ready[0:1];
  real selected;
  initial begin selected = 1.0; -> ready[selected]; end
endmodule
