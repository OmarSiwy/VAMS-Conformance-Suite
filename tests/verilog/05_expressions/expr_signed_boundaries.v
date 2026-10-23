// IEEE1364-2005 §§5.5/5.5.1/5.5.3: signed cast preserves input width;
// $unsigned(-4'sd4) is4'b1100 and zero-extends. Signed8'h80 extends with
// ones, but its full part-select, bit-select and concatenation are unsigned.
// Destination signedness cannot change an unsigned RHS into signed operands.
//! inherited IEEE 1364-2005 5.5 5.5.1 5.5.3
module audit_expr_signed_boundaries;
  reg signed [7:0] s;
  reg [15:0] whole, selected, joined, bit_value;
  reg [7:0] unsigned_cast, signed_cast;
  reg signed [15:0] signed_destination;
  initial begin
    s = 8'h80;
    whole = s;
    selected = s[7:0];
    joined = {s};
    bit_value = s[7];
    signed_destination = s[7:0];
    unsigned_cast = $unsigned(-4'sd4);
    signed_cast = $signed(4'b1100);
    $display("whole=%h selected=%h joined=%h bit=%h", whole, selected, joined, bit_value);
    $display("signed_destination=%0d casts=%b,%b", signed_destination, unsigned_cast, signed_cast);
    $finish(0);
  end
endmodule
