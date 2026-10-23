// IEEE1364-2005 §§5.5.1/5.5.3/5.5.4: signed top x/z replicates in
// extension; unsigned assignment/concatenation pads zero instead.
// Casting the same4-bit unsigned value to signed restores x sign extension.
// Arithmetic addition with a signed unknown operand yields all x.
//! inherited IEEE 1364-2005 5.5.1 5.5.3 5.5.4
module audit_expr_unknown_extension;
  reg signed [3:0] sx, sz;
  reg [3:0] ux;
  reg [7:0] ex, ez, eu, ec, casted, arithmetic;
  initial begin
    sx = 4'bx101; sz = 4'bz101; ux = 4'bx101;
    ex = sx; ez = sz; eu = ux;
    ec = {sx}; casted = $signed(ux);
    arithmetic = sx + 4'sd0;
    $display("signed=%b,%b unsigned=%b", ex, ez, eu);
    $display("concat=%b cast=%b arithmetic=%b", ec, casted, arithmetic);
    $finish(0);
  end
endmodule
