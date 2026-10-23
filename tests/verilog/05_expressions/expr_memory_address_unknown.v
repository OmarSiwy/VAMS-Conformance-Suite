// IEEE1364-2005 §5.2.2: nested indirection permitted; out-of-range or
// anyx/z address returns an unknown word. This is unpacked array addressing,
// not a packed-select diagnostic or whole-array expression.
//! inherited IEEE 1364-2005 5.2.2
module audit_expr_memory_address_unknown;
  reg [3:0] memory [0:1];
  reg [2:0] index;
  initial begin
    memory[0]=1; memory[1]=10;
    $display("indirect=%b",memory[memory[0]]);
    index=3; $display("outside=%b",memory[index]);
    index=3'b00x; $display("unknown=%b",memory[index]);
    index=3'b00z; $display("highz=%b",memory[index]);
    $finish(0);
  end
endmodule
