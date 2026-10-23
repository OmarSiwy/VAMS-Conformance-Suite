// IEEE1364-2005 §4.3.1: bounds may be negative, ascending or equal.
// [-2:1] and[1:-2] both contain4bits, leftboundMSB;17 truncates to1.
// [-3:-3] is1bit. No packed-select support is needed to observe widths.
//! inherited IEEE 1364-2005 4.3.1
module audit_type_negative_vector_bounds;
  reg [-2:1] ascending;
  reg [1:-2] descending;
  reg [-3:-3] singleton;
  initial begin
    ascending=17; descending=17; singleton=3;
    $display("ranges=%b,%b,%b", ascending, descending, singleton);
    $finish(0);
  end
endmodule
