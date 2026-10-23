// IEEE1364-2005 §5.5: casts change sign, not width or bits.
// -4'sd4 has4-bit pattern1100; unsigned cast extends with zeros, signed
// cast of4'b1100 extends with ones. Source §5.5's own boundary values.
//! inherited IEEE 1364-2005 5.5 5.5.3
module audit_expr_cast_width;
  reg [7:0] u, s;
  initial begin
    u = $unsigned(-4'sd4);
    s = $signed(4'b1100);
    $display("casts=%b,%b", u, s);
    $finish(0);
  end
endmodule
