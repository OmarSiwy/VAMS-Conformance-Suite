//! inherited IEEE 1364-2005 17.1.1.2
// %z reads and writes unformatted four-value data; a 32-bit value with x and
// z bits survives $sformat then $sscanf unchanged (sscanf_z).
module triage_sscanf_unformatted_z;
  reg [63:0] str;
  reg [31:0] in, out;
  integer res;

  initial begin
    // Each byte needs an x or a 1 beside its z bits, so it is not a NUL.
    in = 32'b000x100z_001z000x_101xxxzz_100z111x;
    $sformat(str, "%z", in);
    res = $sscanf(str, "%z", out);
    if (res !== 1) $display("FAILED: $sscanf() returned %0d", res);
    else if (in !== out) $display("FAILED: %b !== %b", in, out);
    else $display("PASSED");
  end
endmodule
