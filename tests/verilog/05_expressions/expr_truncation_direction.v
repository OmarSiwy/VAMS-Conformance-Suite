// IEEE1364-2005 §5.6: discard MSBs regardless of declared index direction;
// signed8'h8f truncates to signed5'b01111, changing sign to positive15.
// Low bits retain x/z exactly; width mismatch needs no warning or rejection.
//! inherited IEEE 1364-2005 5.6
module audit_expr_truncation_direction;
  reg signed [7:0] source;
  reg signed [0:4] ascending;
  reg signed [4:0] descending;
  reg [0:3] unknown_low;
  initial begin
    source = 8'sh8f;
    ascending = source; descending = source;
    unknown_low = 8'b1010xz10;
    $display("truncated=%b,%b signed=%0d,%0d", ascending, descending, ascending, descending);
    $display("retained=%b", unknown_low);
    $finish(0);
  end
endmodule
