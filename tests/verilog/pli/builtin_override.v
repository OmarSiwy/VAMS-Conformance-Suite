// Required-positive HOST test, not executable without the paired C plugin.
// IEEE20.4: user registration overrides built-in $unsigned. Its fixed40-bit
// result is8000000001 at BOTH 1-bit and64-bit argument call sites, whereas
// the built-in would produce1 and0. Assignment destinations are explicitly40.
module audit_builtin_override;
  reg [39:0] first, second;
  initial begin
    first = $unsigned(1'b1);
    second = $unsigned(64'h0);
    $display("first=%h second=%h",first,second);
    $finish(0);
  end
endmodule
